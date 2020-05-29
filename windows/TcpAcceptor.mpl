"Function.Function" use
"String.String" use
"String.assembleString" use
"String.print" use
"String.toString" use
"TcpConnection.TcpConnection" use
"atomic.ACQUIRE" use
"atomic.RELEASE" use
"atomic.atomicExchange" use
"atomic.atomicStore" use
"atomic.atomicXor" use
"control.&&" use
"control.=" use
"control.Int32" use
"control.Nat16" use
"control.Nat32" use
"control.Nat8" use
"control.Natx" use
"control.Ref" use
"control.assert" use
"control.cond" use
"control.drop" use
"control.isNil" use
"control.print" use
"control.when" use
"control.||" use
"dispatcher.dispatcher" use
"kernel32.kernel32" use
"ws2_32.winsock2" use

TcpAcceptor: [{
  INIT: [
    0n8 !states
  ];

  DIE: [
    old: IN_DIE @states ACQUIRE atomicExchange;
    [old 0n8 =] "TcpAcceptor.DIE: invalid state" assert
  ];

  # Listen for incoming connections
  # input:
  #   address (Nat32) - IPv4 address to listen on
  #   port (Nat16) - port to listen on
  # output:
  #   result (String) - empty on success, error message on failure
  startListening: [
    address: port:;;
    old: IN_START_LISTENING @states ACQUIRE atomicExchange;
    [old 0n8 =] "TcpAcceptor.startListening: invalid state" assert
    winsock2.IPPROTO_TCP winsock2.SOCK_STREAM winsock2.AF_INET winsock2.socket !listener listener winsock2.INVALID_SOCKET = [("socket failed, result=" winsock2.WSAGetLastError) assembleString] [
      {} (
        [drop nodelay: 1; nodelay storageSize Nat32 cast Int32 cast nodelay storageAddress winsock2.TCP_NODELAY winsock2.IPPROTO_TCP listener winsock2.setsockopt 0 = ~] [("setsockopt failed, result=" winsock2.WSAGetLastError) assembleString]
        [
          drop
          addressData: winsock2.sockaddr_in;
          winsock2.AF_INET Nat32 cast Nat16 cast @addressData.!sin_family
          port winsock2.htons @addressData.!sin_port
          address winsock2.htonl @addressData.!sin_addr
          addressData storageSize Nat32 cast Int32 cast addressData storageAddress listener winsock2.bind 0 = ~
        ] [("bind failed, result=" winsock2.WSAGetLastError) assembleString]
        [drop winsock2.SOMAXCONN listener winsock2.listen 0 = ~] [("listen failed, result=" winsock2.WSAGetLastError) assembleString]
        [
          drop
          @AcceptEx isNil [
            acceptEx: (winsock2.FN_ACCEPTEXRef);
            read: Nat32;
            winsock2.WSAOVERLAPPED_COMPLETION_ROUTINERef kernel32.OVERLAPPED Ref @read acceptEx storageSize Nat32 cast acceptEx storageAddress winsock2.WSAID_ACCEPTEX storageSize Nat32 cast winsock2.WSAID_ACCEPTEX storageAddress winsock2.SIO_GET_EXTENSION_FUNCTION_POINTER listener winsock2.WSAIoctl 0 = ~
            [TRUE] [0 acceptEx @ !AcceptEx FALSE] if
          ] &&
        ] [("WSAIoctl failed, result=" winsock2.WSAGetLastError) assembleString]
        [drop 0n32 0nx dispatcher.completionPort listener kernel32.CreateIoCompletionPort dispatcher.completionPort = ~] [("CreateIoCompletionPort failed, result=" kernel32.GetLastError) assembleString]
        [
          0nx @dispatcherContext.@overlapped.!hEvent
          @onAcceptEventWrapper @dispatcherContext.!onEvent
          "" toString
          LISTENING @states RELEASE atomicStore
        ]
      ) cond

      result:; result "" = ~ [
        listener winsock2.closesocket 0 = ~ [("LEAK: closesocket failed, result=" winsock2.WSAGetLastError LF) assembleString print] when
        0n8 @states RELEASE atomicStore
      ] when

      result
    ] if
  ];

  # Stop listening
  # input:
  #   NONE
  # output:
  #   NONE
  stopListening: [
    old: IN_STOP_LISTENING @states ACQUIRE atomicExchange;
    [old LISTENING =] "TcpAcceptor.stopListening: invalid state" assert
    listener winsock2.closesocket 0 = ~ [("LEAK: closesocket failed, result=" winsock2.WSAGetLastError LF) assembleString print] when
    0n8 @states RELEASE atomicStore
  ];

  # Initiate connection acceptance
  # input:
  #   context (Natx) - context value to be passed to onAccept callback
  #   onAccept (String Ref TcpConnection Ref -- ) - callback to be called when accepted, failed or canceled
  # output:
  #   result (String) - empty on success, error message on failure
  accept: [
    onAccept0:;
    old: IN_ACCEPT LISTENING or @states ACQUIRE atomicExchange;
    [old LISTENING =] "TcpAcceptor.accept: invalid state" assert
    winsock2.IPPROTO_TCP winsock2.SOCK_STREAM winsock2.AF_INET winsock2.socket !connection connection winsock2.INVALID_SOCKET = [("socket failed, result=" winsock2.WSAGetLastError) assembleString] [
      {} (
        [drop nodelay: 1; nodelay storageSize Nat32 cast Int32 cast nodelay storageAddress winsock2.TCP_NODELAY winsock2.IPPROTO_TCP connection winsock2.setsockopt 0 = ~] [("setsockopt failed, result=" winsock2.WSAGetLastError) assembleString]
        [
          drop
          self storageAddress @dispatcherContext.!context
          @onAccept0 @onAccept.assign
          LISTENING ACCEPTING or @states RELEASE atomicStore
          # If 'cancel' will be called at this point, it is possible that it will not happen in time co cancel the operation.
          # It is a caller responsibility to synchronize 'cancel' call with the exit from 'accept'.
          @dispatcherContext.@overlapped Nat32 Ref winsock2.sockaddr_in storageSize Nat32 cast 16n32 + winsock2.sockaddr_in storageSize Nat32 cast 16n32 + 0n32 addresses storageAddress connection listener AcceptEx 0 = ~
        ] ["AcceptEx returned immediately" toString]
        [drop winsock2.WSAGetLastError winsock2.WSA_IO_PENDING = ~] [("AcceptEx failed, result=" winsock2.WSAGetLastError) assembleString]
        ["" toString]
      ) cond

      result:; result "" = ~ [
        connection winsock2.closesocket 0 = ~ [("LEAK: closesocket failed, result=" winsock2.WSAGetLastError LF) assembleString print] when
        LISTENING @states RELEASE atomicStore
      ] when

      result
    ] if
  ];

  # Try to cancel acceptance
  # input:
  #   NONE
  # output:
  #   isCanceled (Cond) - TRUE if accept was canceled, FALSE if cancel failed or accept already finished
  cancel: [
    old: IN_CANCEL @states ACQUIRE atomicXor;
    [old LISTENING ACCEPTING or = [old IN_ON_ACCEPT_EVENT LISTENING or ACCEPTING or =] || [old LISTENING =] ||] "TcpAcceptor.cancel: invalid state" assert
    old LISTENING ACCEPTING or = ~ [FALSE] [
      # In the unfortunate event when 'onAcceptEvent' was called at this point, we still call the 'CancelIoEx', but this should not hurt.
      @dispatcherContext.@overlapped listener kernel32.CancelIoEx 1 = ~ [
        kernel32.GetLastError kernel32.ERROR_NOT_FOUND = ~ [("CancelIoEx failed, result=" kernel32.GetLastError LF) assembleString print] when # There is no good way to handle this, just report.
        FALSE
      ] [TRUE] if
    ] if

    IN_CANCEL @states RELEASE atomicXor drop
  ];

  IN_DIE:             [0x01n8];
  IN_START_LISTENING: [0x02n8];
  IN_STOP_LISTENING:  [0x04n8];
  IN_ACCEPT:          [0x08n8];
  IN_CANCEL:          [0x10n8];
  IN_ON_ACCEPT_EVENT: [0x20n8];
  LISTENING:          [0x40n8];
  ACCEPTING:          [0x80n8];

  states: 0n8;
  listener: Natx;
  connection: Natx;
  addresses: Nat8 winsock2.sockaddr_in storageSize Nat32 cast Int32 cast 16 + 2 * array;
  dispatcherContext: dispatcher.Context;

  onAccept: ({result: String Ref; connection: TcpConnection Ref;} {} {}) Function;
  context: Natx;

  onAcceptEvent: [
    numberOfBytesTransferred: error: copy;;
    old: IN_ON_ACCEPT_EVENT @states ACQUIRE atomicXor;
    [old LISTENING ACCEPTING or = [old IN_CANCEL LISTENING or ACCEPTING or =] ||] "TcpAcceptor.onAcceptEvent: invalid state" assert
    result: String;
    tcpConnection: TcpConnection;
    transferred: 0n32;
    flags: 0n32;
    @flags 0 @transferred @dispatcherContext.@overlapped connection winsock2.WSAGetOverlappedResult 1 = ~ [winsock2.WSAGetLastError Nat32 cast !error] [0n32 !error] if
    [transferred numberOfBytesTransferred =] "unexpected transferred size" assert
    error 0n32 = ~ [
      connection winsock2.closesocket 0 = ~ [("LEAK: closesocket failed, result=" winsock2.WSAGetLastError LF) assembleString print] when
      error kernel32.ERROR_OPERATION_ABORTED = ["canceled" toString !result] [("AcceptEx failed, result=" error) assembleString !result] if
    ] [
      listener storageSize Nat32 cast Int32 cast listener storageAddress winsock2.SO_UPDATE_ACCEPT_CONTEXT winsock2.SOL_SOCKET connection winsock2.setsockopt 0 = ~ [
        ("setsockopt failed, result=" winsock2.WSAGetLastError) assembleString !result
        connection winsock2.closesocket 0 = ~ [("LEAK: closesocket failed, result=" winsock2.WSAGetLastError LF) assembleString print] when
      ] [
        0n32 0nx dispatcher.completionPort connection kernel32.CreateIoCompletionPort dispatcher.completionPort = ~ [
          ("CreateIoCompletionPort failed, result=" kernel32.GetLastError) assembleString !result
          connection winsock2.closesocket 0 = ~ [("LEAK: closesocket failed, result=" winsock2.WSAGetLastError LF) assembleString print] when
        ] [
          connection @tcpConnection.setConnection
        ] if
      ] if
    ] if

    IN_ON_ACCEPT_EVENT ACCEPTING or @states RELEASE atomicXor drop
    @tcpConnection @result onAccept
  ];

  onAcceptEventWrapper: [TcpAcceptor addressToReference .onAcceptEvent];
}];

AcceptEx: winsock2.FN_ACCEPTEXRef;
