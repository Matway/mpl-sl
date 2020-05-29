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
    previousCounter0: previousCounter copy;
    @previousCounter storageAddress Int64 addressToReference kernel32.QueryPerformanceCounter drop
    previousCounter previousCounter0 - Real64 cast multiplier * previousTime + !previousTime
    previousTime copy
  ];

  spinlock: Spinlock;
  multiplier: Real64;
  previousCounter: Nat64;
  previousTime: Real64;
};

@runningTimeInternal.init

runningTime: [@runningTimeInternal];
