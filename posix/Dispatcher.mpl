"FiberBackend.FiberBackend"     use
"IntrusiveQueue.IntrusiveQueue" use
"control.Natx"                  use
"control.nil?"                  use
"control.when"                  use
"errno.errno"                   use
"interface"                     use
"posix"                         use

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

Dispatcher: [{
  private resumingFibers: FiberData IntrusiveQueue;
  private currentContext: ucontext_t;
  backend: FiberBackend;

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

      creationData.nativeFiber ucontext_t addressToReference
      currentFiber.nativeFiber ucontext_t addressToReference
      swapcontext -1 = [("FATAL: swapcontext failed, result=" errno LF) printList "" failProc] when
    ] [
      fiber: @reusableFibers.popFirst;
      funcData @func @fiber.setFunc
      @fiber.switchTo
    ] if
  ];
  resume: [
    self: Dispatcher Ref;
    fiber: FiberData;
    [fiber.context addressToReference @self.currentContext addressToReference swapcontext drop] call
  ];

  dispatch: [
    self: Dispatcher Ref;
    [@self.resumingFibers empty? ~] [
      @self.resumingFibers pop !fiber
      @self @fiber resume call
      @self.backend waitForEvent drop
    ] while
  ];

  register: [
    self: Dispatcher Ref;
    fd: Int32;
    userData: Natx;
    read: Bool;
    write: Bool;
    @self.backend registerFD fd userData read write drop
  ];
}];
