# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"                   use
"IntrusiveQueue.IntrusiveQueue" use
"Mref.Mref"                     use
"String.printList"              use
"algorithm.cond"                use
"control.&&"                    use
"control.Int32"                 use
"control.Natx"                  use
"control.Real64"                use
"control.Ref"                   use
"control.assert"                use
"control.drop"                  use
"control.failProc"              use
"control.nil?"                  use
"control.when"                  use
"conventions.cdecl"             use
"memory.malloc"                 use

"posix.CLOCK_MONOTONIC" use
"posix.EINTR"           use
"posix.clock_gettime"   use
"posix.getcontext"      use
"posix.makecontext"     use
"posix.swapcontext"     use
"posix.timespec"        use
"posix.ucontext_t"      use

"errno"                use
"linux.EPOLLIN"        use
"linux.EPOLLOUT"       use
"linux.EPOLL_CTL_ADD"  use
"linux.TFD_NONBLOCK"   use
"linux.epoll_create1"  use
"linux.epoll_ctl"      use
"linux.epoll_event"    use
"linux.epoll_wait"     use
"linux.timerfd_create" use

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
    [@self @currentFiber is ~] "attempted to resume current fiber" assert

    oldContext: currentFiber.nativeFiber ucontext_t addressToReference;
    newContext: nativeFiber              ucontext_t addressToReference;

    @self !currentFiber
    @newContext @oldContext swapcontext -1 = [("FATAL: swapcontext failed, result=" errno LF) printList "" failProc] when
  ];

  nativeFiber: Natx;
  next:        [FiberData] Mref; # For reusable fibers: next fiber in the LIFO stack; for resuming fibers: next fiber to resume, FIFO queue
  func:        {data: Natx;} {} {} codeRef;
  funcData:    Natx;
}];

canceled?: [
  currentFiber.canceled?
];

defaultCancelFunc: {data: Natx;} {} {} codeRef; [
  drop "invalid cancelation function" failProc
] !defaultCancelFunc

FiberPair: [{
  readFiber:  FiberData Ref;
  writeFiber: FiberData Ref;
}];

dispatch: [
  fiber: FiberData Ref;

  [
    resumingFibers.empty? [
      event: epoll_event;

      INFINITE_TIMEOUT: [-1];
      MAX_EVENT_COUNT:  [1];

      INFINITE_TIMEOUT MAX_EVENT_COUNT event storageAddress epoll_fd epoll_wait MAX_EVENT_COUNT = [
        fiberPair: event.ptr FiberPair addressToReference;
        result: event.events (
          [EPOLLOUT and 0n32 = ~] [@fiberPair.@writeFiber !fiber TRUE]
          [EPOLLIN  and 0n32 = ~] [@fiberPair.@readFiber  !fiber TRUE]
          [FALSE]
        ) cond;

        [result [result nil?] && ~] "dispatch failed" assert

        result ~
      ] [
        lastErrorNumber: errno;
        lastErrorNumber EINTR = ~ [("FATAL: epoll_wait failed, result=" lastErrorNumber LF) printList "" failProc] when
        TRUE
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

getTimerFd: [
  timer_fd: Int32;
  timers.size 0 = [
    TFD_NONBLOCK CLOCK_MONOTONIC timerfd_create !timer_fd
    timer_fd -1 = [("FATAL: timerfd_create failed, result=" errno LF) printList "" failProc] when
    epoll_event timer_fd EPOLL_CTL_ADD epoll_fd epoll_ctl -1 = [("FATAL: epoll_ctl failed, result=" errno LF) printList "" failProc] when
  ] [
    timers.last new !timer_fd
    @timers.popBack
  ] if

  timer_fd new
];

getTimePrivate: [
  currentTime: timespec;
  @currentTime CLOCK_MONOTONIC clock_gettime -1 = [("FATAL: clock_gettime failed, result=" errno LF) printList "" failProc] when

  NANOSECONDS_TO_SECONDS_MULTIPLIER: [0.000000001r64];

  currentTime.tv_sec initTime.tv_sec - Real64 cast currentTime.tv_nsec initTime.tv_nsec - Real64 cast NANOSECONDS_TO_SECONDS_MULTIPLIER * +
];

allocateObject: [
  element:;

  addr:       element storageSize malloc;
  newElement: addr @element addressToReference;
  @newElement manuallyInitVariable
  @element @newElement set

  @newElement
];

createFiber: [
  creationDataPtr: fiberFunc:;;

  newContext: ucontext_t allocateObject;
  @newContext getcontext -1 = [("FATAL: getcontext failed, result=" errno LF) printList "" failProc] when

  STACK_SIZE: [64 1024 * Natx cast];
  stackPtr:   STACK_SIZE malloc;
  stackPtr new @newContext.@uc_stack.!ss_sp
  STACK_SIZE   @newContext.@uc_stack.!ss_size

  {data: creationDataPtr new;} 1 @fiberFunc storageAddress @newContext makecontext

  newContext storageAddress
];

emptyCancelFunc: {data: Natx;} {} {} codeRef; [
  drop
] !emptyCancelFunc

spawnFiber: [
  funcData: func:;;

  reusableFibers.empty? [
    creationData: {nativeFiber: Natx; func: @func; funcData: funcData;};
    fiberFunc:    {data: Natx;} {} {convention: cdecl;} codeRef; [
      creationData: creationData addressToReference;
      data:         FiberData;

      creationData.nativeFiber new @data.!nativeFiber
      creationData.@func           @data.!func
      creationData.funcData    new @data.!funcData
      @data !currentFiber
      [
        data.funcData data.@func
        @emptyCancelFunc @data.!func
        call
        TRUE dynamic
      ] loop
    ] !fiberFunc

    creationData storageAddress @fiberFunc createFiber @creationData.!nativeFiber

    newContext: creationData.nativeFiber ucontext_t addressToReference;
    oldContext: currentFiber.nativeFiber ucontext_t addressToReference;
    @newContext @oldContext swapcontext -1 = [("FATAL: swapcontext failed, result=" errno LF) printList "" failProc] when
  ] [
    fiber: @reusableFibers.popFirst;
    funcData @func @fiber.setFunc
    @fiber.switchTo
  ] if
];

epoll_fd:       Int32;
currentFiber:   FiberData Ref;
rootFiber:      FiberData;
resumingFibers: FiberData IntrusiveQueue;
reusableFibers: FiberData IntrusiveQueue;
timers:         Int32 Array;
initTime:       timespec;

[
  0 epoll_create1 !epoll_fd
  epoll_fd -1 = [("FATAL: epoll_create1 failed, result=" errno LF) printList "" failProc] when

  @initTime CLOCK_MONOTONIC clock_gettime -1 = [("FATAL: clock_gettime failed, result=" errno LF) printList "" failProc] when

  rootContext: ucontext_t allocateObject;
  rootContext storageAddress @rootFiber.!nativeFiber
  @rootContext getcontext -1 = [("FATAL: getcontext failed, result=" errno LF) printList "" failProc] when
  @defaultCancelFunc @rootFiber.!func
  @rootFiber !currentFiber
] call
