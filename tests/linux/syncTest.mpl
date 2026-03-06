# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.String"    use
"String.printList" use
"String.toString"  use
"algorithm.="      use
"algorithm.each"   use
"control.&&"       use
"control.Int32"    use
"control.Nat8"     use
"control.Natx"     use
"control.failProc" use
"control.min"      use
"control.times"    use
"control.when"     use
"control.while"    use

"posix.EAGAIN"      use
"posix.EWOULDBLOCK" use
"posix.pipe"        use
"posix.write"       use
"socket.send"       use

"errno.errno" use

"sync/TcpConnection"     use
"sync/sync.asyncRead"    use
"sync/sync.canceled?"    use
"sync/sync.connectTcp"   use
"sync/sync.ipv4ToString" use
"sync/sync.listenTcp"    use
"sync/sync.spawn"        use
"sync/sync.yield"        use

syncTest: [];

getServerAndClientContexts: [
  address: port:;;

  serverContext: {address: address; port: port; CALL: [
    result:   String;
    acceptor: address port listenTcp !result;
    result "" = ~ [("listenTcp failed, " result LF) printList "" failProc] when

    connection: clientAddress: acceptor.accept !result;;
    result "" = ~ [("TcpAcceptor.accept failed, " result LF) printList "" failProc] when
    clientAddress address = ~ [("TcpAcceptor.accept returned unexpected address, " clientAddress ipv4ToString LF) printList "" failProc] when

    @connection
  ];} TcpConnection spawn;

  clientContext: {address: address; port: port; CALL: [
    result:     String;
    connection: address port connectTcp !result;
    result "" = ~ [("connectTcp failed, " result LF) printList "" failProc] when

    @connection
  ];} TcpConnection spawn;

  @serverContext @clientContext
];

repeatString: [
  string: count:; toString;
  repeatedString: String;

  count dynamic [
    string @repeatedString.cat
  ] times

  @repeatedString
];

fillUpSocketSendBuffer: [
  sockfd:;
  data: "a" 1000 repeatString;

  [0 data.size Natx cast data storageAddress sockfd send -1ix = ~] [] while

  lastErrorNumber: errno;
  lastErrorNumber EAGAIN = ~ [lastErrorNumber EWOULDBLOCK = ~] && [("send failed, result=" lastErrorNumber) printList "" failProc] when
];

writeText: [
  fd: text:;;
  size: text textSize;
  result: size text storageAddress fd write;  # Natx cast
  result -1ix = [("writeText failed, result=" errno LF) printList "" failProc] when
  result Natx cast size = ~ [("unexpected write count " result LF) printList "" failProc] when
];

# Test that write does not block when read is canceled on the same fd
[
  _: client: 0x7F000001n32 6600n16 getServerAndClientContexts .get; .get;

  readContext: {connection: @client; CALL: [
    result: String;

    message: 1024 @connection.readString !result;
    result "canceled" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "" = ~ [("client received unexpected response, \"" message "\"\n") printList "" failProc] when
  ];} () spawn;

  writeContext: {connection: @client; CALL: [
    result: String;

    connection.connection fillUpSocketSendBuffer
    "Hello, World!" @connection.write !result
    result "" = ~ [("TcpConnection.write failed, " result LF) printList "" failProc] when
  ];} () spawn;

  yield
  @readContext.cancel
] call

# Test that read does not block when write is canceled on the same fd
[
  server: client: 0x7F000001n32 6600n16 getServerAndClientContexts .get; .get;

  readContext: {connection: @client; CALL: [
    result: String;

    message: 1024 @connection.readString !result;
    result "" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "Hello, World!" = ~ [("client received unexpected response, \"" message "\"\n") printList "" failProc] when
  ];} () spawn;

  writeContext: {connection: @client; CALL: [
    result: String;

    connection.connection fillUpSocketSendBuffer
    "Hello, World!" @connection.write !result
    result "canceled" = ~ [("TcpConnection.write failed, " result LF) printList "" failProc] when
  ];} () spawn;

  yield
  @writeContext.cancel

  result: "Hello, World!" @server.write;
  result "" = ~ [("TcpConnection.write failed, " result LF) printList "" failProc] when
] call

# Test that on cancel before resuming nothing is read from the socket buffer; fails on Windows
[
  server: client: 0x7F000001n32 6600n16 getServerAndClientContexts .get; .get;

  readContext: {connection: @client; CALL: [
    result: String;

    message: 1 @connection.readString !result;
    result "canceled" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "" = ~ [("client received unexpected response, \"" message "\"\n") printList "" failProc] when
  ];} () spawn;

  yield

  cancelContext: {context: @readContext; CALL: [
    @context.cancel
  ];} () spawn;

  result: "Hello, World!" @server.write;
  result "" = ~ [("TcpConnection.write failed, " result LF) printList "" failProc] when

  @cancelContext.wait
  @readContext  .wait

  message: 1024 @client.readString !result;
  result "" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
  message "Hello, World!" = ~ [("client received unexpected response, \"" message "\"\n") printList "" failProc] when
] call

# Test asyncRead waits input non-blocking
(
  "Hello"          # smaller than bufferSize
  "Hello, World!"  # larger than buggerSize
) [
  message:;
  messageSize: message textSize Int32 cast;
  bufferSize: 10;
  expectedMessage: 0 bufferSize messageSize min message toString.slice;
  pipefd: {in: Int32; out: Int32;};
  @pipefd pipe 0 = ~ [("failed to create pipe, result=" errno LF) printList "" failProc] when
  readyToRead: FALSE;

  context: {
    readfd:          pipefd.in;
    bufferSize:      bufferSize;
    expectedMessage: expectedMessage;
    readyToRead:     @readyToRead;
    CALL: [
      buffer: String;
      bufferSize @buffer.resize
      TRUE @readyToRead set
      readCount: buffer.size Natx cast buffer.data storageAddress readfd asyncRead;
      FALSE @readyToRead set
      message: 0 readCount Int32 cast buffer.slice;
      message expectedMessage = ~ [("received unexpected message, \"" message "\"" LF) printList "" failProc] when
    ];
  } () spawn;
  readyToRead FALSE = ~ [("client was not expected to be started" LF) printList "" failProc] when
  yield
  readyToRead TRUE = ~ [("client is expected to be ready" LF) printList "" failProc] when
  pipefd.out message writeText
  @context.wait
  readyToRead FALSE = ~ [("expected fiber to already read message" LF) printList "" failProc] when
] each

