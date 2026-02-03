# Copyright (C) Matway Burkow
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
"control.Nat32"                 use
"control.Nat64"                 use
"control.Natx"                  use
"control.Ref"                   use
"control.assert"                use
"control.drop"                  use
"control.dup"                   use
"control.failProc"              use
"control.keep"                  use
"control.nil?"                  use
"control.pfunc"                 use
"control.swap"                  use
"control.when"                  use
"control.||"                    use
"conventions.cdecl"             use
"memory.malloc"                 use

"macos.EVFILT_READ"   use
"macos.EVFILT_TIMER"  use
"macos.EVFILT_WRITE"  use
"macos.kevent"        use
"macos.kqueue"        use
"macos.struct_kevent" use

"posix.CLOCK_BOOTTIME" use
"posix.EINTR"          use
"posix.getcontext"     use
"posix.makecontext"    use
"posix.swapcontext"    use
"posix.timespec"       use
"posix.ucontext_t"     use

"errno.errno" use

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
  next:        [FiberData] Mref;
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

createFiber: [
  creationDataPtr: fiberFunc:;;

  ucontext: makeUcontext;
  @ucontext getcontext -1 = [("FATAL: getcontext failed, result=" errno LF) printList "" failProc] when

  STACK_SIZE: [64 1024 * Natx cast];
  STACK_SIZE malloc     @ucontext.@uc_stack.!ss_sp
  STACK_SIZE Nat64 cast @ucontext.@uc_stack.!ss_size

  # split creationDataPtr (Natx) into two Ints
  arg1: creationDataPtr storageAddress                     Int32 addressToReference;
  arg2: creationDataPtr storageAddress Int32 storageSize + Int32 addressToReference;

  {arg1: arg1 new; arg2: arg2 new;} 2 @fiberFunc storageAddress @ucontext makecontext

  ucontext storageAddress
];

dispatch: [
  fiber: FiberData Ref;

  [
    resumingFibers.empty? [
      MAX_EVENT_COUNT: [1];
      event: struct_kevent;
      timespec Ref 0n32 MAX_EVENT_COUNT @event 0 struct_kevent Ref kqueue_fd kevent -1 = [
        lastErrorNumber: errno;
        lastErrorNumber EINTR = ~ [("FATAL: [dispatch] kevent failed, result=" lastErrorNumber LF) printList "" failProc] when
        TRUE
      ] [
        fiberPair: event.udata Natx cast FiberPair addressToReference;
        result: event.filter (
          [EVFILT_READ =] [@fiberPair.@readFiber !fiber TRUE]
          [EVFILT_TIMER =] [@fiberPair.@readFiber !fiber TRUE]
          [EVFILT_WRITE =] [@fiberPair.@writeFiber !fiber TRUE]
          [FALSE]
        ) cond;

        [result [fiber nil?] && ~] "dispatch failed" assert

        result ~
      ] if
    ] [
      @resumingFibers.popFirst !fiber
      FALSE
    ] if
  ] loop
  fiber currentFiber is ~ [
    @fiber.switchTo
  ] when
];

emptyCancelFunc: {data: Natx;} {} {} codeRef; [
  drop
] !emptyCancelFunc

lastTimer: 1nx;

getTimerFd: [
  timer_fd: Natx;
  timers.size 0 = [
    lastTimer new !timer_fd
    lastTimer 1nx + !lastTimer
  ] [
    timers.last new !timer_fd
    @timers.popBack
  ] if
  timer_fd
];

makeUcontext: [ucontext_t dup dup storageSize malloc swap addressToReference [set] keep];

spawnFiber: [
  funcData: func:;;

  reusableFibers.empty? [
    creationData: {nativeFiber: Natx; func: @func; funcData: funcData;};
    fiberFunc: {arg1: Int32; arg2: Int32;} {} {convention: cdecl;} codeRef; [
      arg2: arg1:;;
      creationDataPtr: 0nx;

      arg1 @creationDataPtr storageAddress                     Int32 addressToReference set
      arg2 @creationDataPtr storageAddress Int32 storageSize + Int32 addressToReference set

      creationData: creationDataPtr creationData addressToReference;
      data: FiberData;

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

    @creationData.@nativeFiber ucontext_t addressToReference
    @currentFiber.@nativeFiber ucontext_t addressToReference
    swapcontext -1 = [("FATAL: swapcontext failed, result=" errno LF) printList "" failProc] when
  ] [
    fiber: @reusableFibers.popFirst;
    funcData @func @fiber.setFunc
    @fiber.switchTo
  ] if
];

currentFiber:   FiberData Ref;
kqueue_fd:      Int32;
rootFiber:      FiberData;
resumingFibers: FiberData IntrusiveQueue;
reusableFibers: FiberData IntrusiveQueue;
timers:         Natx Array;

[
  kqueue !kqueue_fd
  kqueue_fd -1 = [("In [syncPrivate]: FATAL: kqueue failed, result=" errno LF) printList "" failProc] when

  rootContext: makeUcontext;
  rootContext storageAddress @rootFiber.!nativeFiber
  @rootContext getcontext -1 = [("FATAL: getcontext failed, result=" errno LF) printList "" failProc] when
  @defaultCancelFunc @rootFiber.!func
  @rootFiber !currentFiber
] call
