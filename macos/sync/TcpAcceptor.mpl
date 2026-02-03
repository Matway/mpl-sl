# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.String"    use
"String.printList" use
"algorithm.="      use
"control.Int32"    use
"control.Nat32"    use
"control.Nat64"    use
"control.Nat8"     use
"control.Ref"      use
"control.assert"   use
"control.failProc" use
"control.sequence" use
"control.when"     use
"control.||"       use

"posix.EINVAL"          use
"posix.O_NONBLOCK"      use
"posix.close"           use
"posix.fcntl"           use
"posix.timespec"        use
"socket.AF_INET"        use
"socket.F_GETFL"        use
"socket.F_SETFL"        use
"socket.INVALID_SOCKET" use
"socket.IPPROTO_TCP"    use
"socket.SOCK_STREAM"    use
"socket.SOL_SOCKET"     use
"socket.SOMAXCONN"      use
"socket.SO_ERROR"       use
"socket.SO_REUSEADDR"   use
"socket.TCP_NODELAY"    use
"socket.bind"           use
"socket.getsockopt"     use
"socket.htonl"          use
"socket.htons"          use
"socket.listen"         use
"socket.ntohl"          use
"socket.setsockopt"     use
"socket.sockaddr"       use
"socket.sockaddr_in"    use
"socket.socket"         use
"socket.socklen_t"      use

"errno.errno"         use
"macos.EVFILT_READ"   use
"macos.EVFILT_WRITE"  use
"macos.EV_ADD"        use
"macos.EV_ENABLE"     use
"macos.EV_ONESHOT"    use
"macos.kevent"        use
"macos.struct_kevent" use

"TcpConnection.TcpConnection"   use
"syncPrivate.FiberData"         use
"syncPrivate.FiberPair"         use
"syncPrivate.canceled?"         use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use
"syncPrivate.kqueue_fd"         use
"syncPrivate.resumingFibers"    use

TcpAcceptor: [{
  INIT: [INVALID_SOCKET !acceptor];

  DIE: [
    valid? [
      acceptor close 0 = ~ [("FATAL: close failed, result=" errno LF) printList "" failProc] when
    ] when
  ];

  valid?: [acceptor INVALID_SOCKET = ~];

  # Accept connection
  # in:
  #   NONE
  # out:
  #   connection (TcpConnection) - accepted connection
  #   address (Nat32) - remote IPv4 address
  #   result (String) - empty on success, error message on failure
  accept: [
    [valid?] "invalid TcpAcceptor" assert

    address:     Nat32;
    connection:  TcpConnection;
    result:      String;
    listenEvent: struct_kevent;
    writeEvent:  struct_kevent;

    (
      [result "" =] [
        canceled? ["canceled" @result.cat] when
      ] [
        fiberPair: FiberPair;
        @currentFiber @fiberPair.!readFiber

        EVFILT_READ @listenEvent.@filter set
        EV_ONESHOT EV_ADD or @listenEvent.@flags set
        fiberPair storageAddress Nat64 cast @listenEvent.@udata set
        acceptor Nat64 cast @listenEvent.!ident

        timespec Ref 0n32 0 struct_kevent Ref 1 listenEvent kqueue_fd kevent -1 = [("[accept] kevent failed, result=" errno) @result.catMany] when
      ] [
        acceptContext: {
          acceptor: acceptor new;
          fiber:    @currentFiber;
          le: @listenEvent new;
        };
        acceptContext storageAddress [
          acceptContext: @acceptContext addressToReference;

          acceptContext.acceptor Nat64 cast @acceptContext.@le.!ident
          # Ignore EINVAL - socket may be already closed during cleanup
          timespec Ref 0n32 0 struct_kevent Ref 1 acceptContext.le kqueue_fd kevent -1 = [
            lastErrorNumber: errno;
            lastErrorNumber EINVAL = ~ [
              ("FATAL: [accept] kevent failed, result=" lastErrorNumber LF) printList "" failProc
            ] when
          ] when

          @acceptContext.@fiber @resumingFibers.append
        ] @currentFiber.setFunc

        dispatch
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func

        "socket.accept" use

        remoteAddress: sockaddr;
        addressSize:   remoteAddress storageSize;
        addressSize storageAddress socklen_t addressToReference @remoteAddress acceptor accept @connection.!connection

        connection.connection -1 = [("accept failed, result=" errno) @result.catMany] when
      ] [
        flags: (0) F_GETFL connection.connection fcntl;
        flags -1 = [
          O_NONBLOCK Nat32 cast flags Nat32 cast or Int32 cast !flags
          (O_NONBLOCK Int32 cast) F_SETFL connection.connection fcntl -1 =
        ] || [("fcntl failed, result=" errno) @result.catMany] when
      ] [
        nodelay: 1;
        nodelay storageSize Nat32 cast nodelay storageAddress TCP_NODELAY IPPROTO_TCP connection.connection setsockopt -1 = [("setsockopt failed, result=" errno) @result.catMany] when
      ] [
        fiberPair: FiberPair;
        @currentFiber @fiberPair.!writeFiber

        connectEvent: struct_kevent;

        connection.connection Nat64 cast @connectEvent.!ident
        EVFILT_WRITE @connectEvent.@filter set
        EV_ADD EV_ONESHOT or @connectEvent.@flags set

        fiberPair storageAddress Nat64 cast @connectEvent.@udata set

        timespec Ref 0n32 0 struct_kevent Ref 1 connectEvent kqueue_fd kevent -1 = [("[accept] kevent failed, result=" errno) @result.catMany] when
      ] [
        context: {
          connection: connection.connection new;
          fiber:      @currentFiber;
          connEvent:  struct_kevent;
        };

        connection.connection Nat64 cast @context.@connEvent.!ident

        context storageAddress [
          context: @context addressToReference;

          timespec Ref 0n32 0 struct_kevent Ref 1 context.connEvent kqueue_fd kevent -1 = [("[accept] kevent failed, result=" errno) printList "" failProc] when

          @context.@fiber @resumingFibers.append
        ] @currentFiber.setFunc

        dispatch
        FiberData Ref @fiberPair.!readFiber
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func

        retVal:    -1;
        retValLen: retVal storageSize;
        retValLen storageAddress socklen_t addressToReference retVal storageAddress SO_ERROR SOL_SOCKET connection.connection getsockopt -1 = [("getsockopt failed, result=" errno) @result.catMany] when
      ] [
        remoteAddress storageAddress sockaddr_in addressToReference .sin_addr ntohl !address
      ]
    ) sequence

    result "" = ~ [TcpConnection !connection] when

    @connection @address @result
  ];

  acceptor: INVALID_SOCKET;
}];

