"IntrusiveQueue.IntrusiveQueue" use
"control.assert" use
"control.isNil" use
"control.when" use

"syncPrivate.FiberData" use
"syncPrivate.canceled?" use
"syncPrivate.currentFiber" use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch" use
"syncPrivate.resumingFibers" use

Signal: [{
  INIT: [];

  DIE: [
    [fibers.empty?] "some fibers left sleeping" assert
  ];

  wait: [
    canceled? ~ [
      [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert
      @currentFiber @fibers.append
      data: {fibers: @fibers; fiber: @currentFiber;}; data storageAddress [
        data: @data addressToReference;
        # Cancelation is considered a rare operation, so O(n) complexity is not a problem here
        # It is possible that the current fiber was already removed from the linked list by calling wake/wakeOne before cancel
        [data.fiber is] @data.@fibers.cutIf 1 = [@data.@fiber @resumingFibers.append] when
      ] @currentFiber.setFunc

      dispatch
      canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
    ] when
  ];

  wake: [
    fibers.empty? ~ [
      resumingFibers.last isNil [
        [resumingFibers.first isNil] "invalid linked list state" assert
        @fibers.@first @resumingFibers.!first
      ] [
        [resumingFibers.last.next isNil] "invalid linked list state" assert
        @fibers.@first @resumingFibers.@last.@next.set
      ] if

      @fibers.@last @resumingFibers.!last
      @fibers.clear
    ] when
  ];

  wakeOne: [
    fibers.empty? ~ [
      fiber: @fibers.popFirst;
      [fiber.canceled? ~] "invalid fiber state" assert
      @fiber @resumingFibers.append
    ] when
  ];

  fibers: FiberData IntrusiveQueue;
}];
