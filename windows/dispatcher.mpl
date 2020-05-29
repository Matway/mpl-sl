"String.assembleString" use
"String.print" use
"control.Nat32" use
"control.Natx" use
"control.assert" use
"control.exit" use
"control.isNil" use
"control.when" use
"kernel32.kernel32" use
"ws2_32.winsock2" use

dispatcherInternal: {
  OnCallback: [{context: Natx;} {} {} codeRef];
  OnEventRef: [{context: Natx; numberOfBytesTransferred: Nat32; error: Nat32;} {} {} codeRef];

  Context: [{
    overlapped: kernel32.OVERLAPPED;
    onEvent: OnEventRef;
    context: Natx;
  }];

  DIE: [
    winsock2.WSACleanup 0 = ~ [("LEAK: WSACleanup failed, result=" winsock2.WSAGetLastError LF) assembleString print] when
    completionPort kernel32.CloseHandle 1 = ~ [("LEAK: CloseHandle failed, result=" kernel32.GetLastError LF) assembleString print] when
  ];

  init: [
    0n32 0nx 0nx kernel32.INVALID_HANDLE_VALUE kernel32.CreateIoCompletionPort !completionPort completionPort 0nx = [
      ("FATAL: CreateIoCompletionPort failed, result=" kernel32.GetLastError LF) assembleString print 1 exit
    ] when

    wsaData: winsock2.WSADATA; result: @wsaData 0x0202n16 winsock2.WSAStartup; result 0 = ~ [
      ("FATAL: WSAStartup failed, result=" result LF) assembleString print 1 exit
    ] when
  ];

  dispatch: [
    entry: kernel32.OVERLAPPED_ENTRY;
    actual: Nat32;
    1 kernel32.INFINITE @actual 1n32 @entry completionPort kernel32.GetQueuedCompletionStatusEx 1 = ~ [
      error: kernel32.GetLastError;
      ("FATAL: GetQueuedCompletionStatusEx failed, result=" error LF) assembleString print 1 exit
    ] [
      [actual 1n32 =] "unexpected actual entry count" assert
      entry.lpCompletionKey 0nx = [
        [entry.dwNumberOfBytesTransferred entry.lpOverlapped.InternalHigh Nat32 cast =] "unexpected transferred size" assert
        context: entry.lpOverlapped storageAddress Context addressToReference;
        entry.dwNumberOfBytesTransferred entry.lpOverlapped.Internal Nat32 cast context.context context.onEvent
      ] [
        entry.lpOverlapped storageAddress entry.lpCompletionKey {context: Natx;} {} {} codeRef addressToReference call
      ] if
    ] if
  ];

  tryDispatch: [
    entry: kernel32.OVERLAPPED_ENTRY;
    actual: Nat32;
    1 0n32 @actual 1n32 @entry completionPort kernel32.GetQueuedCompletionStatusEx 1 = ~ [
      error: kernel32.GetLastError;
      error kernel32.WAIT_TIMEOUT = ~ [
        ("FATAL: GetQueuedCompletionStatusEx failed, result=" error LF) assembleString print 1 exit
      ] when
    ] [
      [actual 1n32 =] "unexpected actual entry count" assert
      entry.lpCompletionKey 0nx = [
        [entry.dwNumberOfBytesTransferred entry.lpOverlapped.InternalHigh Nat32 cast =] "unexpected transferred size" assert
        context: entry.lpOverlapped storageAddress Context addressToReference;
        entry.dwNumberOfBytesTransferred entry.lpOverlapped.Internal Nat32 cast context.context context.onEvent
      ] [
        entry.lpOverlapped storageAddress entry.lpCompletionKey {context: Natx;} {} {} codeRef addressToReference call
      ] if
    ] if
  ];

  post: [
    context: callback:;;
    [@callback isNil ~] "dispatcher.post: invalid callback" assert
    context kernel32.OVERLAPPED addressToReference @callback storageAddress 0n32 completionPort kernel32.PostQueuedCompletionStatus 1 = ~ [
      ("FATAL: PostQueuedCompletionStatus failed, result=" kernel32.GetLastError LF) assembleString print 1 exit
    ] when
  ];

  wakeOne: [
    nop: OnCallback;
    [drop] !nop
    0nx @nop post
  ];

  completionPort: Natx;
};

@dispatcherInternal.init

dispatcher: [dispatcherInternal];