makeTcpAcceptor: [
  address: port:;;
  acceptor: TcpAcceptor;
  result:   String;

  (
    [result "" =] [
      canceled? ["canceled" @result.cat] when
    ] [
      IPPROTO_TCP SOCK_STREAM AF_INET socket @acceptor.!acceptor
      acceptor.valid? ~ [("socket failed, result=" errno) @result.catMany] when
    ] [
      flags: (0) F_GETFL acceptor.acceptor fcntl;
      flags -1 = [
        flags Nat32 cast O_NONBLOCK Nat32 cast or Int32 cast !flags
        (flags new) F_SETFL acceptor.acceptor fcntl -1 =
      ] || [("fcntl failed, result=" errno) @result.catMany] when
    ] [
      nodelay: 1;
      nodelay storageSize Nat32 cast nodelay storageAddress TCP_NODELAY IPPROTO_TCP acceptor.acceptor setsockopt -1 = [("setsockopt failed, result=" errno) @result.catMany] when
    ] [
      reuseAddrEnable: 1;
      reuseAddrEnable storageSize Nat32 cast reuseAddrEnable storageAddress SO_REUSEADDR SOL_SOCKET acceptor.acceptor setsockopt -1 = [("setsockopt failed, result=" errno) @result.catMany] when
    ] [
      addressData: sockaddr_in;
      AF_INET Nat8 cast @addressData.!sin_family
      port    htons      @addressData.!sin_port
      address htonl      @addressData.!sin_addr

      addressData storageSize Nat32 cast addressData storageAddress sockaddr addressToReference acceptor.acceptor bind 0 = ~ [("bind failed, result=" errno) @result.catMany] when
    ] [
      SOMAXCONN acceptor.acceptor listen 0 = ~ [("listen failed, result=" errno) @result.catMany] when
    ]
  ) sequence

  result "" = ~ [TcpAcceptor !acceptor] when

  @acceptor @result
];
