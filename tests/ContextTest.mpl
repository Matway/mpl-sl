"control.&&" use
"control.Int32" use
"control.Ref" use
"control.drop" use
"control.ensure" use
"control.isCopyable" use
"control.when" use

"sync/Context.Context" use
"sync/sync.canceled?" use
"sync/sync.spawn" use
"sync/sync.yield" use

initCount: Int32;
dieCount: Int32;

# Test that spawn creates a valid, non-canceled context
[
  stage: 0;
  context: {stage: @stage; CALL: [
    [canceled? ~] "spawn created a canceled context" ensure
    1 @stage set
  ];} () spawn;

  [context.valid?] "spawn created an invalid context" ensure
  [context.done? ~] "spawn created a finished context" ensure
  [stage 0 =] "spawn executed immediately" ensure
] call

# Test that spawn moves the input and finished context destroys it
[
  0 !initCount
  0 !dieCount
  object: {
    INIT: [1 !state initCount 1 + @initCount set];
    DIE: [dieCount 1 + @dieCount set];
    CALL: [
      [initCount 1 = [dieCount 0 =] && [state 1234 =] &&] "spawn did not correctly move the input data" ensure
    ];

    state: 1234;
  };

  context: @object () spawn;
  [initCount 1 = [dieCount 0 =] && [@object.state 1 =] &&] "spawn did not move the input" ensure
  @context.wait
  [initCount 1 = [dieCount 1 =] && [@object.state 1 =] &&] "finished context did not destroy the copied input" ensure
] call

# Test that yield executes the context body
[
  stage: 0;
  context: {stage: @stage; CALL: [
    1 @stage set
  ];} () spawn;

  yield
  [context.done?] "yield did not finish the context" ensure
  [stage 1 =] "yield did not execute the context body" ensure
] call

# Test that Context is constructed in the invalid state
[
  context: () Context;
  context.valid? ["Context did construct in the valid state" raiseStaticError] [] uif
] call

# Test that Context.INIT clears the state
[
  context: [] () spawn;
  @context.valid? [ # Context is valid, otherwise skip the test
    context manuallyDestroyVariable
    context manuallyInitVariable
    context.valid? ["Context.INIT did not invalidate context" raiseStaticError] [] uif
  ] when
] call

# Test that Context.DIE yields
[
  stage: 0;

  [
    context: {stage: @stage; CALL: [
      1 @stage set
    ];} () spawn;
  ] call

  [stage 1 =] "Context.DIE did not yield" ensure
] call

# Test that Context.DIE destroys output and reused context destroys it again
[
  0 !initCount
  0 !dieCount
  Object: [{
    INIT: [initCount 1 + @initCount set];
    DIE: [dieCount 1 + @dieCount set];
    CALL: ["spawn did call the output object" raiseStaticError];
    value: 0;
  }];

  [
    context: [Object] Object spawn;
    [initCount 0 = [dieCount 0 =] &&] "spawn produced redundant object operations" ensure
    @context.wait
    [initCount 0 = [dieCount 0 =] &&] "Finished context produced redundant object operations" ensure
  ] call

  [initCount 1 = [dieCount 2 =] &&] "Context.DIE did not destroy the output object" ensure
  [] () spawn drop
  [initCount 1 = [dieCount 3 =] &&] "Reused context did not destroy the output object" ensure
] call

# Test that Context is not copyable
[
  context: () Context;
  context isCopyable ["Context is copyable" raiseStaticError] [] uif
] call

# Test that Context.cancel sets the canceled state
[
  context: {CALL: [
    [canceled?] "Context.cancel did not set the canceled state" ensure
  ];} () spawn;

  @context.cancel
  yield
] call

# Test that Context.cancel works properly for finished contexts
# This test relies on internal Context state validation in DEBUG mode
[
  context: [] () spawn;
  yield
  @context.cancel
] call

# Test that Context.get yields
[
  stage: 0;
  context: {stage: @stage; CALL: [
    1 @stage set
  ];} () spawn;

  @context.get
  [stage 1 =] "Context.get did not yield" ensure
] call

# Test that Context.get returns expected values
[
  ([] () spawn.get) () same ~ ["Context.get returned invalid output schema" raiseStaticError] [] uif

  ([0] Int32 spawn.get) (Int32 Ref) same ~ ["Context.get returned invalid output schema" raiseStaticError] [] uif
  [[0] Int32 spawn.get 0 =] "Context.get returned invalid output value" ensure

  ({CALL:[1];} Int32 spawn.get) (Int32 Ref) same ~ ["Context.get returned invalid output schema" raiseStaticError] [] uif
  [{CALL:[1];} Int32 spawn.get 1 =] "Context.get returned invalid output value" ensure

  code: {} Int32 {} codeRef;
  [2] !code
  (@code Int32 spawn.get) (Int32 Ref) same ~ ["Context.get returned invalid output schema" raiseStaticError] [] uif
  [@code Int32 spawn.get 2 =] "Context.get returned invalid output value" ensure
] call

# Test that Context.wait yields
[
  stage: 0;
  context: {stage: @stage; CALL: [
    1 @stage set
  ];} () spawn;

  @context.wait
  [stage 1 =] "Context.wait did not yield" ensure
] call

# Test that Context.wait in the canceled context cancels the blocking context
[
  context0: {CALL: [
    context1: {CALL: [
      [canceled?] "Context.wait in the canceled context did not cancel the blocking context" ensure
    ];} () spawn;
  ];} () spawn;

  @context0.cancel
  yield
] call

# Test that Context.wait cancelation cancels the blocking context
[
  context0: {CALL: [
    context1: {CALL: [
      [canceled?] "Context.wait cancelation did not cancel the blocking context" ensure
    ];} () spawn;
  ];} () spawn;

  yield
  @context0.cancel
] call
