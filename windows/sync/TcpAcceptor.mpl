# Copyright (C) Matway Burkow
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
"control.nil?"     use
"control.sequence" use
"control.when"     use

"kernel32.CancelIoEx"                        use
"kernel32.CreateIoCompletionPort"            use
"kernel32.ERROR_NOT_FOUND"                   use
"kernel32.GetLastError"                      use
"kernel32.OVERLAPPED"                        use
"ws2_32.AF_INET"                             use
"ws2_32.FN_ACCEPTEXRef"                      use
"ws2_32.FN_GETACCEPTEXSOCKADDRSRef"          use
"ws2_32.INVALID_SOCKET"                      use
"ws2_32.IPPROTO_TCP"                         use
"ws2_32.SIO_GET_EXTENSION_FUNCTION_POINTER"  use
"ws2_32.SOCK_STREAM"                         use
"ws2_32.SOL_SOCKET"                          use
"ws2_32.SOMAXCONN"                           use
"ws2_32.SO_UPDATE_ACCEPT_CONTEXT"            use
"ws2_32.TCP_NODELAY"                         use
"ws2_32.WSAGetLastError"                     use
"ws2_32.WSAGetOverlappedResult"              use
"ws2_32.WSAID_ACCEPTEX"                      use
"ws2_32.WSAID_GETACCEPTEXSOCKADDRS"          use
"ws2_32.WSAIoctl"                            use
"ws2_32.WSAOVERLAPPED_COMPLETION_ROUTINERef" use
"ws2_32.WSA_IO_PENDING"                      use
"ws2_32.bind"                                use
"ws2_32.closesocket"                         use
"ws2_32.htonl"                               use
"ws2_32.htons"                               use
"ws2_32.listen"                              use
"ws2_32.ntohl"                               use
"ws2_32.setsockopt"                          use
"ws2_32.sockaddr"                            use
"ws2_32.sockaddr_in"                         use
"ws2_32.socket"                              use

"TcpConnection.TcpConnection"   use
"syncPrivate.FiberData"         use
"syncPrivate.canceled?"         use
"syncPrivate.completionPort"    use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use

TcpAcceptor: [{
  INIT: [INVALID_SOCKET !acceptor];

  DIE: [
    valid? [
      acceptor closesocket 0 = ~ [("FATAL: closesocket failed, result=" WSAGetLastError LF) printList "" failProc] when
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
    connection: TcpConnection;
    address: Nat32;
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
        addresses: Nat8 sockaddr_in storageSize Int32 cast 16 + 2 * array;
        context: {
          overlapped: OVERLAPPED;
          fiber: FiberData Ref;
          acceptor: Natx;
        };

        @context.@overlapped Nat32 Ref sockaddr_in storageSize Nat32 cast 16n32 + dup 0n32 addresses storageAddress connection.connection acceptor AcceptEx 0 = ~ [("AcceptEx returned immediately") @result.catMany] when
      ] [
        lastError: WSAGetLastError;
        lastError WSA_IO_PENDING = ~ [("AcceptEx failed, result=" lastError) @result.catMany] when
      ] [
        @currentFiber @context.!fiber
        acceptor new @context.!acceptor
        context storageAddress [
          context: @context addressToReference;
          @context.@overlapped context.acceptor CancelIoEx 1 = ~ [
            lastError: GetLastError;
            lastError ERROR_NOT_FOUND = ~ [("FATAL: CancelIoEx failed, result=" lastError LF) printList "" failProc] when
          ] when
        ] @currentFiber.setFunc

        dispatch
        canceled? ["canceled" @result.cat] when
      ] [
        @defaultCancelFunc @currentFiber.!func
        Nat32 0 Nat32 @context.@overlapped connection.connection WSAGetOverlappedResult 1 = ~ [("AcceptEx failed, result=" WSAGetLastError) @result.catMany] when
      ] [
        acceptor storageSize Int32 cast acceptor storageAddress SO_UPDATE_ACCEPT_CONTEXT SOL_SOCKET connection.connection setsockopt 0 = ~ [("setsockopt failed, result=" WSAGetLastError) @result.catMany] when
      ] [
        0n32 0nx completionPort connection.connection CreateIoCompletionPort completionPort = ~ [("CreateIoCompletionPort failed, result=" GetLastError) @result.catMany] when
      ] [
        localAddress:  sockaddr AsRef;
        remoteAddress: sockaddr AsRef;
        Int32 @remoteAddress Int32 @localAddress sockaddr_in storageSize Nat32 cast 16n32 + dup 0n32 addresses storageAddress GetAcceptExSockaddrs
        localAddressIn:  localAddress  storageAddress sockaddr_in addressToReference;
        remoteAddressIn: remoteAddress storageAddress sockaddr_in addressToReference;
        remoteAddressIn.sin_addr ntohl !address
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
  result: String;

  (
    [result "" =] [
      canceled? ["canceled" @result.cat] when
    ] [
      IPPROTO_TCP SOCK_STREAM AF_INET socket @acceptor.!acceptor acceptor.valid? ~ [("socket failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      nodelay: 1;
      nodelay storageSize Int32 cast nodelay storageAddress TCP_NODELAY IPPROTO_TCP acceptor.acceptor setsockopt 0 = ~ [("setsockopt failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      0n32 0nx completionPort acceptor.acceptor CreateIoCompletionPort completionPort = ~ [("CreateIoCompletionPort failed, result=" GetLastError) @result.catMany] when
    ] [
      addressData: sockaddr_in;
      AF_INET Nat16 cast @addressData.!sin_family
      port    htons @addressData.!sin_port
      address htonl @addressData.!sin_addr
      addressData storageSize Int32 cast addressData storageAddress acceptor.acceptor bind 0 = ~ [("bind failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      SOMAXCONN acceptor.acceptor listen 0 = ~ [("listen failed, result=" WSAGetLastError) @result.catMany] when
    ] [
      @AcceptEx nil? [
        acceptEx: FN_ACCEPTEXRef AsRef;
        WSAOVERLAPPED_COMPLETION_ROUTINERef OVERLAPPED Ref Nat32 @acceptEx storageSize Nat32 cast @acceptEx storageAddress WSAID_ACCEPTEX storageSize Nat32 cast WSAID_ACCEPTEX storageAddress SIO_GET_EXTENSION_FUNCTION_POINTER acceptor.acceptor WSAIoctl 0 = ~ [
          TRUE [("WSAIoctl failed, result=" WSAGetLastError) @result.catMany] when
        ] [
          getAcceptExSockaddrs: FN_GETACCEPTEXSOCKADDRSRef AsRef;
          WSAOVERLAPPED_COMPLETION_ROUTINERef OVERLAPPED Ref Nat32 @getAcceptExSockaddrs storageSize Nat32 cast @getAcceptExSockaddrs storageAddress WSAID_GETACCEPTEXSOCKADDRS storageSize Nat32 cast WSAID_GETACCEPTEXSOCKADDRS storageAddress SIO_GET_EXTENSION_FUNCTION_POINTER acceptor.acceptor WSAIoctl 0 = ~ [
            TRUE [("WSAIoctl failed, result=" WSAGetLastError) @result.catMany] when
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

AcceptEx:             FN_ACCEPTEXRef;
GetAcceptExSockaddrs: FN_GETACCEPTEXSOCKADDRSRef;
