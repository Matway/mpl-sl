"IntrusiveQueue.IntrusiveQueue" use
"Mref.Mref" use
"String.printList" use
"control.Nat32" use
"control.Natx" use
"control.Ref" use
"control.assert" use
"control.drop" use
"control.failProc" use
"control.isNil" use
"control.when" use

"kernel32.kernel32" use
"ws2_32.winsock2" use

FiberData: [{
  canceled?: [@func isNil];

  cancel: [
    canceled? ~ [
      funcData @func
      {data: Natx;} {} {} codeRef !func
      call
    ] when
  ];

  setFunc: [
    !func copy !funcData
  ];

  switchTo: [
    [self currentFiber is ~] "attempted to resume current fiber" assert
    @self !currentFiber
    nativeFiber kernel32.SwitchToFiber
  ];

  nativeFiber: Natx;
  next: [FiberData] Mref; # For reusable fibers: next fiber in the LIFO stack; for resuming fibers: next fiber to resume, FIFO queue
  func: {data: Natx;} {} {} codeRef;
  funcData: Natx;
}];

canceled?: [
  currentFiber.canceled?
];

defaultCancelFunc: {data: Natx;} {} {} codeRef; [
  drop "invalid cancelation function" failProc
] !defaultCancelFunc

dispatch: [
  resumingFibers.empty? [
    entry: kernel32.OVERLAPPED_ENTRY;
    actual: Nat32;
    1 kernel32.INFINITE @actual 1n32 @entry completionPort kernel32.GetQueuedCompletionStatusEx 1 = ~ [
      ("FATAL: GetQueuedCompletionStatusEx failed, result=" kernel32.GetLastError LF) printList "" failProc
    ] [
      [actual 1n32 =] "unexpected actual entry count" assert
      [entry.dwNumberOfBytesTransferred entry.lpOverlapped.InternalHigh Nat32 cast =] "unexpected transferred size" assert

      SyncOverlapped: [{
        overlapped: kernel32.OVERLAPPED;
        fiber: FiberData Ref;
      }];

      syncOverlapped: entry.lpOverlapped storageAddress SyncOverlapped addressToReference;
      syncOverlapped.fiber currentFiber is ~ [
        @syncOverlapped.@fiber.switchTo
      ] when
    ] if
  ] [
    @resumingFibers.popFirst.switchTo
  ] if
];

emptyCancelFunc: {data: Natx;} {} {} codeRef; [
  drop
] !emptyCancelFunc

spawnFiber: [
  funcData: func:;;
  reusableFibers.empty? [
    fiberFunc: [
      creationData: creationData addressToReference;
      data: FiberData;
      creationData.nativeFiber copy @data.!nativeFiber
      creationData.@func @data.!func
      creationData.funcData copy @data.!funcData
      @data !currentFiber

      [
        data.funcData data.@func
        @emptyCancelFunc @data.!func
        call
        TRUE dynamic
      ] loop
    ];

    creationData: {nativeFiber: Natx; func: @func; funcData: funcData;};
    creationData storageAddress @fiberFunc 4096nx kernel32.CreateFiber @creationData.!nativeFiber creationData.nativeFiber 0nx = [("FATAL: CreateFiber failed, result=" kernel32.GetLastError LF) printList "" failProc] when
    creationData.nativeFiber kernel32.SwitchToFiber
  ] [
    fiber: @reusableFibers.popFirst;
    funcData @func @fiber.setFunc
    @fiber.switchTo
  ] if
];

rootFiber: FiberData;
completionPort: Natx;
currentFiber: FiberData Ref;
reusableFibers: FiberData IntrusiveQueue;
resumingFibers: FiberData IntrusiveQueue;

[
  0nx kernel32.ConvertThreadToFiber @rootFiber.!nativeFiber rootFiber.nativeFiber 0nx = [("FATAL: ConvertThreadToFiber failed, result=" kernel32.GetLastError LF) printList "" failProc] when
  0n32 0nx 0nx kernel32.INVALID_HANDLE_VALUE kernel32.CreateIoCompletionPort !completionPort completionPort 0nx = [("FATAL: CreateIoCompletionPort failed, result=" kernel32.GetLastError LF) printList "" failProc] when
  result: winsock2.WSADATA 0x0202n16 winsock2.WSAStartup; result 0 = ~ [("FATAL: WSAStartup failed, result=" result LF) printList "" failProc] when
  @defaultCancelFunc @rootFiber.!func
  @rootFiber !currentFiber
] call
