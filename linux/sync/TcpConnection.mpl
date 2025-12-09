# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Span.toSpan"           use
"String.String"         use
"String.assembleString" use
"String.printList"      use
"algorithm.="           use
"algorithm.all"         use
"algorithm.unhead"      use
"control.&&"            use
"control.Cref"          use
"control.Int32"         use
"control.Nat16"         use
"control.Nat32"         use
"control.Nat8"          use
"control.Natx"          use
"control.Ref"           use
"control.assert"        use
"control.drop"          use
"control.failProc"      use
"control.nil?"          use
"control.sequence"      use
"control.when"          use
"control.||"            use

"posix.EAGAIN"          use
"posix.EINPROGRESS"     use
"posix.EWOULDBLOCK"     use
"posix.O_NONBLOCK"      use
"posix.close"           use
"posix.fcntl"           use
"socket.AF_INET"        use
"socket.F_GETFL"        use
"socket.F_SETFL"        use
"socket.INVALID_SOCKET" use
"socket.IPPROTO_TCP"    use
"socket.MSG_NOSIGNAL"   use
"socket.SHUT_WR"        use
"socket.SOCK_STREAM"    use
"socket.SOL_SOCKET"     use
"socket.SO_ERROR"       use
"socket.TCP_NODELAY"    use
"socket.connect"        use
"socket.getsockopt"     use
"socket.htonl"          use
"socket.htons"          use
"socket.recv"           use
"socket.send"           use
"socket.setsockopt"     use
"socket.sockaddr"       use
"socket.sockaddr_in"    use
"socket.socket"         use
"socket.socklen_t"      use

"errno.errno"         use
"linux.EPOLLIN"       use
"linux.EPOLLONESHOT"  use
"linux.EPOLLOUT"      use
"linux.EPOLL_CTL_ADD" use
"linux.EPOLL_CTL_MOD" use
"linux.epoll_ctl"     use
"linux.epoll_event"   use

"syncPrivate.FiberData"         use
"syncPrivate.FiberPair"         use
"syncPrivate.canceled?"         use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use
"syncPrivate.epoll_fd"          use
"syncPrivate.resumingFibers"    use

TcpConnection: [{
  INIT: [INVALID_SOCKET !connection];

  DIE: [
    valid? [
      connection close 0 = ~ [("LEAK: close failed, result=" errno LF) printList "" failProc] when
    ] when
  ];

  valid?: [connection INVALID_SOCKET = ~];

  # Read data
  # in:
  #   data (Nat8 Span) - buffer to read into
  # out:
  #   size (Int32) - size of the actual data
  #   result (String) - empty on success, error message on failure
  read: [
    data: toSpan;
    [valid?]                   "invalid TcpConnection"                     assert
    [fiberPair.readFiber nil?] "attempted to read data by multiple fibers" assert
    (@data.data) (Nat8 Ref) same ~ [data printStack drop "[TcpConnection.read], invalid argument, [Nat8 Span] expected" raiseStaticError] when
    size:   0;
    result: String;

    recievedByteCount: 0ix;
    canceled? ["canceled" @result.cat] [
      0 data.size Natx cast data.data storageAddress connection recv !recievedByteCount
    ] if

    recievedByteCount -1ix = [
      (
        [result "" =] [
          lastErrorNumber: errno;
          lastErrorNumber EAGAIN = ~ [lastErrorNumber EWOULDBLOCK = ~] && [("recv failed, result=" lastErrorNumber) @result.catMany] when
        ] [
          @currentFiber @fiberPair.!readFiber

          connectionEvent: epoll_event;
          fiberPair storageAddress @connectionEvent.ptr set

          fiberPair.writeFiber nil? ~ [
            EPOLLIN EPOLLOUT or EPOLLONESHOT or @connectionEvent.!events
          ] [
            EPOLLIN EPOLLONESHOT or @connectionEvent.!events
          ] if

          @connectionEvent connection EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
        ] [
          context: {
            connection: connection new;
            fiberPair:  @fiberPair;
          };

          ContextType: @context Ref virtual;
          context storageAddress [
            context:   @ContextType addressToReference;
            fiberPair: @context.@fiberPair;

            connectionEvent: epoll_event;
            fiberPair.writeFiber nil? ~ [
              EPOLLOUT EPOLLONESHOT or @connectionEvent.!events
              fiberPair storageAddress @connectionEvent.ptr set
            ] when

            @connectionEvent context.connection EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("FATAL: epoll_failed failed, result=" errno LF) printList "" failProc] when

            @fiberPair.@readFiber @resumingFibers.append
          ] @currentFiber.setFunc

          dispatch
          FiberData Ref @fiberPair.!readFiber
          canceled? ["canceled" @result.cat] when
        ] [
          @defaultCancelFunc @currentFiber.!func

          fiberPair.writeFiber nil? ~ [
            connectionEvent: epoll_event;
            EPOLLOUT EPOLLONESHOT or @connectionEvent.!events
            fiberPair storageAddress @connectionEvent.ptr set

            @connectionEvent connection EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
          ] when
        ] [
          0 data.size Natx cast data.data storageAddress connection recv !recievedByteCount
          recievedByteCount -1ix = [("recv failed, result=" errno) @result.catMany] when
        ]
      ) sequence
    ] when

    result "" = [
      recievedByteCount 0ix = ["closed" @result.cat] [recievedByteCount Int32 cast !size] if
    ] when

    @size @result
  ];

  readString: [
    [valid?] "invalid TcpConnection" assert
    string: String; @string.resize
    result: @string read; @string.resize
    @string @result
  ];

  shutdown: [
    [valid?] "invalid TcpConnection" assert

    "socket.shutdown" use

    SHUT_WR connection shutdown 0 = [String] [("shutdown failed, result=" errno) assembleString] if
  ];

  # Write data
  # in:
  #   data (Nat8 Cref Span) - buffer to write
  # out:
  #   result (String) - empty on success, error message on failure
  write: [
    data: toSpan;
    [valid?]                    "invalid TcpConnection"                      assert
    [fiberPair.writeFiber nil?] "attempted to write data by multiple fibers" assert
    (data.data) (Nat8 Cref) same ~ [data printStack drop "[TcpConnection.write], invalid argument, [Nat8 Cref Span] expected" raiseStaticError] when

    result: String;

    canceled? ~ [
      @currentFiber @fiberPair.!writeFiber

      [
        sentByteCount: MSG_NOSIGNAL Int32 cast data.size Natx cast data.data storageAddress connection send;
        sentByteCount -1ix = ~ [
          data sentByteCount Int32 cast unhead !data
          TRUE
        ] [
          (
            [
              lastErrorNumber: errno;
              lastErrorNumber EAGAIN = ~ [lastErrorNumber EWOULDBLOCK = ~] && [("send failed, result=" lastErrorNumber) @result.catMany] when
            ] [
              connectionEvent: epoll_event;
              fiberPair storageAddress @connectionEvent.ptr set

              fiberPair.readFiber nil? ~ [
                EPOLLIN EPOLLOUT or EPOLLONESHOT or @connectionEvent.!events
              ] [
                EPOLLOUT EPOLLONESHOT or @connectionEvent.!events
              ] if

              @connectionEvent connection EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
            ] [
              context: {
                connection: connection new;
                fiberPair:  @fiberPair;
              };

              ContextType: @context Ref virtual;
              context storageAddress [
                context:   @ContextType addressToReference;
                fiberPair: @context.@fiberPair;

                connectionEvent: epoll_event;
                fiberPair.readFiber nil? ~ [
                  EPOLLIN EPOLLONESHOT or  @connectionEvent.!events
                  fiberPair storageAddress @connectionEvent.ptr set
                ] when

                @connectionEvent context.connection EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("FATAL: epoll_failed failed, result=" errno LF) printList "" failProc] when

                @fiberPair.@writeFiber @resumingFibers.append
              ] @currentFiber.setFunc

              dispatch
              canceled? ["canceled" @result.cat] when
            ] [
              @defaultCancelFunc @currentFiber.!func

              fiberPair.readFiber nil? ~ [
                connectionEvent: epoll_event;
                EPOLLIN EPOLLONESHOT or  @connectionEvent.!events
                fiberPair storageAddress @connectionEvent.ptr set

                @connectionEvent connection EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
              ] when
            ]
          ) [call result "" =] all
        ] if [data.size 0 = ~] &&
      ] loop

      FiberData Ref @fiberPair.!writeFiber
    ] ["canceled" @result.cat] if

    [result "" = ~ [data.size 0 =] ||] "wrong transferred size on no error" assert

    @result
  ];

  connection: INVALID_SOCKET;
  fiberPair:  FiberPair;
}];

