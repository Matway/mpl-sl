"control.ensure" use
"control.isCopyable" use
"control.when" use

"sync/Event.Event" use
"sync/sync.spawn" use
"sync/sync.yield" use

EventTest: [];

# Test that Event is constructed in the cleared state
[
  event: Event;
  event.get ["Event did construct in the set state" raiseStaticError] [] uif
] call

# Test that Event.INIT clears the state
[
  event: Event;
  @event.set
  @event.get [ # Event.set set the state, otherwise skip the test
    event manuallyDestroyVariable
    event manuallyInitVariable
    event.get ["Event.INIT did not clear the state" raiseStaticError] [] uif
  ] when
] call

# Test that Event is not copyable
[
  event: Event;
  event isCopyable ["Event is copyable" raiseStaticError] [] uif
] call

# Test that Event.clear clears the state
[
  event: Event;
  @event.set
  @event.get [ # Event.set set the state, otherwise skip the test
    @event.clear
    event.get ["Event.clear did not clear the state" raiseStaticError] [] uif
  ] when
] call

# Test that Event.set sets the state and unblocks the waiting contexts, in the correct order
[
  stage: 0;
  event: Event;
  @event.get ~ [ # Event constructed in the cleared state, otherwise skip the test
    context0: {stage: @stage; event: @event; CALL: [
      @event.wait
      1 @stage set
    ];} () spawn;

    context1: {stage: @stage; event: @event; CALL: [
      @event.wait
      [stage 1 =] "Event.set woke contexts in the wrong order" ensure
      2 @stage set
    ];} () spawn;

    yield
    stage 0 = [ # Wait blocked, otherwise skip the test
      @event.set
      [event.get] "Event.set did not set the state" ensure
      [stage 0 =] "Event.set woke contexts immediately" ensure
      yield
      [stage 2 =] "Event.set did not woke contexts" ensure
    ] when
  ] when
] call

# Test that Event.wait does not block when the event is set
[
  stage: 0;
  event: Event;
  @event.set
  @event.get [ # Event.set set the state, otherwise skip the test
    context: {stage: @stage; event: @event; CALL: [
      @event.wait
      1 @stage set
    ];} () spawn;

    yield
    [stage 1 =] "Event.wait blocked on the set event" ensure
  ] when
] call

# Test that Event.wait blocks when the event is not set
[
  stage: 0;
  event: Event;
  @event.get ~ [ # Event constructed in the cleared state, otherwise skip the test
    context: {stage: @stage; event: @event; CALL: [
      @event.wait
      1 @stage set
    ];} () spawn;

    yield
    [stage 0 =] "Event.wait did not block on the cleared event" ensure
    @context.cancel
  ] when
] call

# Test that Event.wake unblocks the waiting contexts, in the correct order
[
  stage: 0;
  event: Event;
  @event.get ~ [ # Event constructed in the clear state, otherwise skip the test
    context0: {stage: @stage; event: @event; CALL: [
      @event.wait
      1 @stage set
    ];} () spawn;

    context1: {stage: @stage; event: @event; CALL: [
      @event.wait
      [stage 1 =] "Event.wake woke contexts in the wrong order" ensure
      2 @stage set
    ];} () spawn;

    yield
    stage 0 = [ # Wait blocked, otherwise skip the test
      @event.wake
      [event.get ~] "Event.wake did set the state" ensure
      [stage 0 =] "Event.wake woke contexts immediately" ensure
      yield
      [stage 2 =] "Event.wake did not woke contexts" ensure
    ] when
  ] when
] call

# Test that Event.wakeOne unblocks the first of the waiting contexts
[
  stage: 0;
  event: Event;
  @event.get ~ [ # Event constructed in the clear state, otherwise skip the test
    context0: {stage: @stage; event: @event; CALL: [
      @event.wait
      1 @stage set
    ];} () spawn;

    context1: {stage: @stage; event: @event; CALL: [
      @event.wait
      [stage 1 =] "Event.wakeOne woke contexts in the wrong order" ensure
      2 @stage set
    ];} () spawn;

    yield
    stage 0 = [ # Wait blocked, otherwise skip the test
      @event.wakeOne
      [event.get ~] "Event.wakeOne did set the state" ensure
      [stage 0 =] "Event.wakeOne woke contexts immediately" ensure
      yield
      [stage 0 = ~] "Event.wakeOne did not woke the first context" ensure
      [stage 1 =] "Event.wakeOne did woke the second context" ensure
      @context1.cancel
    ] when
  ] when
] call
