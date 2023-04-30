# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"IntrusiveQueue.IntrusiveQueue" use
"control.assert"                use
"control.nil?"                  use
"control.when"                  use

"syncPrivate.FiberData"         use
"syncPrivate.canceled?"         use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use
"syncPrivate.resumingFibers"    use

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
