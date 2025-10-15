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
"control.&&"            use
"control.Cref"          use
"control.Int32"         use
"control.Nat16"         use
"control.Nat32"         use
"control.Nat64"         use
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
"posix.timespec"        use
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
"macos.EVFILT_READ"   use
"macos.EVFILT_WRITE"  use
"macos.EV_ADD"        use
"macos.EV_ONESHOT"    use
"macos.kevent"        use
"macos.struct_kevent" use

"objectTools.formatObject" use

"syncPrivate.FiberData"         use
"syncPrivate.FiberPair"         use
"syncPrivate.canceled?"         use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use
"syncPrivate.kqueue_fd"         use
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

          isReadWrite: fiberPair.writeFiber nil? ~;
          nEvents: isReadWrite [2] [1] if;

          connectionEvents: struct_kevent 2 array;

          readEvent: 0 @connectionEvents @;
          fiberPair storageAddress Nat64 cast @readEvent.@udata set
          connection Nat64 cast @readEvent.!ident
          EVFILT_READ @readEvent.@filter set
          EV_ONESHOT @readEvent.@flags set

          isReadWrite [
            writeEvent: 1 @connectionEvents @;
            fiberPair storageAddress Nat64 cast @writeEvent.@udata set
            connection Nat64 cast @writeEvent.!ident
            EVFILT_WRITE @writeEvent.@filter set
            EV_ONESHOT @writeEvent.@flags set
          ] when

          timespec Ref 0n32 0 struct_kevent Ref nEvents connectionEvents storageAddress struct_kevent addressToReference kqueue_fd kevent -1 = [("kevent failed, result=" errno) @result.catMany] when
          "control.Nat32" use
        ] [
          context: {
            connection: connection new;
            fiberPair:  @fiberPair;
          };

          context storageAddress [
            context:   @context addressToReference;
            fiberPair: @context.@fiberPair;

            connectionEvent: struct_kevent;

            context.connection Nat64 cast @connectionEvent.!ident
            fiberPair.writeFiber nil? ~ [
              EVFILT_WRITE @connectionEvent.@filter set
              EV_ONESHOT @connectionEvent.@flags set
              fiberPair storageAddress Nat64 cast @connectionEvent.@udata set
            ] when

            timespec Ref 0n32 0 struct_kevent Ref 1 connectionEvent kqueue_fd kevent -1 = [("FATAL: kevent failed, result=" errno LF) printList "" failProc] when

            @fiberPair.@readFiber @resumingFibers.append
          ] @currentFiber.setFunc

          dispatch
          FiberData Ref @fiberPair.!readFiber
          canceled? ["canceled" @result.cat] when
        ] [
          @defaultCancelFunc @currentFiber.!func

          fiberPair.writeFiber nil? ~ [
            connectionEvent: struct_kevent;

            connection Nat64 cast @connectionEvent.!ident
            EVFILT_WRITE @connectionEvent.@filter set
            EV_ONESHOT @connectionEvent.@flags set
            fiberPair storageAddress Nat64 cast @connectionEvent.@udata set

            timespec Ref 0n32 0 struct_kevent Ref 1 connectionEvent kqueue_fd kevent -1 = [("kevent failed, result=" errno) @result.catMany] when
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

    sentByteCount: 0ix;
    canceled? ["canceled" @result.cat] [
      MSG_NOSIGNAL Int32 cast data.size Natx cast data.data storageAddress connection send !sentByteCount
    ] if

    sentByteCount -1ix = [
      (
        [result "" =] [
          lastErrorNumber: errno;
          lastErrorNumber EAGAIN = ~ [lastErrorNumber EWOULDBLOCK = ~] && [("send failed, result=" lastErrorNumber) @result.catMany] when
        ] [
          @currentFiber @fiberPair.!writeFiber

          isReadWrite: fiberPair.readFiber nil? ~;
          nEvents: isReadWrite [2] [1] if;

          connectionEvents: struct_kevent 2 array;

          writeEvent: 0 @connectionEvents @;
          fiberPair storageAddress Nat64 cast @writeEvent.@udata set
          connection Nat64 cast @writeEvent.!ident
          EVFILT_READ @writeEvent.@filter set
          EV_ONESHOT @writeEvent.@flags set

          isReadWrite [
            readEvent: 1 @connectionEvents @;
            fiberPair storageAddress Nat64 cast @readEvent.@udata set
            connection Nat64 cast @readEvent.!ident
            EVFILT_WRITE @readEvent.@filter set
            EV_ONESHOT @readEvent.@flags set
          ] when

          timespec Ref 0n32 0 struct_kevent Ref nEvents connectionEvents storageAddress struct_kevent addressToReference kqueue_fd kevent -1 = [("kevent failed, result=" errno) @result.catMany] when
        ] [
          context: {
            connection: connection new;
            fiberPair:  @fiberPair;
          };

          context storageAddress [
            context:   @context addressToReference;
            fiberPair: @context.@fiberPair;

            connectionEvent: struct_kevent;
            context.connection Nat64 cast @connectionEvent.!ident
            fiberPair.readFiber nil? ~ [
              EVFILT_READ @connectionEvent.@filter set
              fiberPair storageAddress Nat64 cast @connectionEvent.@udata set
              EV_ONESHOT @connectionEvent.@flags set
            ] when

            timespec Ref 0n32 0 struct_kevent Ref 1 connectionEvent kqueue_fd kevent -1 = [("FATAL: kevent failed, result=" errno LF) printList "" failProc] when

            @fiberPair.@writeFiber @resumingFibers.append
          ] @currentFiber.setFunc

          dispatch
          FiberData Ref @fiberPair.!writeFiber
          canceled? ["canceled" @result.cat] when
        ] [
          @defaultCancelFunc @currentFiber.!func

          fiberPair.readFiber nil? ~ [
            connectionEvent: struct_kevent;
            connection Nat64 cast @connectionEvent.!ident
            EVFILT_READ @connectionEvent.@filter set
            fiberPair storageAddress Nat64 cast @connectionEvent.@udata set

            timespec Ref 0n32 0 struct_kevent Ref 1 connectionEvent kqueue_fd kevent -1 = [("kevent failed, result=" errno) @result.catMany] when
          ] when
        ] [
          0 data.size Natx cast data.data storageAddress connection send !sentByteCount
          sentByteCount -1ix = [("send failed, result=" errno) @result.catMany] when
        ] [
          [sentByteCount Int32 cast data.size =] "wrong transferred size" assert
        ]
      ) sequence
    ] when

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
        O_NONBLOCK Nat32 cast flags Nat32 cast or Int32 cast @flags set
        (flags new) F_SETFL connection.connection fcntl -1 =
      ] || [("fcntl failed, result=" errno) @result.catMany] when
    ] [
      addressData: sockaddr_in;
      AF_INET Nat8 cast  @addressData.!sin_family
      port    htons      @addressData.!sin_port
      address htonl      @addressData.!sin_addr

      addressData storageSize Nat32 cast addressData storageAddress sockaddr addressToReference connection.connection connect 0 = ~ [
        ("connect failed, result=" errno) @result.catMany
      ] when
    ] [
      fiberPair: FiberPair;
      @currentFiber @fiberPair.!writeFiber

      connectEvent: struct_kevent;

      connection.connection Nat64 cast @connectEvent.!ident
      EVFILT_WRITE @connectEvent.@filter set
      EV_ADD EV_ONESHOT or @connectEvent.@flags set

      fiberPair storageAddress Nat64 cast @connectEvent.@udata set

      (connectEvent {} formatObject LF "kqueue_fd: " kqueue_fd LF) printList

      timespec Ref 0n32 0 struct_kevent Ref 1 connectEvent kqueue_fd kevent -1 = [("kevent failed, result=" errno) @result.catMany] when
    ] [
      context: {
        connection: connection.connection new;
        fiber:      @currentFiber;
        connEvent:  struct_kevent;
      };

      connection.connection Nat64 cast @context.@connEvent.!ident

      context storageAddress [
        context: @context addressToReference;

        timespec Ref 0n32 0 struct_kevent Ref 1 context.connEvent kqueue_fd kevent -1 = [("kevent failed, result=" errno) printList "" failProc] when

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
      retVal 0 = ~ [("connect failed, result=" retVal) @result.catMany] when
    ]
  ) sequence

  result "" = ~ [TcpConnection !connection] when

  @connection @result
];
