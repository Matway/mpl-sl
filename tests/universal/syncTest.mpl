# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.String"    use
"String.printList" use
"algorithm.="      use
"control.Nat16"    use
"control.ensure"   use
"control.failProc" use
"control.pfunc"    use
"control.when"     use

"sync/sync.connectTcp"   use
"sync/sync.getTime"      use
"sync/sync.ipv4ToString" use
"sync/sync.listenTcp"    use
"sync/sync.sleepFor"     use
"sync/sync.spawn"        use
"sync/sync.yield"        use

syncTest: [];

[
  time0: getTime;
  time1: getTime;
  [time1 time0 < ~] "getTime returned non-monotonic values" ensure
] call

[
  [0xC0A86465n32 ipv4ToString "192.168.100.101" =] "ipv4ToString returned unexpected string" ensure
] call

# Test that sleepFor does not block in canceled contexts
[
  stage: 0;
  context: {stage: @stage; CALL: [
    0.01 sleepFor
    1 @stage set
  ];} () spawn;

  @context.cancel
  yield
  [stage 1 =] "sleepFor blocked in the canceled context" ensure
] call

# Test that sleepFor blocks and cancels properly
[
  stage: 0;
  context: {stage: @stage; CALL: [
    1000.0 sleepFor
    1 @stage set
  ];} () spawn;

  yield
  [stage 0 =] "sleepFor did not block" ensure
  @context.cancel
  [stage 0 =] "sleepFor canceled immediately" ensure
  yield
  [stage 1 =] "sleepFor did not cancel" ensure
] call

# Test that sleepFor wakes context in the correct order
[
  stage: 0;
  context0: {stage: @stage; CALL: [
    0.01 sleepFor
    [stage 1 =] "sleep woke contexts in the wrong order" ensure
    2 @stage set
  ];} () spawn;

  context1: {stage: @stage; CALL: [
    0.0 sleepFor
    [stage 0 =] "sleep woke contexts in the wrong order" ensure
    1 @stage set
  ];} () spawn;

  context2: {stage: @stage; CALL: [
    0.02 sleepFor
    [stage 2 =] "sleep woke contexts in the wrong order" ensure
  ];} () spawn;
] call

[
  tcpPort: [6600n16];
  tcpPort: [TCP_PORT TRUE] [TCP_PORT Nat16 cast] pfunc;

  client: [
    result: String;
    connection: 0x7F000001n32 tcpPort connectTcp !result;
    result "" = ~ [("connectTcp failed, " result LF) printList "" failProc] when

    "Hello, world!" @connection.write !result
    result "" = ~ [("TcpConnection.write failed, " result LF) printList "" failProc] when

    message: 1024 @connection.readString !result;
    result "" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "Reply: Hello, world!" = ~ [("client received unexpected response, \"" message "\"\n") printList "" failProc] when

    connection.shutdown !result
    result "" = ~ [("TcpConnection.shutdown failed, " result LF) printList "" failProc] when

    message: 1024 @connection.readString !result;
    result "closed" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "" = ~ [("client received invalid response, \"" message "\"\n") printList "" failProc] when
  ];

  server: [
    result: String;
    acceptor: 0x7F000001n32 tcpPort listenTcp !result;
    result "" = ~ [("listenTcp failed, " result LF) printList "" failProc] when

    connection: address: acceptor.accept !result;;
    result "" = ~ [("TcpAcceptor.accept failed, " result LF) printList "" failProc] when
    address 0x7F000001n32 = ~ [("TcpAcceptor.accept returned unexpected address, " address ipv4ToString LF) printList "" failProc] when

    message: 1024 @connection.readString !result;
    result "" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "Hello, world!" = ~ [("server received unexpected request, \"" message "\"\n") printList "" failProc] when

    "Reply: Hello, world!" @connection.write !result
    result "" = ~ [("TcpConnection.write failed, " result LF) printList "" failProc] when

    message: 1024 @connection.readString !result;
    result "closed" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "" = ~ [("server received invalid request, \"" message "\"\n") printList "" failProc] when

    connection.shutdown !result
    result "" = ~ [("TcpConnection.shutdown failed, " result LF) printList "" failProc] when
  ];

  serverContext: @server () spawn;
  clientContext: @client () spawn;
] call
