"String.String" use
"String.printList" use
"control.=" use
"control.ensure" use
"control.failProc" use
"control.when" use

"sync/sync.connectTcp" use
"sync/sync.ipv4ToString" use
"sync/sync.listenTcp" use
"sync/sync.spawn" use

syncTest: [];

[
  [0xC0A86465n32 ipv4ToString "192.168.100.101" =] "ipv4ToString returned unexpected string" ensure
] call

[
  client: [
    result: String;
    connection: 0x7F000001n32 6600n16 connectTcp !result;
    result "" = ~ [("connectTcp failed, " result LF) printList "" failProc] when

    "Hello, world!" connection.writeString !result
    result "" = ~ [("TcpConnection.writeString failed, " result LF) printList "" failProc] when

    message: 1024 connection.readString !result;
    result "" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "Reply: Hello, world!" = ~ [("client received unexpected response, \"" message "\"\n") printList "" failProc] when

    connection.shutdown !result
    result "" = ~ [("TcpConnection.shutdown failed, " result LF) printList "" failProc] when

    message: 1024 connection.readString !result;
    result "closed" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "" = ~ [("client received invalid response, \"" message "\"\n") printList "" failProc] when
  ];

  server: [
    result: String;
    acceptor: 0x7F000001n32 6600n16 listenTcp !result;
    result "" = ~ [("listenTcp failed, " result LF) printList "" failProc] when

    connection: address: acceptor.accept !result;;
    result "" = ~ [("TcpAcceptor.accept failed, " result LF) printList "" failProc] when
    address 0x7F000001n32 = ~ [("TcpAcceptor.accept returned unexpected address, " address ipv4ToString LF) printList "" failProc] when

    message: 1024 connection.readString !result;
    result "" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "Hello, world!" = ~ [("server received unexpected request, \"" message "\"\n") printList "" failProc] when

    "Reply: Hello, world!" connection.writeString !result
    result "" = ~ [("TcpConnection.writeString failed, " result LF) printList "" failProc] when

    message: 1024 connection.readString !result;
    result "closed" = ~ [("TcpConnection.readString failed, " result LF) printList "" failProc] when
    message "" = ~ [("server received invalid request, \"" message "\"\n") printList "" failProc] when

    connection.shutdown !result
    result "" = ~ [("TcpConnection.shutdown failed, " result LF) printList "" failProc] when
  ];

  clientContext: @client () spawn;
  serverContext: @server () spawn;
] call
