"IntrusiveQueue.IntrusiveQueue" use
"Mref.Mref" use
"String.printList" use
"control.Int64" use
"control.Nat32" use
"control.Nat64" use
"control.Natx" use
"control.Real64" use
"control.Ref" use
"control.assert" use
"control.drop" use
"control.dup" use
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

TimerData: [{
  fiber: FiberData Ref;
  next: [TimerData] Mref;
  time: Real64;
}];

canceled?: [
  currentFiber.canceled?
];

defaultCancelFunc: {data: Natx;} {} {} codeRef; [
  drop "invalid cancelation function" failProc
] !defaultCancelFunc

dispatch: [
  fiber: FiberData Ref;

  [
    timeout: kernel32.INFINITE;
    timers.empty? ~ [
      time: getTimePrivate;

      [
        delta: timers.first.time time -;
        delta 0.0 > [
          delta 1000.0 * ceil Nat32 cast !timeout
          FALSE
        ] [
          @timers.popFirst.@fiber @resumingFibers.append
          timers.empty? ~
        ] if
      ] loop
    ] when

    resumingFibers.empty? [
      entry: kernel32.OVERLAPPED_ENTRY;
      actual: Nat32;
      1 timeout @actual 1n32 @entry completionPort kernel32.GetQueuedCompletionStatusEx 1 = ~ dup [
        lastError: kernel32.GetLastError;
        lastError kernel32.WAIT_TIMEOUT = ~ [("FATAL: GetQueuedCompletionStatusEx failed, result=" lastError LF) printList "" failProc] when
      ] [
        [actual 1n32 =] "unexpected actual entry count" assert
        [entry.dwNumberOfBytesTransferred entry.lpOverlapped.InternalHigh Nat32 cast =] "unexpected transferred size" assert

        SyncOverlapped: [{
          overlapped: kernel32.OVERLAPPED;
          fiber: FiberData Ref;
        }];

        syncOverlapped: entry.lpOverlapped storageAddress SyncOverlapped addressToReference;
        @syncOverlapped.@fiber !fiber
      ] if
    ] [
      @resumingFibers.popFirst !fiber
      FALSE
    ] if
  ] loop

  @fiber @currentFiber is ~ [
    @fiber.switchTo
  ] when
];

emptyCancelFunc: {data: Natx;} {} {} codeRef; [
  drop
] !emptyCancelFunc

getTimePrivate: [
  previousCounter0: timePreviousCounter copy;
  @timePreviousCounter storageAddress Int64 addressToReference kernel32.QueryPerformanceCounter drop
  timePreviousCounter previousCounter0 - Real64 cast timeMultiplier * timePreviousTime + !timePreviousTime
  timePreviousTime copy
];

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
timeMultiplier: Real64;
timePreviousCounter: Nat64;
timePreviousTime: Real64;
currentFiber: FiberData Ref;
reusableFibers: FiberData IntrusiveQueue;
resumingFibers: FiberData IntrusiveQueue;
timers: TimerData IntrusiveQueue;

[
  0nx kernel32.ConvertThreadToFiber @rootFiber.!nativeFiber rootFiber.nativeFiber 0nx = [("FATAL: ConvertThreadToFiber failed, result=" kernel32.GetLastError LF) printList "" failProc] when
  @defaultCancelFunc @rootFiber.!func
  0n32 0nx 0nx kernel32.INVALID_HANDLE_VALUE kernel32.CreateIoCompletionPort !completionPort completionPort 0nx = [("FATAL: CreateIoCompletionPort failed, result=" kernel32.GetLastError LF) printList "" failProc] when
  result: winsock2.WSADATA 0x0202n16 winsock2.WSAStartup; result 0 = ~ [("FATAL: WSAStartup failed, result=" result LF) printList "" failProc] when

  frequency: Int64;
  @frequency kernel32.QueryPerformanceFrequency drop
  1.0 frequency Real64 cast / !timeMultiplier
  @timePreviousCounter storageAddress Int64 addressToReference kernel32.QueryPerformanceCounter drop
  0.0 !timePreviousTime

  @rootFiber !currentFiber
] call
