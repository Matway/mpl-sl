# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"IntrusiveQueue.IntrusiveQueue" use
"control.Ref"                   use
"control.assert"                use
"control.nil?"                  use
"control.when"                  use

"sync/syncPrivate.FiberData"         use
"sync/syncPrivate.canceled?"         use
"sync/syncPrivate.currentFiber"      use
"sync/syncPrivate.defaultCancelFunc" use
"sync/syncPrivate.dispatch"          use
"sync/syncPrivate.resumingFibers"    use

Signal: [{
  INIT: [];

  DIE: [
    [fibers.empty?] "some fibers left sleeping" assert
  ];

  wait: [
    canceled? ~ [
      [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert
      @currentFiber @fibers.append
      data: {fibers: @fibers; fiber: @currentFiber;};
      Data: @data Ref virtual;
      data storageAddress [
        data: @Data addressToReference;
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
      resumingFibers.last nil? [
        [resumingFibers.first nil?] "invalid linked list state" assert
        @fibers.@first @resumingFibers.!first
      ] [
        [resumingFibers.last.next nil?] "invalid linked list state" assert
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
