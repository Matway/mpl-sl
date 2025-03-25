# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"IntrusiveQueue.IntrusiveQueue" use
"Mref.Mref"                     use
"String.String"                 use
"String.assembleString"         use
"String.addTerminator"          use
"String.makeStringView"         use
"String.printList"              use
"String.toString"               use
"algorithm.cond0"               use
"control.AsRef"                 use
"control.Int64"                 use
"control.Cref"                  use
"control.Nat32"                 use
"control.Nat64"                 use
"control.Natx"                  use
"control.Real64"                use
"control.Ref"                   use
"control.assert"                use
"control.drop"                  use
"control.dup"                   use
"control.failProc"              use
"control.nil?"                  use
"control.swap"                  use
"control.reinterpret"           use
"control.times"                 use
"control.when"                  use
"control.while"                 use
"unicode.utf16"                 use

"kernel32.ConvertThreadToFiber"        use
"kernel32.CreateFiber"                 use
"kernel32.CreateIoCompletionPort"      use
"kernel32.GetLastError"                use
"kernel32.GetQueuedCompletionStatusEx" use
"kernel32.INFINITE"                    use
"kernel32.INVALID_HANDLE_VALUE"        use
"kernel32.OVERLAPPED"                  use
"kernel32.OVERLAPPED_ENTRY"            use
"kernel32.QueryPerformanceCounter"     use
"kernel32.QueryPerformanceFrequency"   use
"kernel32.PostQueuedCompletionStatus"  use
"kernel32.SwitchToFiber"               use
"kernel32.WAIT_TIMEOUT"                use
"ws2_32.ADDRINFOEXW"                   use
"ws2_32.AF_INET"                       use
"ws2_32.FreeAddrInfoExW"               use
"ws2_32.GetAddrInfoExCancel"           use
"ws2_32.GetAddrInfoExW"                use
"ws2_32.IPPROTO_TCP"                   use
"ws2_32.NS_DNS"                        use
"ws2_32.SOCK_STREAM"                   use
"ws2_32.WSA_IO_PENDING"                use
"ws2_32.WSADATA"                       use
"ws2_32.WSAStartup"                    use
"ws2_32.ntohl"                         use
"ws2_32.sockaddr_in"                   use

FiberData: [{
  canceled?: [@func nil?];

  cancel: [
    canceled? ~ [
      funcData @func
      {data: Natx;} {} {} codeRef !func
      call
    ] when
  ];

  setFunc: [
    !func new !funcData
  ];

  switchTo: [
    [self currentFiber is ~] "attempted to resume current fiber" assert
    @self !currentFiber
    nativeFiber SwitchToFiber
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
    timeout: INFINITE;
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
      entry: OVERLAPPED_ENTRY;
      actual: Nat32;
      1 timeout @actual 1n32 @entry completionPort GetQueuedCompletionStatusEx 1 = ~ dup [
        lastError: GetLastError;
        lastError WAIT_TIMEOUT = ~ [("FATAL: GetQueuedCompletionStatusEx failed, result=" lastError LF) printList "" failProc] when
      ] [
        [actual 1n32 =] "unexpected actual entry count" assert
        [entry.dwNumberOfBytesTransferred entry.lpOverlapped.InternalHigh Nat32 cast =] "unexpected transferred size" assert

        SyncOverlapped: [{
          overlapped: OVERLAPPED;
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
  previousCounter0: timePreviousCounter new;
  @timePreviousCounter storageAddress Int64 addressToReference QueryPerformanceCounter drop
  timePreviousCounter previousCounter0 - Real64 cast timeMultiplier * timePreviousTime + !timePreviousTime
  timePreviousTime new
];

spawnFiber: [
  funcData: func:;;
  reusableFibers.empty? [
    fiberFunc: [
      creationData: creationData addressToReference;
      data: FiberData;
      creationData.nativeFiber new @data.!nativeFiber
      creationData.@func @data.!func
      creationData.funcData new @data.!funcData
      @data !currentFiber

      [
        data.funcData data.@func
        @emptyCancelFunc @data.!func
        call
        TRUE dynamic
      ] loop
    ];

    creationData: {nativeFiber: Natx; func: @func; funcData: funcData;};
    creationData storageAddress @fiberFunc 4096nx CreateFiber @creationData.!nativeFiber creationData.nativeFiber 0nx = [("FATAL: CreateFiber failed, result=" GetLastError LF) printList "" failProc] when
    creationData.nativeFiber SwitchToFiber
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
  0nx ConvertThreadToFiber @rootFiber.!nativeFiber rootFiber.nativeFiber 0nx = [("FATAL: ConvertThreadToFiber failed, result=" GetLastError LF) printList "" failProc] when
  @defaultCancelFunc @rootFiber.!func
  0n32 0nx 0nx INVALID_HANDLE_VALUE CreateIoCompletionPort !completionPort completionPort 0nx = [("FATAL: CreateIoCompletionPort failed, result=" GetLastError LF) printList "" failProc] when
  result: WSADATA 0x0202n16 WSAStartup; result 0 = ~ [("FATAL: WSAStartup failed, result=" result LF) printList "" failProc] when

  frequency: Int64;
  @frequency QueryPerformanceFrequency drop
  1.0 frequency Real64 cast / !timeMultiplier
  @timePreviousCounter storageAddress Int64 addressToReference QueryPerformanceCounter drop
  0.0 !timePreviousTime

  @rootFiber !currentFiber
] call

resolveHost0: [
  name: utf16;

  completion: [
    context: _: dwError:;; @ContextSchema reinterpret;
    dwError new @context.!error
    @context.@overlapped 0nx 0n32 completionPort new PostQueuedCompletionStatus 0 = [
      ("FATAL: PostQueuedCompletionStatus failed, result=" GetLastError LF) printList "" failProc
    ] when
  ];

  context: {
    overlapped:   OVERLAPPED;
    fiber:        @currentFiber;
    cancelHandle: Natx;
    error:        Nat32;
  };

  ContextSchema: @context ;

  hints: ADDRINFOEXW;
  AF_INET     @hints.!ai_family
  SOCK_STREAM @hints.!ai_socktype
  IPPROTO_TCP @hints.!ai_protocol

  hosts: ADDRINFOEXW AsRef;

  canceled? ~ [
    status:
      @context.@cancelHandle
      @completion
      @context.@overlapped
      0nx
      @hosts
      @hints
      0nx
      NS_DNS
      0nx
      name.data storageAddress
      GetAddrInfoExW
    ;

    (
      [status WSA_IO_PENDING =] [
        context storageAddress [
          context: @ContextSchema addressToReference;
          status: @context.@cancelHandle GetAddrInfoExCancel;
          status 0 = ~ [
            ("FATAL: GetAddrInfoExCancel failed, result=" status LF) printList "" failProc
          ] when
        ] @currentFiber.setFunc
        dispatch
        canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
        context.error 0n32 = [String] [
          ("??? failed, result = " context.error) assembleString
        ] if
      ]

      [status 0 =] [String]

      [("GetAddrInfoExW failed, result = " status) assembleString]
    ) cond0
  ] ["canceled" toString] if

  {
    SCHEMA_NAME: "ResolveIpv4HostsIter" virtual;

    root:   hosts;
    source: hosts;

    next: [
      source nil? ~ [
        source.ai_addr sockaddr_in Cref addressToReference .sin_addr new ntohl
        TRUE
        @source.ai_next ADDRINFOEXW addressToReference !source
      ] [Nat32 FALSE] if
    ];

    DIE: [
      root nil? ~ [
        @root FreeAddrInfoExW
      ] when
    ];
  } swap
];