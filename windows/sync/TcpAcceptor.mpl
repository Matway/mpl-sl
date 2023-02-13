# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.String"    use
"String.printList" use
"algorithm.="      use
"control.AsRef"    use
"control.Int32"    use
"control.Nat16"    use
"control.Nat32"    use
"control.Nat8"     use
"control.Natx"     use
"control.Ref"      use
"control.assert"   use
"control.dup"      use
"control.failProc" use
"control.isNil"    use
"control.sequence" use
"control.when"     use

"kernel32.kernel32" use
"ws2_32.winsock2"   use

"TcpConnection.TcpConnection"   use
"syncPrivate.FiberData"         use
"syncPrivate.canceled?"         use
"syncPrivate.completionPort"    use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use

TcpAcceptor: [{
  INIT: [winsock2.INVALID_SOCKET !acceptor];

  DIE: [
    valid? [
      acceptor winsock2.closesocket 0 = ~ [("FATAL: closesocket failed, result=" winsock2.WSAGetLastError LF) printList "" failProc] when
    ] when
  ];

  valid?: [acceptor winsock2.INVALID_SOCKET = ~];

  # Accept connection
  # in:
  #   NONE
  # out:
  #   connection (TcpConnection) - accepted connection
  #   address (Nat32) - remote IPv4 address
  #   result (String) - empty on success, error message on failure
  accept: [
    [valid?] "invalid TcpAcceptor" assert
    connection: TcpConnection;
    address: Nat32;
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
        addresses: Nat8 winsock2.sockaddr_in storageSize Int32 cast 16 + 2 * array;
        context: {
          overlapped: kernel32.OVERLAPPED;
          fiber: FiberData Ref;
          acceptor: Natx;
        };

        @context.@overlapped Nat32 Ref winsock2.sockaddr_in storageSize Nat32 cast 16n32 + dup 0n32 addresses storageAddress connection.connection acceptor AcceptEx 0 = ~ [("AcceptEx returned immediately") @result.catMany] when
      ] [
        lastError: winsock2.WSAGetLastError;
        lastError winsock2.WSA_IO_PENDING = ~ [("AcceptEx failed, result=" lastError) @result.catMany] when
      ] [
        @currentFiber @context.!fiber
        acceptor new @context.!acceptor
        context storageAddress [
          context: @context addressToReference;
          @context.@overlapped context.acceptor kernel32.CancelIoEx 1 = ~ [
            lastError: kernel32.GetLastError;
            lastError kernel32.ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
          ] when
        ] @currentFiber.setFunc

        dispatch
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func
        Nat32 0 Nat32 @context.@overlapped connection.connection winsock2.WSAGetOverlappedResult 1 = ~ [("AcceptEx failed, result=" winsock2.WSAGetLastError) @result.catMany] when
      ] [
        acceptor storageSize Int32 cast acceptor storageAddress winsock2.SO_UPDATE_ACCEPT_CONTEXT winsock2.SOL_SOCKET connection.connection winsock2.setsockopt 0 = ~ [("setsockopt failed, result=" winsock2.WSAGetLastError) @result.catMany] when
      ] [
        0n32 0nx completionPort connection.connection kernel32.CreateIoCompletionPort completionPort = ~ [("CreateIoCompletionPort failed, result=" kernel32.GetLastError) @result.catMany] when
      ] [
        localAddress: winsock2.sockaddr AsRef;
        remoteAddress: winsock2.sockaddr AsRef;
        Int32 @remoteAddress Int32 @localAddress winsock2.sockaddr_in storageSize Nat32 cast 16n32 + dup 0n32 addresses storageAddress GetAcceptExSockaddrs
        localAddressIn: localAddress storageAddress winsock2.sockaddr_in addressToReference;
        remoteAddressIn: remoteAddress storageAddress winsock2.sockaddr_in addressToReference;
        remoteAddressIn.sin_addr winsock2.ntohl !address
      ]
    ) sequence

    result "" = ~ [TcpConnection !connection] when
    @connection @address @result
  ];

  acceptor: winsock2.INVALID_SOCKET;
}];

makeTcpAcceptor: [
  address: port:;;
  acceptor: TcpAcceptor;
  result: String;

  (
    [result "" =] [
      canceled? ["canceled" @result.cat] when
    ] [
      winsock2.IPPROTO_TCP winsock2.SOCK_STREAM winsock2.AF_INET winsock2.socket @acceptor.!acceptor acceptor.valid? ~ [("socket failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      nodelay: 1;
      nodelay storageSize Int32 cast nodelay storageAddress winsock2.TCP_NODELAY winsock2.IPPROTO_TCP acceptor.acceptor winsock2.setsockopt 0 = ~ [("setsockopt failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      0n32 0nx completionPort acceptor.acceptor kernel32.CreateIoCompletionPort completionPort = ~ [("CreateIoCompletionPort failed, result=" kernel32.GetLastError) @result.catMany] when
    ] [
      addressData: winsock2.sockaddr_in;
      winsock2.AF_INET Nat16 cast @addressData.!sin_family
      port winsock2.htons @addressData.!sin_port
      address winsock2.htonl @addressData.!sin_addr
      addressData storageSize Int32 cast addressData storageAddress acceptor.acceptor winsock2.bind 0 = ~ [("bind failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      winsock2.SOMAXCONN acceptor.acceptor winsock2.listen 0 = ~ [("listen failed, result=" winsock2.WSAGetLastError) @result.catMany] when
    ] [
      @AcceptEx isNil [
        acceptEx: winsock2.FN_ACCEPTEXRef AsRef;
        winsock2.WSAOVERLAPPED_COMPLETION_ROUTINERef kernel32.OVERLAPPED Ref Nat32 @acceptEx storageSize Nat32 cast @acceptEx storageAddress winsock2.WSAID_ACCEPTEX storageSize Nat32 cast winsock2.WSAID_ACCEPTEX storageAddress winsock2.SIO_GET_EXTENSION_FUNCTION_POINTER acceptor.acceptor winsock2.WSAIoctl 0 = ~ [
          TRUE [("WSAIoctl failed, result=" winsock2.WSAGetLastError) @result.catMany] when
        ] [
          getAcceptExSockaddrs: winsock2.FN_GETACCEPTEXSOCKADDRSRef AsRef;
          winsock2.WSAOVERLAPPED_COMPLETION_ROUTINERef kernel32.OVERLAPPED Ref Nat32 @getAcceptExSockaddrs storageSize Nat32 cast @getAcceptExSockaddrs storageAddress winsock2.WSAID_GETACCEPTEXSOCKADDRS storageSize Nat32 cast winsock2.WSAID_GETACCEPTEXSOCKADDRS storageAddress winsock2.SIO_GET_EXTENSION_FUNCTION_POINTER acceptor.acceptor winsock2.WSAIoctl 0 = ~ [
            TRUE [("WSAIoctl failed, result=" winsock2.WSAGetLastError) @result.catMany] when
          ] [
            @acceptEx.@data !AcceptEx
            @getAcceptExSockaddrs.@data !GetAcceptExSockaddrs
          ] if
        ] if
      ] when
    ]
  ) sequence

  result "" = ~ [TcpAcceptor !acceptor] when
  @acceptor @result
];

AcceptEx: winsock2.FN_ACCEPTEXRef;
GetAcceptExSockaddrs: winsock2.FN_GETACCEPTEXSOCKADDRSRef;
