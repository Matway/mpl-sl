"Spinlock" module
"atomic" includeModule

Spinlock: [{
  state: 0n8;

  INIT: [
    0n8 !state
  ];

  DIE: [
    [state 0n8 =] "attempted to destroy a locked Spinlock" assert
  ];

  lock: [
    1n8 @state ACQUIRE atomicExchange 1n8 = [
      counter: 1;
      [
        counter 200000 = [
          "spinlocked for a long time" failProc
        ] when

        1n8 @state ACQUIRE atomicExchange 1n8 = [
          counter 1 + !counter TRUE
        ] [
          FALSE
        ] if
      ] loop
    ] when
  ];

  unlock: [
    0n8 @state RELEASE atomicStore
  ];
}];
