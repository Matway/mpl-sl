# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.assembleString" use
"String.print"          use
"control.Nat32"         use
"control.Natx"          use
"control.assert"        use
"control.exit"          use
"control.nil?"          use
"control.when"          use

"kernel32.CloseHandle"                 use
"kernel32.CreateIoCompletionPort"      use
"kernel32.GetLastError"                use
"kernel32.GetQueuedCompletionStatusEx" use
"kernel32.INVALID_HANDLE_VALUE"        use
"kernel32.OVERLAPPED"                  use
"kernel32.OVERLAPPED_ENTRY"            use
"kernel32.PostQueuedCompletionStatus"  use
"kernel32.WAIT_TIMEOUT"                use
"ws2_32.WSACleanup"                    use
"ws2_32.WSADATA"                       use
"ws2_32.WSAGetLastError"               use
"ws2_32.WSAStartup"                    use

dispatcherInternal: {
  OnCallback: [{context: Natx;} {} {} codeRef];
  OnEventRef: [{context: Natx; numberOfBytesTransferred: Nat32; error: Nat32;} {} {} codeRef];

  Context: [{
    overlapped: OVERLAPPED;
    onEvent: OnEventRef;
    context: Natx;
  }];

  DIE: [
    WSACleanup 0 = ~ [("LEAK: WSACleanup failed, result=" WSAGetLastError LF) assembleString print] when
    completionPort CloseHandle 1 = ~ [("LEAK: CloseHandle failed, result=" GetLastError LF) assembleString print] when
  ];

  init: [
    0n32 0nx 0nx INVALID_HANDLE_VALUE CreateIoCompletionPort !completionPort completionPort 0nx = [
      ("FATAL: CreateIoCompletionPort failed, result=" GetLastError LF) assembleString print 1 exit
    ] when

    wsaData: WSADATA; result: @wsaData 0x0202n16 WSAStartup; result 0 = ~ [
      ("FATAL: WSAStartup failed, result=" result LF) assembleString print 1 exit
    ] when
  ];

  dispatch: [
    entry: OVERLAPPED_ENTRY;
    actual: Nat32;
    1 INFINITE @actual 1n32 @entry completionPort GetQueuedCompletionStatusEx 1 = ~ [
      error: GetLastError;
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
    entry: OVERLAPPED_ENTRY;
    actual: Nat32;
    1 0n32 @actual 1n32 @entry completionPort GetQueuedCompletionStatusEx 1 = ~ [
      error: GetLastError;
      error WAIT_TIMEOUT = ~ [
        ("FATAL: GetQueuedCompletionStatusEx failed, result=" error LF) assembleString print 1 exit
      ] when

      FALSE
    ] [
      [actual 1n32 =] "unexpected actual entry count" assert
      entry.lpCompletionKey 0nx = [
        [entry.dwNumberOfBytesTransferred entry.lpOverlapped.InternalHigh Nat32 cast =] "unexpected transferred size" assert
        context: entry.lpOverlapped storageAddress Context addressToReference;
        entry.dwNumberOfBytesTransferred entry.lpOverlapped.Internal Nat32 cast context.context context.onEvent
      ] [
        entry.lpOverlapped storageAddress entry.lpCompletionKey {context: Natx;} {} {} codeRef addressToReference call
      ] if

      TRUE
    ] if
  ];

  post: [
    context: callback:;;
    [@callback nil? ~] "dispatcher.post: invalid callback" assert
    context OVERLAPPED addressToReference @callback storageAddress 0n32 completionPort PostQueuedCompletionStatus 1 = ~ [
      ("FATAL: PostQueuedCompletionStatus failed, result=" GetLastError LF) assembleString print 1 exit
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