makeTcpConnection: [
  address: port:;;
  connection: TcpConnection;
  result:     String;

  (
    [result "" =] [
      canceled? ["canceled" @result.cat] when
    ] [
      IPPROTO_TCP SOCK_STREAM AF_INET socket @connection.!connection
      connection.valid? ~ ["socket failed, result=" @result.cat] when
    ] [
      nodelay: 1;
      nodelay storageSize Nat32 cast nodelay storageAddress TCP_NODELAY IPPROTO_TCP connection.connection setsockopt -1 = [("setsockopt failed, result=" errno) @result.catMany] when
    ] [
      flags: (0) F_GETFL connection.connection fcntl;
      flags -1 = [
        O_NONBLOCK Nat32 cast flags Nat32 cast or Int32 cast !flags
        (flags new) F_SETFL connection.connection fcntl -1 =
      ] || [("fcntl failed, result=" errno) @result.catMany] when
    ] [
      addressData: sockaddr_in;
      AF_INET Nat16 cast @addressData.!sin_family
      port    htons      @addressData.!sin_port
      address htonl      @addressData.!sin_addr

      addressData storageSize Nat32 cast addressData storageAddress sockaddr addressToReference connection.connection connect 0 = [("connect returned immediately") @result.catMany] when
    ] [
      lastErrorNumber: errno;
      lastErrorNumber EINPROGRESS = ~ [("connect failed, result=" lastErrorNumber) @result.catMany] when
    ] [
      fiberPair: FiberPair;
      @currentFiber @fiberPair.!writeFiber

      connectEvent: epoll_event;
      EPOLLOUT EPOLLONESHOT or @connectEvent.!events
      fiberPair storageAddress @connectEvent.ptr set

      @connectEvent connection.connection EPOLL_CTL_ADD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno) @result.catMany] when
    ] [
      context: {
        connection: connection.connection new;
        fiber:      @currentFiber;
      };
      ContextType: @context Ref virtual;

      context storageAddress [
        context: @ContextType addressToReference;

        epoll_event context.connection EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("epoll_ctl failed, result=" errno LF) printList "" failProc] when

        @context.@fiber @resumingFibers.append
      ] @currentFiber.setFunc

      dispatch
      canceled? ["canceled" @result.cat] when
    ] [
      @defaultCancelFunc @currentFiber.!func

      retVal:    -1;
      retValLen: retVal storageSize;
      retValLen storageAddress socklen_t addressToReference retVal storageAddress SO_ERROR SOL_SOCKET connection.connection getsockopt -1 = [("getsockopt failed, result=" errno) @result.catMany] when
    ] [
      retVal 0 = ~ [("connect failed, result=" retVal) @result.catMany] when
    ]
  ) sequence

  result "" = ~ [TcpConnection !connection] when

  @connection @result
];
