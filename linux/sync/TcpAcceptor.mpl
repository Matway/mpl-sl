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
"control.Nat16"    use
"control.Nat32"    use
"control.Ref"      use
"control.assert"   use
"control.failProc" use
"control.sequence" use
"control.when"     use
"control.||"       use

"posix.O_NONBLOCK"      use
"posix.close"           use
"posix.fcntl"           use
"socket.AF_INET"        use
"socket.F_GETFL"        use
"socket.F_SETFL"        use
"socket.INVALID_SOCKET" use
"socket.IPPROTO_TCP"    use
"socket.SOCK_STREAM"    use
"socket.SOL_SOCKET"     use
"socket.SOMAXCONN"      use
"socket.SO_REUSEADDR"   use
"socket.TCP_NODELAY"    use
"socket.bind"           use
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
"linux.EPOLLIN"       use
"linux.EPOLLONESHOT"  use
"linux.EPOLL_CTL_ADD" use
"linux.EPOLL_CTL_MOD" use
"linux.epoll_ctl"     use
"linux.epoll_event"   use

"TcpConnection.TcpConnection"   use
"syncPrivate.FiberPair"         use
"syncPrivate.canceled?"         use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use
"syncPrivate.epoll_fd"          use
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

    address:    Nat32;
    connection: TcpConnection;
    result:     String;

    (
      [result "" =] [
        canceled? ["canceled" @result.cat] when
      ] [
        fiberPair: FiberPair;
        @currentFiber @fiberPair.!readFiber

        listenEvent: epoll_event;
        EPOLLIN EPOLLONESHOT or  @listenEvent.!events
        fiberPair storageAddress @listenEvent.ptr set

        @listenEvent acceptor EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
      ] [
        acceptContext: {
          acceptor: acceptor new;
          fiber:    @currentFiber;
        };

        AcceptContextType: @acceptContext Ref virtual;
        acceptContext storageAddress [
          acceptContext: @AcceptContextType addressToReference;

          epoll_event acceptContext.acceptor EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("FATAL: epoll_ctl failed, result=" errno LF) printList "" failProc] when

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
          (flags new) F_SETFL connection.connection fcntl -1 =
        ] || [("fcntl failed, result=" errno) @result.catMany] when
      ] [
        nodelay: 1;
        nodelay storageSize Nat32 cast nodelay storageAddress TCP_NODELAY IPPROTO_TCP connection.connection setsockopt -1 = [("setsockopt failed, result=" errno) @result.catMany] when
      ] [
        epoll_event connection.connection EPOLL_CTL_ADD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
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
      AF_INET Nat16 cast @addressData.!sin_family
      port    htons      @addressData.!sin_port
      address htonl      @addressData.!sin_addr

      addressData storageSize Nat32 cast addressData storageAddress sockaddr addressToReference acceptor.acceptor bind 0 = ~ [("bind failed, result=" errno) @result.catMany] when
    ] [
      SOMAXCONN acceptor.acceptor listen 0 = ~ [("listen failed, result=" errno) @result.catMany] when
    ] [
      epoll_event acceptor.acceptor EPOLL_CTL_ADD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
    ]
  ) sequence

  result "" = ~ [TcpAcceptor !acceptor] when

  @acceptor @result
];
