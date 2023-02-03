# Copyright (C) 2022 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"        use
"control.Int32"     use
"control.copyable?" use
"control.ensure"    use

"sync/ContextGroup.ContextGroup" use
"sync/sync.canceled?"            use
"sync/sync.spawn"                use
"sync/sync.yield"                use

initCount: Int32;
dieCount:  Int32;

# Test that ContextGroup.DIE yields
[
  stage: 0;

  [
    group: ContextGroup;
    {stage: @stage; CALL: [
      1 @stage set
    ];} @group.spawn
  ] call

  [stage 1 =] "ContextGroup.DIE did not yield" ensure
] call

# Test that ContextGroup is not copyable
[
  group: ContextGroup;
  group copyable? ["ContextGroup is copyable" raiseStaticError] [] uif
] call

# Test that ContextGroup.cancel sets the canceled state
[
  group: ContextGroup;
  {CALL: [
    [canceled?] "ContextGroup.cancel did not set the canceled state" ensure
  ];} @group.spawn

  @group.cancel
  yield
] call

# Test that ContextGroup.spawn creates a valid, non-canceled context
[
  stage: 0;
  group: ContextGroup;
  {stage: @stage; CALL: [
    [canceled? ~] "ContextGroup.spawn created a canceled context" ensure
    1 @stage set
  ];} @group.spawn

  [stage 0 =] "ContextGroup.spawn executed immediately" ensure
] call

# Test that ContextGroup.spawn moves the input and finished context destroys it
[
  0 !initCount
  0 !dieCount
  object: {
    INIT: [1 !state initCount 1 + @initCount set];
    DIE: [dieCount 1 + @dieCount set];
    CALL: [
      [initCount 1 = [dieCount 0 =] && [state 1234 =] &&] "ContextGroup.spawn did not correctly move the input data" ensure
    ];

    state: 1234;
  };

  group: ContextGroup;
  @object @group.spawn
  [initCount 1 = [dieCount 0 =] && [@object.state 1 =] &&] "ContextGroup.spawn did not move the input" ensure
  @group.wait
  [initCount 1 = [dieCount 1 =] && [@object.state 1 =] &&] "finished context did not destroy the copied input" ensure
] call

# Test that ContextGroup.wait yields
[
  stage: 0;
  group: ContextGroup;
  {stage: @stage; CALL: [
    1 @stage set
  ];} @group.spawn

  @group.wait
  [stage 1 =] "ContextGroup.wait did not yield" ensure
] call

# Test that ContextGroup.wait in the canceled context cancels the blocking context
[
  context: {CALL: [
    group: ContextGroup;
    {CALL: [
      [canceled?] "ContextGroup.wait in the canceled context did not cancel the blocking context" ensure
    ];} @group.spawn
  ];} () spawn;

  @context.cancel
  yield
] call

# Test that ContextGroup.wait cancelation cancels the blocking context
[
  context: {CALL: [
    group: ContextGroup;
    {CALL: [
      [canceled?] "Context.wait cancelation did not cancel the blocking context" ensure
    ];} @group.spawn
  ];} () spawn;

  yield
  @context.cancel
] call
