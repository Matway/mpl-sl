# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Span.toSpan"           use
"String.String"         use
"String.assembleString" use
"String.makeStringView" use
"String.printList"      use
"algorithm.="           use
"control.AsRef"         use
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
"control.isNil"         use
"control.sequence"      use
"control.when"          use

"kernel32.CancelIoEx"                        use
"kernel32.CreateIoCompletionPort"            use
"kernel32.ERROR_NOT_FOUND"                   use
"kernel32.GetLastError"                      use
"kernel32.OVERLAPPED"                        use
"ws2_32.AF_INET"                             use
"ws2_32.FN_CONNECTEXRef"                     use
"ws2_32.INADDR_ANY"                          use
"ws2_32.INVALID_SOCKET"                      use
"ws2_32.IPPROTO_TCP"                         use
"ws2_32.SD_SEND"                             use
"ws2_32.SIO_GET_EXTENSION_FUNCTION_POINTER"  use
"ws2_32.SOCK_STREAM"                         use
"ws2_32.SOL_SOCKET"                          use
"ws2_32.SO_UPDATE_CONNECT_CONTEXT"           use
"ws2_32.TCP_NODELAY"                         use
"ws2_32.WSAGetLastError"                     use
"ws2_32.WSAGetOverlappedResult"              use
"ws2_32.WSAID_CONNECTEX"                     use
"ws2_32.WSAIoctl"                            use
"ws2_32.WSAOVERLAPPED_COMPLETION_ROUTINERef" use
"ws2_32.WSARecv"                             use
"ws2_32.WSASend"                             use
"ws2_32.WSA_IO_PENDING"                      use
"ws2_32.bind"                                use
"ws2_32.closesocket"                         use
"ws2_32.htonl"                               use
"ws2_32.htons"                               use
"ws2_32.setsockopt"                          use
"ws2_32.sockaddr_in"                         use
"ws2_32.socket"                              use

"syncPrivate.FiberData"         use
"syncPrivate.canceled?"         use
"syncPrivate.completionPort"    use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use

