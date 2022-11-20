# Copyright (C) 2022 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"atomic.ACQUIRE" use
"atomic.RELEASE" use
"atomic.atomicExchange" use
"atomic.atomicStore" use
"control.assert" use
"control.when" use

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
        counter 2000000 = [
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
