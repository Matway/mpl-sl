# Copyright (C) 2023 Matway Burkow
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

"syncPrivate.FiberData"         use
"syncPrivate.canceled?"         use
"syncPrivate.currentFiber"      use
"syncPrivate.defaultCancelFunc" use
"syncPrivate.dispatch"          use
"syncPrivate.emptyCancelFunc"   use
"syncPrivate.resumingFibers"    use
"syncPrivate.reusableFibers"    use
"syncPrivate.spawnFiber"        use

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
      creationData: @creationData addressToReference;
      group: @creationData.@group;
      data: Data;
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
    creationData storageAddress @contextGroupFunc spawnFiber
  ];

  wait: [
    canceled? [
      cancel
    ] when

    [fibers.empty? ~] [
      [fibers.first.waitedBy nil?] "multiple attempts to wait on the same fiber" assert
      @currentFiber @fibers.@first.!waitedBy
      canceled? ~ [
        [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert
        self storageAddress [@self addressToReference .cancel] @currentFiber.setFunc
      ] when

      dispatch
      canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
    ] while
  ];

  Data: [{
    fiber: FiberData Ref;
    prev: [Data] Mref;
    next: [Data] Mref;
    waitedBy: FiberData Ref;
  }];

  fibers: Data IntrusiveDeque;
}];
