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

"posix.CLOCK_BOOTTIME" use
"posix.EINTR"          use
"posix.getcontext"     use
"posix.makecontext"    use
"posix.swapcontext"    use
"posix.ucontext_t"     use

"errno.errno"          use
"linux.EPOLLIN"        use
"linux.EPOLLOUT"       use
"linux.EPOLL_CTL_ADD"  use
"linux.TFD_NONBLOCK"   use
"linux.epoll_create1"  use
"linux.epoll_ctl"      use
"linux.epoll_event"    use
"linux.epoll_wait"     use
"linux.timerfd_create" use

UNDER_VALGRIND: [FALSE];
UNDER_VALGRIND: [SL_SYNC_UNDER_VALGRIND TRUE] [
  SL_SYNC_UNDER_VALGRIND {} same [SL_SYNC_UNDER_VALGRIND] ||
] pfunc;

{
  default: Nat64;
  request: Nat64;
  arg1:    Nat64;
  arg2:    Nat64;
  arg3:    Nat64;
  arg4:    Nat64;
  arg5:    Nat64;
} Nat64 {} "valgrind_client_request" importFunction

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

createFiber: [
  creationDataPtr: fiberFunc:;;

  ucontext: makeUcontext;
  @ucontext getcontext -1 = [("FATAL: getcontext failed, result=" errno LF) printList "" failProc] when

  STACK_SIZE: [64 1024 * Natx cast];
  STACK_SIZE malloc @ucontext.@uc_stack.!ss_sp
  STACK_SIZE        @ucontext.@uc_stack.!ss_size

  UNDER_VALGRIND [
    VALGRIND_STACK_REGISTER: [0x1501n64];
    offset0: stackPtr Nat64 cast;
    offset1: STACK_SIZE Nat64 cast offset0 +;
    0n64 0n64 0n64 offset1 offset0 VALGRIND_STACK_REGISTER 0n64 valgrind_client_request drop
  ] when

  (creationDataPtr new) 1 @fiberFunc storageAddress @ucontext makecontext

  ucontext storageAddress
];

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

        [result [fiber nil?] && ~] "dispatch failed" assert

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

  fiber currentFiber is ~ [
    @fiber.switchTo
  ] when
];

emptyCancelFunc: {data: Natx;} {} {} codeRef; [
  drop
] !emptyCancelFunc

getTimerFd: [
  timer_fd: Int32;
  timers.size 0 = [
    TFD_NONBLOCK CLOCK_BOOTTIME timerfd_create !timer_fd
    timer_fd -1 = [("FATAL: timerfd_create failed, result=" errno LF) printList "" failProc] when
    epoll_event timer_fd EPOLL_CTL_ADD epoll_fd epoll_ctl -1 = [("FATAL: epoll_ctl failed, result=" errno LF) printList "" failProc] when
  ] [
    timers.last new !timer_fd
    @timers.popBack
  ] if

  timer_fd new
];

makeUcontext: [ucontext_t dup dup storageSize malloc swap addressToReference [set] keep];

spawnFiber: [
  funcData: func:;;

  reusableFibers.empty? [
    creationData: {nativeFiber: Natx; func: @func; funcData: funcData;};
    CreationDataType: creationData Ref virtual;
    fiberFunc:    {data: Natx;} {} {convention: cdecl;} codeRef; [
      creationData: CreationDataType addressToReference;
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

    creationData.nativeFiber ucontext_t addressToReference
    currentFiber.nativeFiber ucontext_t addressToReference
    swapcontext -1 = [("FATAL: swapcontext failed, result=" errno LF) printList "" failProc] when
  ] [
    fiber: @reusableFibers.popFirst;
    funcData @func @fiber.setFunc
    @fiber.switchTo
  ] if
];

currentFiber:   FiberData Ref;
epoll_fd:       Int32;
rootFiber:      FiberData;
resumingFibers: FiberData IntrusiveQueue;
reusableFibers: FiberData IntrusiveQueue;
timers:         Int32 Array;

[
  0 epoll_create1 !epoll_fd
  epoll_fd -1 = [("FATAL: epoll_create1 failed, result=" errno LF) printList "" failProc] when

  rootContext: makeUcontext;
  rootContext storageAddress @rootFiber.!nativeFiber
  @rootContext getcontext -1 = [("FATAL: getcontext failed, result=" errno LF) printList "" failProc] when
  @defaultCancelFunc @rootFiber.!func
  @rootFiber !currentFiber
] call
