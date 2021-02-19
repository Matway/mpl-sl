# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Spinlock.Spinlock" use
"control.Int64" use
"control.Nat64" use
"control.Real64" use
"control.drop" use
"kernel32.kernel32" use
"lockGuard.lockGuard" use

runningTimeInternal: {
  init: [
    frequency: Int64;
    @frequency kernel32.QueryPerformanceFrequency drop
    1.0 frequency Real64 cast / !multiplier
    @previousCounter storageAddress Int64 addressToReference kernel32.QueryPerformanceCounter drop
    0.0 !previousTime
  ];

  get: [
    lock: @spinlock lockGuard;
    previousCounter0: previousCounter new;
    @previousCounter storageAddress Int64 addressToReference kernel32.QueryPerformanceCounter drop
    previousCounter previousCounter0 - Real64 cast multiplier * previousTime + !previousTime
    previousTime new
  ];

  spinlock: Spinlock;
  multiplier: Real64;
  previousCounter: Nat64;
  previousTime: Real64;
};

@runningTimeInternal.init

runningTime: [@runningTimeInternal];
