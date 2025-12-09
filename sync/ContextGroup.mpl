# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"IntrusiveDeque.IntrusiveDeque" use
"Mref.Mref"                     use
"algorithm.each"                use
"control.Ref"                   use
"control.assert"                use
"control.dup"                   use
"control.nil?"                  use
"control.when"                  use
"control.while"                 use

"sync/syncPrivate.FiberData"         use
"sync/syncPrivate.canceled?"         use
"sync/syncPrivate.currentFiber"      use
"sync/syncPrivate.defaultCancelFunc" use
"sync/syncPrivate.dispatch"          use
"sync/syncPrivate.emptyCancelFunc"   use
"sync/syncPrivate.resumingFibers"    use
"sync/syncPrivate.reusableFibers"    use
"sync/syncPrivate.spawnFiber"        use

ContextGroup: [{
  INIT: [
  ];

  DIE: [
    wait
  ];

  cancel: [
    @fibers [.@fiber.cancel] each
  ];

  spawn: [
    in:;
    contextGroupFunc: [
      creationData: @CreationData addressToReference;
      group:        @creationData.@group;
      data:         Data;
      @currentFiber @data.!fiber
      @data @group.@fibers.append

      [
        in: @creationData.@in dup isConst ~ [new] when;
        @data.@fiber @resumingFibers.append
        @creationData.@waitingFiber.switchTo

        [currentFiber data.fiber is] "inconsistent current fiber" assert
        data.fiber.canceled? ~ [
          [data.fiber.@func @emptyCancelFunc is] "invalid cancelation function" assert
          @defaultCancelFunc @data.@fiber.!func
        ] when

        @in call
      ] call

      @data @group.@fibers.cut
      @currentFiber @reusableFibers.prepend
      data.waitedBy nil? [
        dispatch
      ] [
        @data.@waitedBy.switchTo
      ] if
    ];

    creationData: {group: @self; in: @in; waitingFiber: @currentFiber;};
    CreationData: @creationData Ref virtual;
    creationData storageAddress @contextGroupFunc spawnFiber
  ];

  wait: [
    canceled? [
      cancel
    ] when

    [fibers.empty? ~] [
      [fibers.first.fiber currentFiber is ~] "attempted to wait on itself"                 assert
      [fibers.first.waitedBy nil?          ] "multiple attempts to wait on the same fiber" assert

      @currentFiber @fibers.@first.!waitedBy
      canceled? ~ [
        [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert
        Self: @self Ref virtual;
        self storageAddress [@Self addressToReference .cancel] @currentFiber.setFunc
      ] when

      dispatch
      canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
    ] while
  ];

  Data: [{
    fiber:    FiberData Ref;
    prev:     [Data] Mref;
    next:     [Data] Mref;
    waitedBy: FiberData Ref;
  }];

  fibers: Data IntrusiveDeque;
}];
