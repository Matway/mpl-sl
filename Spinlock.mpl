# Copyright (C) 2022 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"atomic.ACQUIRE"        use
"atomic.RELEASE"        use
"atomic.atomicExchange" use
"atomic.atomicStore"    use
"control.assert"        use

Spinlock: [{
  LOCKED:   [1n8];
  UNLOCKED: [0n8];

  MAXIMUM_SPIN_COUNT: [1000000];

  state: UNLOCKED;

  DIE: [
    [state UNLOCKED =] "Attempted to destroy a locked [Spinlock]" assert
  ];

  INIT: [UNLOCKED !state];

  lock: [
    DEBUG [counter: 0;] [] uif

    [
      [counter MAXIMUM_SPIN_COUNT = ~] "The maximum [Spinlock] spin count has been reached" assert

      LOCKED @state ACQUIRE atomicExchange LOCKED = [
        counter 1 + !counter
        TRUE
      ] [
        FALSE
      ] if
    ] loop
  ];

  unlock: [
    [state LOCKED =] "[unlock] was called in an invalid [Spinlock] state" assert
    UNLOCKED @state RELEASE atomicStore
  ];
}];
