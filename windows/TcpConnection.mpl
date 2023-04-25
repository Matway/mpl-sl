# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Function.Function"     use
"Span.toSpan"           use
"String.String"         use
"String.assembleString" use
"String.print"          use
"String.toString"       use
"algorithm.="           use
"algorithm.cond"        use
"atomic.ACQUIRE"        use
"atomic.RELEASE"        use
"atomic.atomicExchange" use
"atomic.atomicStore"    use
"atomic.atomicXor"      use
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
"control.exit"          use
"control.nil?"          use
"control.when"          use
"control.||"            use

"kernel32.CreateIoCompletionPort"            use
"kernel32.ERROR_OPERATION_ABORTED"           use
"kernel32.GetLastError"                      use
"kernel32.OVERLAPPED"                        use
"ws2_32.AF_INET"                             use
"ws2_32.FN_CONNECTEXRef"                     use
"ws2_32.INADDR_ANY"                          use
"ws2_32.INVALID_SOCKET"                      use
"ws2_32.IPPROTO_TCP"                         use
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

"dispatcher.dispatcher" use

writeEventCount: 0 dynamic;

TcpConnection: [{
  INIT: [
    0n32 !states
  ];

  DIE: [
    old: IN_DIE @states ACQUIRE atomicExchange;
    [old 0n32 =] "TcpConnection.DIE: invalid state" assert
  ];

  isConnected: [
    old: IN_IS_CONNECTED @states ACQUIRE atomicXor;
    [old 0n32 = [old CONNECTED =] ||] "TcpConnection.isConnected: invalid state" assert
    old CONNECTED =
    IN_IS_CONNECTED @states ACQUIRE atomicXor drop
  ];

  setConnection: [
    connection0:;
    old: IN_SET @states ACQUIRE atomicExchange;
    [old 0n32 =] "TcpConnection.setConnection: invalid state" assert
    connection0 copy !connection
    0nx @readDispatcherContext.@overlapped.!hEvent
    @onReadEventWrapper @readDispatcherContext.!onEvent
    0nx @writeDispatcherContext.@overlapped.!hEvent
    @onWriteEventWrapper @writeDispatcherContext.!onEvent
    CONNECTED @states RELEASE atomicStore
  ];

  # Initiate connection
  # input:
  #   address (Nat32) - destination IPv4 address
  #   port (Nat16) - destination port
  #   onConnect (String Ref -- ) - callback to be called when connected, failed or canceled
  # output:
  #   result (String) - empty on success, error message on failure
  connect: [
    address: port: onConnect0:;;;
    old: IN_CONNECT @states ACQUIRE atomicExchange;
    [old 0n32 =] "TcpConnection.connect: invalid state" assert
    IPPROTO_TCP SOCK_STREAM AF_INET socket !connection connection INVALID_SOCKET = [("socket failed, result=" WSAGetLastError) assembleString] [
      {} (
        [drop nodelay: 1; nodelay storageSize Nat32 cast Int32 cast nodelay storageAddress TCP_NODELAY IPPROTO_TCP connection setsockopt 0 = ~] [("setsockopt failed, result=" WSAGetLastError) assembleString]
        [
          drop
          bindAddress: sockaddr_in;
          AF_INET Nat32 cast Nat16 cast @bindAddress.!sin_family
          0n16       @bindAddress.!sin_port
          INADDR_ANY @bindAddress.!sin_addr
          bindAddress storageSize Nat32 cast Int32 cast bindAddress storageAddress connection bind 0 = ~
        ] [("bind failed, result=" WSAGetLastError) assembleString]
        [
          drop
          @ConnectEx nil? [
            connectEx: (FN_CONNECTEXRef);
            read: Nat32;
            WSAOVERLAPPED_COMPLETION_ROUTINERef OVERLAPPED Ref @read connectEx storageSize Nat32 cast connectEx storageAddress WSAID_CONNECTEX storageSize Nat32 cast WSAID_CONNECTEX storageAddress SIO_GET_EXTENSION_FUNCTION_POINTER connection WSAIoctl 0 = ~
            [TRUE] [0 connectEx @ !ConnectEx FALSE] if
          ] &&
        ] [("WSAIoctl failed, result=" WSAGetLastError) assembleString]
        [drop 0n32 0nx dispatcher.completionPort connection CreateIoCompletionPort dispatcher.completionPort = ~] [("CreateIoCompletionPort failed, result=" GetLastError) assembleString]
        [
          drop
          addressData: sockaddr_in;
          AF_INET Nat32 cast Nat16 cast @addressData.!sin_family
          port    htons @addressData.!sin_port
          address htonl @addressData.!sin_addr
          0nx @writeDispatcherContext.@overlapped.!hEvent
          @onConnectEventWrapper @writeDispatcherContext.!onEvent
          self storageAddress @writeDispatcherContext.!context
          @onConnect0 @onWrite.assign
          CONNECTING @states RELEASE atomicStore
          # If 'cancelConnect' will be called at this point, it is possible that it will not happen in time co cancel the operation.
          # It is a caller responsibility to synchronize 'cancelConnect' call with the exit from 'connect'.
          @writeDispatcherContext.@overlapped Nat32 Ref 0n32 0nx addressData storageSize Nat32 cast Int32 cast addressData storageAddress connection ConnectEx 1 =
        ] ["ConnectEx returned immediately" toString]
        [drop WSAGetLastError WSA_IO_PENDING = ~] [("ConnectEx failed, result=" WSAGetLastError) assembleString]
        ["" toString]
      ) cond

      result:; result "" = ~ [
        connection closesocket 0 = ~ [("LEAK: closesocket failed, result=" WSAGetLastError LF) assembleString print] when
        0n32 @states RELEASE atomicStore
      ] when

      result
    ] if
  ];

  # Try to cancel connection
  # input:
  #   NONE
  # output:
  #   isCanceled (Cond) - TRUE if connect was canceled, FALSE if cancel failed or connect already finished
  cancelConnect: [
    old: IN_CANCEL_CONNECT @states ACQUIRE atomicXor;
    [old CONNECTING = [old IN_ON_CONNECT_EVENT CONNECTING or =] || [old 0n32 =] || [old CONNECTED =] ||] "TcpConnection.cancelConnect: invalid state" assert
    old CONNECTING = ~ [
      FALSE
      IN_CANCEL_CONNECT @states RELEASE atomicXor drop
    ] [
      @writeDispatcherContext.@overlapped connection CancelIoEx 1 = ~ [
        GetLastError ERROR_NOT_FOUND = ~ [("CancelIoEx failed, result=" GetLastError LF) assembleString print] when # There is no good way to handle this, just report.
        FALSE
      ] [TRUE] if

      IN_CANCEL_CONNECT @states RELEASE atomicXor !old
      [old IN_CANCEL_CONNECT CONNECTING or = [old IN_CANCEL_CONNECT IN_ON_CONNECT_EVENT or CONNECTING or =] || [old IN_CANCEL_CONNECT =] || [old IN_CANCEL_CONNECT CONNECTED or =] ||] "TcpConnection.cancelConnect: invalid state" assert
      # There is a chance that 'onConnectEvent' was called in the middle of executon of 'cancelConnect' and was not allowed to proceed. In this case, we should restart it.
      old IN_CANCEL_CONNECT IN_ON_CONNECT_EVENT or CONNECTING or = [
        CONNECTING @states RELEASE atomicStore
        @writeDispatcherContext.@overlapped 0nx writeDispatcherContext.overlapped.InternalHigh Nat32 cast dispatcher.completionPort PostQueuedCompletionStatus 1 = ~ [
          ("FATAL: PostQueuedCompletionStatus failed, result=" GetLastError LF) assembleString print 1 exit
        ] when
      ] when
    ] if
  ];

  # Disconnect connection
  # input:
  #   NONE
  # output:
  #   NONE
  disconnect: [
    old: IN_DISCONNECT @states ACQUIRE atomicExchange;
    [old CONNECTED =] "TcpConnection.disconnect: invalid state" assert
    connection closesocket 0 = ~ [("LEAK: closesocket failed, result=" WSAGetLastError LF) assembleString print] when
    0n32 @states RELEASE atomicStore
  ];

  # Initiate read
  # input:
  #   data (Nat8 Span) - buffer to read into
  #   onRead (String Ref Int32 -- ) - callback to be called when read completed, failed or canceled
  # output:
  #   result (String) - empty on success, error message on failure
  read: [
    data: onRead0:; toSpan;
    (@data.data) (Nat8 Ref) same ~ [data printStack drop "[TcpConnection.read], invalid argument, [Nat8 Span] expected" raiseStaticError] when
    old: IN_READ @states ACQUIRE atomicXor READ_MASK and;
    [old CONNECTED =] "TcpConnection.read: invalid state" assert
    buf: {len: data.size Nat32 cast; buf: data.data storageAddress;};
    flags: 0n32;
    self storageAddress @readDispatcherContext.!context
    @onRead0 @onRead.assign
    IN_READ READING or @states RELEASE atomicXor drop
    # If 'cancelRead' will be called at this point, it is possible that it will not happen in time co cancel the operation.
    # It is a caller responsibility to synchronize 'cancelRead' call with the exit from 'read'.
    WSAOVERLAPPED_COMPLETION_ROUTINERef @readDispatcherContext.@overlapped @flags Nat32 Ref 1n32 @buf connection WSARecv 0 = ~ [
      WSAGetLastError WSA_IO_PENDING = ~ [
        ("WSARecv failed, result=" WSAGetLastError) assembleString
        READING @states RELEASE atomicXor drop
      ] ["" toString] if
    ] ["" toString] if
  ];

  # Try to cancel read
  # input:
  #   NONE
  # output:
  #   isCanceled (Cond) - TRUE if connection was reading, FALSE if connection was not reading or cancel failed
  cancelRead: [
    old: IN_CANCEL_READ @states ACQUIRE atomicXor READ_MASK and;
    [old CONNECTED READING or = [old IN_ON_READ_EVENT CONNECTED or READING or =] || [old CONNECTED =] ||] "TcpConnection.cancelRead: invalid state" assert
    old CONNECTED READING or = ~ [FALSE] [
      # In the unfortunate event when 'onReadEvent' was called at this point, we still call the 'CancelIoEx', but this should not hurt.
      @readDispatcherContext.@overlapped connection CancelIoEx 1 = ~ [
        GetLastError ERROR_NOT_FOUND = ~ [("CancelIoEx failed, result=" GetLastError LF) assembleString print] when # There is no good way to handle this, just report.
        FALSE
      ] [TRUE] if
    ] if

    IN_CANCEL_READ @states RELEASE atomicXor drop
  ];

  # Initiate write
  # input:
  #   data (Nat8 Cref Span) - buffer to write
  #   onWrite (String Ref -- ) - callback to be called when write completed, failed or canceled
  # output:
  #   result (String) - empty on success, error message on failure
  write: [
    data: onWrite0:; toSpan;
    (data.data) (Nat8 Cref) same ~ [data printStack drop "[TcpConnection.write], invalid argument, [Nat8 Cref Span] expected" raiseStaticError] when
    old: IN_WRITE @states ACQUIRE atomicXor WRITE_MASK and;
    [old CONNECTED =] "TcpConnection.write: invalid state" assert
    buf: {len: data.size Nat32 cast; buf: data.data storageAddress;};
    self storageAddress @writeDispatcherContext.!context
    @onWrite0 @onWrite.assign
    IN_WRITE WRITING or @states RELEASE atomicXor drop
    # If 'cancelWrite' will be called at this point, it is possible that it will not happen in time co cancel the operation.
    # It is a caller responsibility to synchronize 'cancelWrite' call with the exit from 'write'.
    WSAOVERLAPPED_COMPLETION_ROUTINERef @writeDispatcherContext.@overlapped 0n32 Nat32 1n32 @buf connection WSASend 0 = ~ [
      WSAGetLastError WSA_IO_PENDING = ~ [
        ("WSASend failed, result=" WSAGetLastError) assembleString
        WRITING @states RELEASE atomicXor drop
      ] ["" toString] if
    ] ["" toString] if
  ];

  # Try to cancel write
  # input:
  #   NONE
  # output:
  #   isCanceled (Cond) - TRUE if connection was writing, FALSE if connection was not writing or cancel failed
  cancelWrite: [
    old: IN_CANCEL_WRITE @states ACQUIRE atomicXor WRITE_MASK and;
    [old CONNECTED WRITING or = [old IN_ON_WRITE_EVENT CONNECTED or WRITING or =] || [old CONNECTED =] ||] "TcpConnection.cancelWrite: invalid state" assert
    old CONNECTED WRITING or = ~ [FALSE] [
      # In the unfortunate event when 'onWriteEvent' was called at this point, we still call the 'CancelIoEx', but this should not hurt.
      @writeDispatcherContext.@overlapped connection CancelIoEx 1 = ~ [
        GetLastError ERROR_NOT_FOUND = ~ [("CancelIoEx failed, result=" GetLastError LF) assembleString print] when # There is no good way to handle this, just report.
        FALSE
      ] [TRUE] if
    ] if

    IN_CANCEL_WRITE @states RELEASE atomicXor drop
  ];

  IN_DIE:              [0x00000001n32];
  IN_IS_CONNECTED:     [0x00000002n32];
  IN_SET:              [0x00000004n32];
  IN_CONNECT:          [0x00000008n32];
  IN_CANCEL_CONNECT:   [0x00000010n32];
  IN_DISCONNECT:       [0x00000020n32];
  IN_READ:             [0x00000040n32];
  IN_CANCEL_READ:      [0x00000080n32];
  IN_WRITE:            [0x00000100n32];
  IN_CANCEL_WRITE:     [0x00000200n32];
  IN_ON_CONNECT_EVENT: [0x00000400n32];
  IN_ON_READ_EVENT:    [0x00000800n32];
  IN_ON_WRITE_EVENT:   [0x00001000n32];
  CONNECTING:          [0x00002000n32];
  CONNECTED:           [0x00004000n32];
  READING:             [0x00008000n32];
  WRITING:             [0x00010000n32];
  COMMON_MASK:         [IN_DIE IN_IS_CONNECTED or IN_SET or IN_CONNECT or IN_CANCEL_CONNECT or IN_DISCONNECT or IN_ON_CONNECT_EVENT or CONNECTING or CONNECTED or];
  READ_MASK:           [COMMON_MASK IN_READ or IN_CANCEL_READ or READING or];
  WRITE_MASK:          [COMMON_MASK IN_WRITE or IN_CANCEL_WRITE or WRITING or];

  states: 0n32;
  connection: Natx;
  readDispatcherContext: dispatcher.Context;
  onRead: ({result: String Ref; numberOfTransferredBytes: Int32;} {} {}) Function;
  writeDispatcherContext: dispatcher.Context;
  onWrite: ({result: String Ref;} {} {}) Function;

  onConnectEvent: [
    numberOfBytesTransferred: error: new;;
    old: IN_ON_CONNECT_EVENT @states ACQUIRE atomicXor;
    [old CONNECTING = [old IN_CANCEL_CONNECT CONNECTING or =] ||] "TcpConnection.onConnectEvent: invalid state" assert
    old IN_CANCEL_CONNECT CONNECTING or = [("TcpConnection.onConnectEvent called before connect or cancelConnect returned - should be extremely rare" LF) assembleString print] [
      result: String;
      transferred: 0n32;
      flags: 0n32;
      @flags 0 @transferred @writeDispatcherContext.@overlapped connection WSAGetOverlappedResult 1 = ~ [WSAGetLastError Nat32 cast !error] [0n32 !error] if
      [transferred numberOfBytesTransferred =] "unexpected transferred size" assert
      error 0n32 = ~ [
        connection closesocket 0 = ~ [("LEAK: closesocket failed, result=" WSAGetLastError LF) assembleString print] when
        error ERROR_OPERATION_ABORTED = ["canceled" toString !result] [("ConnectEx failed, result=" error) assembleString !result] if
        IN_ON_CONNECT_EVENT CONNECTING or
      ] [
        value: 1n32; value storageSize Nat32 cast Int32 cast value storageAddress SO_UPDATE_CONNECT_CONTEXT SOL_SOCKET connection setsockopt 0 = ~ [
          ("setsockopt failed, result=" WSAGetLastError) assembleString !result
          connection closesocket 0 = ~ [("LEAK: closesocket failed, result=" WSAGetLastError LF) assembleString print] when
          IN_ON_CONNECT_EVENT CONNECTING or
        ] [
          0nx @readDispatcherContext.@overlapped.!hEvent
          @onReadEventWrapper @readDispatcherContext.!onEvent
          @onWriteEventWrapper @writeDispatcherContext.!onEvent
          IN_ON_CONNECT_EVENT CONNECTING or CONNECTED or
        ] if
      ] if

      @states RELEASE atomicXor drop
      @result onWrite
    ] if
  ];

  onReadEvent: [
    numberOfBytesTransferred: error: new;;
    old: IN_ON_READ_EVENT @states ACQUIRE atomicXor READ_MASK and;
    [old CONNECTED READING or = [old IN_CANCEL_READ CONNECTED or READING or =] ||] "TcpConnection.onReadEvent: invalid state" assert
    result: String;
    transferred: 0n32;
    flags: 0n32;
    @flags 0 @transferred @readDispatcherContext.@overlapped connection WSAGetOverlappedResult 1 = ~ [WSAGetLastError Nat32 cast !error] [0n32 !error] if
    [transferred numberOfBytesTransferred =] "unexpected transferred size" assert
    error 0n32 = ~ [
      error ERROR_OPERATION_ABORTED = ["canceled" toString !result] [("WSARecv failed, result=" error) assembleString !result] if
    ] when

    IN_ON_READ_EVENT READING or @states RELEASE atomicXor drop
    numberOfBytesTransferred Int32 cast @result onRead
  ];

  onWriteEvent: [
    numberOfBytesTransferred: error: new;;
    old: IN_ON_WRITE_EVENT @states ACQUIRE atomicXor WRITE_MASK and;
    [old CONNECTED WRITING or = [old IN_CANCEL_WRITE CONNECTED or WRITING or =] ||] "TcpConnection.onReadEvent: invalid state" assert
    result: String;
    transferred: 0n32;
    flags: 0n32;
    @flags 0 @transferred @writeDispatcherContext.@overlapped connection WSAGetOverlappedResult 1 = ~ [WSAGetLastError Nat32 cast !error] [0n32 !error] if
    [transferred numberOfBytesTransferred =] "unexpected transferred size" assert
    error 0n32 = ~ [
      error ERROR_OPERATION_ABORTED = ["canceled" toString !result] [("WSASend failed, result=" error) assembleString !result] if
    ] when

    IN_ON_WRITE_EVENT WRITING or @states RELEASE atomicXor drop
    @result onWrite
  ];

  onConnectEventWrapper: [TcpConnection addressToReference .onConnectEvent];
  onReadEventWrapper:    [TcpConnection addressToReference .onReadEvent   ];
  onWriteEventWrapper:   [TcpConnection addressToReference .onWriteEvent  ];
}];

ConnectEx: FN_CONNECTEXRef;
