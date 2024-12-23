# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Natx"   use
"control.Ref"    use
"control.assert" use
"control.dup"    use
"control.nil?"   use
"control.when"   use

"sync/syncPrivate.FiberData"         use
"sync/syncPrivate.canceled?"         use
"sync/syncPrivate.currentFiber"      use
"sync/syncPrivate.defaultCancelFunc" use
"sync/syncPrivate.dispatch"          use
"sync/syncPrivate.emptyCancelFunc"   use
"sync/syncPrivate.resumingFibers"    use
"sync/syncPrivate.reusableFibers"    use
"sync/syncPrivate.spawnFiber"        use

Context: [{
  INIT: [
    Data Ref !data
  ];

  DIE: [
    valid? [
      wait
      @Out virtual? ~ [
        data.out @Out addressToReference manuallyDestroyVariable
        data.out @Out addressToReference manuallyInitVariable
      ] when

      @data.@fiber @reusableFibers.prepend
    ] when
  ];

  valid?: [
    data nil? ~
  ];

  done?: [
    [valid?] "invalid Context" assert
    data.out 0nx = ~
  ];

  cancel: [
    [valid?] "invalid Context" assert
    @data.@fiber.cancel
  ];

  get: [
    wait
    @Out () same ~ [
      @Out virtual? [@Out] [data.out @Out addressToReference] if
    ] when
  ];

  wait: [
    done? ~ [
      [data.waitedBy nil?          ] "multiple attempts to wait on the same fiber" assert
      [data.fiber currentFiber is ~] "attempted to wait on self"                   assert

      @currentFiber @data.!waitedBy
      canceled? [
        cancel
      ] [
        [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert
        self storageAddress [@self addressToReference .cancel] @currentFiber.setFunc
      ] if

      dispatch
      [done?] "no out" assert
      canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
    ] when
  ];

  Data: [{
    fiber:    FiberData Ref;
    waitedBy: FiberData Ref;
    out:      Natx;
  }];

  virtual Out: dup virtual? ~ [Ref] when;
  data: Data Ref;
}];

makeContext: [
  in: virtual Out: dup virtual? ~ [Ref] when;;
  contextFunc: [
    creationData: @creationData addressToReference;
    data:         @Out Context.Data;

    @currentFiber @data.!fiber
    @data @creationData.!data

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

    @Out () same [
      1nx
    ] [
      out:;
      @out @Out same ~ ["context return schema mismatch" raiseStaticError] when
      @out virtual? [1nx] [@out storageAddress] if
    ] uif

    @data.!out

    data.fiber.canceled? ~ [
      [data.fiber.@func @defaultCancelFunc is] "invalid cancelation function" assert
      @emptyCancelFunc @data.@fiber.!func
    ] when

    data.waitedBy nil? [
      dispatch
    ] [
      @data.@waitedBy.switchTo
    ] if
  ];

  creationData: {in: @in; waitingFiber: @currentFiber; data: @Out Context.Data Ref;};
  creationData storageAddress @contextFunc spawnFiber

  context: @Out Context;
  @creationData.@data @context.!data
  @context
];
