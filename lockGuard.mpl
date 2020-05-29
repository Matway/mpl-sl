lockGuard: [
  guard: {
    object:;

    DIE: [
      @object.unlock
    ];
  };

  @guard.@object.lock

  guard
];

unlockGuard: [
  guard: {
    object:;

    DIE: [
      @object.lock
    ];
  };

  @guard.@object.unlock

  guard
];