TcpConnection: [{
  INIT: [INVALID_SOCKET !connection];

  DIE: [
    valid? [
      connection closesocket 0 = ~ [("FATAL: closesocket failed, result=" WSAGetLastError LF) printList "" failProc] when
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
    [valid?] "invalid TcpConnection" assert
    (@data.data) (Nat8 Ref) same ~ [data printStack drop "[TcpConnection.read], invalid argument, [Nat8 Span] expected" raiseStaticError] when
    size: 0;
    result: String;

    (
      [result "" =] [
        canceled? ["canceled" @result.cat] when
      ] [
        context: {
          overlapped: OVERLAPPED;
          fiber: FiberData Ref;
          connection: Natx;
        };

        WSAOVERLAPPED_COMPLETION_ROUTINERef @context.@overlapped Nat32 Nat32 Ref 1n32 {len: data.size Nat32 cast; buf: data.data storageAddress;} connection WSARecv 0 = ~ [
          lastError: WSAGetLastError;
          lastError WSA_IO_PENDING = ~ [("WSARecv failed, result=" lastError) @result.catMany] when
        ] when
      ] [
        @currentFiber @context.!fiber
        connection new @context.!connection
        context storageAddress [
          context: @context addressToReference;
          @context.@overlapped context.connection CancelIoEx 1 = ~ [
            lastError: GetLastError;
            lastError ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
          ] when
        ] @currentFiber.setFunc

        dispatch
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func
        transferred: 0n32;
        Nat32 0 @transferred @context.@overlapped connection WSAGetOverlappedResult 1 = ~ [("WSARecv failed, result=" WSAGetLastError) @result.catMany] when
      ] [
        transferred 0n32 = ["closed" @result.cat] when
      ] [
        transferred Int32 cast !size
      ]
    ) sequence

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
    "ws2_32.shutdown" use
    SD_SEND connection shutdown 0 = [String] [("shutdown failed, result=" WSAGetLastError) assembleString] if
  ];

  # Write data
  # in:
  #   data (Nat8 Cref Span) - buffer to write
  # out:
  #   result (String) - empty on success, error message on failure
  write: [
    data: toSpan;
    [valid?] "invalid TcpConnection" assert
    (data.data) (Nat8 Cref) same ~ [data printStack drop "[TcpConnection.write], invalid argument, [Nat8 Cref Span] expected" raiseStaticError] when
    result: String;

    (
      [result "" =] [
        canceled? ["canceled" @result.cat] when
      ] [
        context: {
          overlapped: OVERLAPPED;
          fiber: FiberData Ref;
          connection: Natx;
        };

        WSAOVERLAPPED_COMPLETION_ROUTINERef @context.@overlapped 0n32 Nat32 1n32 {len: data.size Nat32 cast; buf: data.data storageAddress;} connection WSASend 0 = ~ [
          lastError: WSAGetLastError;
          lastError WSA_IO_PENDING = ~ [("WSASend failed, result=" lastError) @result.catMany] when
        ] when
      ] [
        @currentFiber @context.!fiber
        connection new @context.!connection
        context storageAddress [
          context: @context addressToReference;
          @context.@overlapped context.connection CancelIoEx 1 = ~ [
            lastError: GetLastError;
            lastError ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
          ] when
        ] @currentFiber.setFunc

        dispatch
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func
        transferred: 0n32;
        Nat32 0 @transferred @context.@overlapped connection WSAGetOverlappedResult 1 = ~ [("WSASend failed, result=" WSAGetLastError) @result.catMany] when
      ] [
        [transferred Int32 cast data.size =] "wrong transferred size" assert
      ]
    ) sequence

    @result
  ];

  connection: INVALID_SOCKET;
}];

makeTcpConnection: [
  address: port:;;
  connection: TcpConnection;
  result: String;

  (
    [result "" =] [
      canceled? ["canceled" @result.cat] when
    ] [
      IPPROTO_TCP SOCK_STREAM AF_INET socket @connection.!connection connection.valid? ~ [("socket failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      nodelay: 1;
      nodelay storageSize Int32 cast nodelay storageAddress TCP_NODELAY IPPROTO_TCP connection.connection setsockopt 0 = ~ [("setsockopt failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      bindAddress: sockaddr_in;
      AF_INET Nat16 cast @bindAddress.!sin_family
      0n16 @bindAddress.!sin_port
      INADDR_ANY @bindAddress.!sin_addr
      bindAddress storageSize Int32 cast bindAddress storageAddress connection.connection bind 0 = ~ [("bind failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      @ConnectEx isNil [
        connectEx: FN_CONNECTEXRef AsRef;
        WSAOVERLAPPED_COMPLETION_ROUTINERef OVERLAPPED Ref Nat32 @connectEx storageSize Nat32 cast @connectEx storageAddress WSAID_CONNECTEX storageSize Nat32 cast WSAID_CONNECTEX storageAddress SIO_GET_EXTENSION_FUNCTION_POINTER connection.connection WSAIoctl 0 = ~ [
          TRUE [("WSAIoctl failed, result=" WSAGetLastError) @result.catMany] when
        ] [
          @connectEx.@data !ConnectEx
        ] if
      ] when
    ] [
      0n32 0nx completionPort connection.connection CreateIoCompletionPort completionPort = ~ [("CreateIoCompletionPort failed, result=" GetLastError) @result.catMany] when
    ] [
      addressData: sockaddr_in;
      AF_INET Nat16 cast @addressData.!sin_family
      port    htons @addressData.!sin_port
      address htonl @addressData.!sin_addr
      context: {
        overlapped: OVERLAPPED;
        fiber: FiberData Ref;
        connection: Natx;
      };

      @context.@overlapped Nat32 Ref 0n32 0nx addressData storageSize Int32 cast addressData storageAddress connection.connection ConnectEx 0 = ~ [("ConnectEx returned immediately") @result.catMany] when
    ] [
      lastError: WSAGetLastError;
      lastError WSA_IO_PENDING = ~ [("ConnectEx failed, result=" lastError) @result.catMany] when
    ] [
      @currentFiber @context.!fiber
      connection.connection new @context.!connection
      context storageAddress [
        context: @context addressToReference;
        @context.@overlapped context.connection CancelIoEx 1 = ~ [
          lastError: GetLastError;
          lastError ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
        ] when
      ] @currentFiber.setFunc

      dispatch
      canceled? ["canceled" @result.cat] when
    ] [
      @defaultCancelFunc @currentFiber.!func
      Nat32 0 Nat32 @context.@overlapped connection.connection WSAGetOverlappedResult 1 = ~ [("ConnectEx failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      value: 1n32; value storageSize Int32 cast value storageAddress SO_UPDATE_CONNECT_CONTEXT SOL_SOCKET connection.connection setsockopt 0 = ~ [("setsockopt failed, result=" WSAGetLastError) @result.catMany] when
    ]
  ) sequence

  result "" = ~ [TcpConnection !connection] when
  @connection @result
];

ConnectEx: FN_CONNECTEXRef;
