# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

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

"kernel32.kernel32" use
"ws2_32.winsock2"   use

"syncPrivate.FiberData"         use
"syncPrivate.canceled?"         use
"syncPrivate.completionPort"    use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use

TcpConnection: [{
  INIT: [winsock2.INVALID_SOCKET !connection];

  DIE: [
    valid? [
      connection winsock2.closesocket 0 = ~ [("FATAL: closesocket failed, result=" winsock2.WSAGetLastError LF) printList "" failProc] when
    ] when
  ];

  valid?: [connection winsock2.INVALID_SOCKET = ~];

  # Read data
  # in:
  #   data (Nat8 Ref) - address of the buffer to read data into
  #   dataSize (Int32) - size of the buffer
  # out:
  #   size (Int32) - size of the actual data
  #   result (String) - empty on success, error message on failure
  read: [
    data: dataSize:;;
    [valid?] "invalid TcpConnection" assert
    @data AsRef Nat8 AsRef same ~ [@data printStack drop "[TcpConnection.read], invalid argument, [Nat8 Ref] expected" raiseStaticError] when
    size: 0;
    result: String;

    (
      [result "" =] [
        canceled? ["canceled" @result.cat] when
      ] [
        context: {
          overlapped: kernel32.OVERLAPPED;
          fiber: FiberData Ref;
          connection: Natx;
        };

        winsock2.WSAOVERLAPPED_COMPLETION_ROUTINERef @context.@overlapped Nat32 Nat32 Ref 1n32 {len: dataSize Nat32 cast; buf: data storageAddress;} connection winsock2.WSARecv 0 = ~ [
          lastError: winsock2.WSAGetLastError;
          lastError winsock2.WSA_IO_PENDING = ~ [("WSARecv failed, result=" lastError) @result.catMany] when
        ] when
      ] [
        @currentFiber @context.!fiber
        connection new @context.!connection
        context storageAddress [
          context: @context addressToReference;
          @context.@overlapped context.connection kernel32.CancelIoEx 1 = ~ [
            lastError: kernel32.GetLastError;
            lastError kernel32.ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
          ] when
        ] @currentFiber.setFunc

        dispatch
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func
        transferred: 0n32;
        Nat32 0 @transferred @context.@overlapped connection winsock2.WSAGetOverlappedResult 1 = ~ [("WSARecv failed, result=" winsock2.WSAGetLastError) @result.catMany] when
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
    result: @string.data string.size read; @string.resize
    @string @result
  ];

  shutdown: [
    [valid?] "invalid TcpConnection" assert
    winsock2.SD_SEND connection winsock2.shutdown 0 = [String] [("shutdown failed, result=" winsock2.WSAGetLastError) assembleString] if
  ];

  # Write data
  # in:
  #   data (Nat8 Cref) - address of the buffer to write
  #   size (Int32) - size of the buffer
  # out:
  #   result (String) - empty on success, error message on failure
  write: [
    data: size:;;
    [valid?] "invalid TcpConnection" assert
    @data AsRef Nat8 Cref AsRef same ~ [@data printStack drop "[TcpConnection.write], invalid argument, [Nat8 Cref] expected" raiseStaticError] when
    result: String;

    (
      [result "" =] [
        canceled? ["canceled" @result.cat] when
      ] [
        context: {
          overlapped: kernel32.OVERLAPPED;
          fiber: FiberData Ref;
          connection: Natx;
        };

        winsock2.WSAOVERLAPPED_COMPLETION_ROUTINERef @context.@overlapped 0n32 Nat32 1n32 {len: size Nat32 cast; buf: data storageAddress;} connection winsock2.WSASend 0 = ~ [
          lastError: winsock2.WSAGetLastError;
          lastError winsock2.WSA_IO_PENDING = ~ [("WSASend failed, result=" lastError) @result.catMany] when
        ] when
      ] [
        @currentFiber @context.!fiber
        connection new @context.!connection
        context storageAddress [
          context: @context addressToReference;
          @context.@overlapped context.connection kernel32.CancelIoEx 1 = ~ [
            lastError: kernel32.GetLastError;
            lastError kernel32.ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
          ] when
        ] @currentFiber.setFunc

        dispatch
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func
        transferred: 0n32;
        Nat32 0 @transferred @context.@overlapped connection winsock2.WSAGetOverlappedResult 1 = ~ [("WSASend failed, result=" winsock2.WSAGetLastError) @result.catMany] when
      ] [
        [transferred Int32 cast size =] "wrong transferred size" assert
      ]
    ) sequence

    @result
  ];

  writeString: [
    [valid?] "invalid TcpConnection" assert
    string: makeStringView;
    string.data string.size write
  ];

  connection: winsock2.INVALID_SOCKET;
}];

makeTcpConnection: [
  address: port:;;
  connection: TcpConnection;
  result: String;

  (
    [result "" =] [
      canceled? ["canceled" @result.cat] when
    ] [
      winsock2.IPPROTO_TCP winsock2.SOCK_STREAM winsock2.AF_INET winsock2.socket @connection.!connection connection.valid? ~ [("socket failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      nodelay: 1;
      nodelay storageSize Int32 cast nodelay storageAddress winsock2.TCP_NODELAY winsock2.IPPROTO_TCP connection.connection winsock2.setsockopt 0 = ~ [("setsockopt failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      bindAddress: winsock2.sockaddr_in;
      winsock2.AF_INET Nat16 cast @bindAddress.!sin_family
      0n16 @bindAddress.!sin_port
      winsock2.INADDR_ANY @bindAddress.!sin_addr
      bindAddress storageSize Int32 cast bindAddress storageAddress connection.connection winsock2.bind 0 = ~ [("bind failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      @ConnectEx isNil [
        connectEx: winsock2.FN_CONNECTEXRef AsRef;
        winsock2.WSAOVERLAPPED_COMPLETION_ROUTINERef kernel32.OVERLAPPED Ref Nat32 connectEx storageSize Nat32 cast connectEx storageAddress winsock2.WSAID_CONNECTEX storageSize Nat32 cast winsock2.WSAID_CONNECTEX storageAddress winsock2.SIO_GET_EXTENSION_FUNCTION_POINTER connection.connection winsock2.WSAIoctl 0 = ~ [
          TRUE [("WSAIoctl failed, result=" winsock2.WSAGetLastError) @result.catMany] when
        ] [
          connectEx.@data !ConnectEx
        ] if
      ] when
    ] [
      0n32 0nx completionPort connection.connection kernel32.CreateIoCompletionPort completionPort = ~ [("CreateIoCompletionPort failed, result=" kernel32.GetLastError) @result.catMany] when
    ] [
      addressData: winsock2.sockaddr_in;
      winsock2.AF_INET Nat16 cast @addressData.!sin_family
      port winsock2.htons @addressData.!sin_port
      address winsock2.htonl @addressData.!sin_addr
      context: {
        overlapped: kernel32.OVERLAPPED;
        fiber: FiberData Ref;
        connection: Natx;
      };

      @context.@overlapped Nat32 Ref 0n32 0nx addressData storageSize Int32 cast addressData storageAddress connection.connection ConnectEx 0 = ~ [("ConnectEx returned immediately") @result.catMany] when
    ] [
      lastError: winsock2.WSAGetLastError;
      lastError winsock2.WSA_IO_PENDING = ~ [("ConnectEx failed, result=" lastError) @result.catMany] when
    ] [
      @currentFiber @context.!fiber
      connection.connection new @context.!connection
      context storageAddress [
        context: @context addressToReference;
        @context.@overlapped context.connection kernel32.CancelIoEx 1 = ~ [
          lastError: kernel32.GetLastError;
          lastError kernel32.ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
        ] when
      ] @currentFiber.setFunc

      dispatch
      canceled? ["canceled" @result.cat] when
    ] [
      @defaultCancelFunc @currentFiber.!func
      Nat32 0 Nat32 @context.@overlapped connection.connection winsock2.WSAGetOverlappedResult 1 = ~ [("ConnectEx failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      value: 1n32; value storageSize Int32 cast value storageAddress winsock2.SO_UPDATE_CONNECT_CONTEXT winsock2.SOL_SOCKET connection.connection winsock2.setsockopt 0 = ~ [("setsockopt failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ]
  ) sequence

  result "" = ~ [TcpConnection !connection] when
  @connection @result
];

ConnectEx: winsock2.FN_CONNECTEXRef;
