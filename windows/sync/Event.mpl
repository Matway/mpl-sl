"control.when" use

"Signal.Signal" use

Event: [{
  INIT: [
    FALSE !state
  ];

  DIE: [];

  get: [
    state new
  ];

  clear: [
    FALSE !state
  ];

  set: [
    TRUE !state
    @signal.wake
  ];

  wait: [
    state ~ [
      @signal.wait
    ] when
  ];

  wake: [
    @signal.wake
  ];

  wakeOne: [
    @signal.wakeOne
  ];

  state: FALSE;
  signal: Signal;
}];
