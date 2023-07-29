# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.copyable?" use
"control.ensure"    use
"control.when"      use

"sync/Signal.Signal" use
"sync/sync.spawn"    use
"sync/sync.yield"    use

SignalTest: [];

# Test that Signal is not copyable
[
  signal: Signal;
  signal copyable? ["Signal is copyable" raiseStaticError] [] uif
] call

# Test that Signal.wait does not block in canceled contexts
[
  stage: 0;
  signal: Signal;
  context: {stage: @stage; signal: @signal; CALL: [
    @signal.wait
    1 @stage set
  ];} () spawn;

  @context.cancel
  yield
  [stage 1 =] "Signal.wait blocked in the canceled context" ensure
] call

# Test that Signal.wait blocks and cancels properly
[
  stage: 0;
  signal: Signal;
  context: {stage: @stage; signal: @signal; CALL: [
    @signal.wait
    1 @stage set
  ];} () spawn;

  yield
  [stage 0 =] "Signal.wait did not block" ensure
  @context.cancel
  [stage 0 =] "Signal.wait canceled immediately" ensure
  yield
  [stage 1 =] "Signal.wait did not cancel" ensure
] call

# Test that Signal.wake unblocks the waiting contexts, in the correct order
[
  stage: 0;
  signal: Signal;
  context0: {stage: @stage; signal: @signal; CALL: [
    @signal.wait
    1 @stage set
  ];} () spawn;

  context1: {stage: @stage; signal: @signal; CALL: [
    @signal.wait
    [stage 1 =] "Signal.wake woke contexts in the wrong order" ensure
    2 @stage set
  ];} () spawn;

  yield
  stage 0 = [ # Wait blocked, otherwise skip the test
    @signal.wake
    [stage 0 =] "Signal.wake woke contexts immediately" ensure
    yield
    [stage 2 =] "Signal.wake did not woke contexts" ensure
  ] when
] call

# Test that awakening Signal.wait context handles cancel properly
# This test relies on internal Signal state validation in DEBUG mode
[
  stage: 0;
  signal: Signal;
  context: {stage: @stage; signal: @signal; CALL: [
    @signal.wait
    1 @stage set
  ];} () spawn;

  yield
  @signal.wake
  @context.cancel
] call

# Test that Signal.wakeOne unblocks the first of the waiting contexts
[
  stage: 0;
  signal: Signal;
  context0: {stage: @stage; signal: @signal; CALL: [
    @signal.wait
    1 @stage set
  ];} () spawn;

  context1: {stage: @stage; signal: @signal; CALL: [
    @signal.wait
    [stage 1 =] "Signal.wakeOne woke contexts in the wrong order" ensure
    2 @stage set
  ];} () spawn;

  yield
  stage 0 = [ # Wait blocked, otherwise skip the test
    @signal.wakeOne
    [stage 0 =] "Signal.wakeOne woke contexts immediately" ensure
    yield
    [stage 0 = ~] "Signal.wakeOne did not woke the first context" ensure
    [stage 1 =] "Signal.wakeOne did woke the second context" ensure
    @context1.cancel
  ] when
] call
