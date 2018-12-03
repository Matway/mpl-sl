"lockGuard" module
"control" useModule

lockGuard: [
  guard: {
    object:;

    DIE: [
      @object.unlock
    ];
  };

  @guard.@object.lock

  guard
] func;

unlockGuard: [
  guard: {
    object:;

    DIE: [
      @object.lock
    ];
  };

  @guard.@object.unlock

  guard
] func;
