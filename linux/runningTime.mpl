# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.printList" use
"control.Real64"   use
"control.failProc" use
"control.when"     use

"posix.CLOCK_MONOTONIC" use
"posix.clock_gettime"   use
"posix.timespec"        use

"linux.errno" use

runningTimeInternal: {
  init: [
    @initTime CLOCK_MONOTONIC clock_gettime -1 = [("FATAL: clock_gettime failed, result=" errno LF) printList "" failProc] when
  ];

  get: [
    currentTime: timespec;
    @currentTime CLOCK_MONOTONIC clock_gettime -1 = [("FATAL: clock_gettime failed, result=" errno LF) printList "" failProc] when

    NANOSECONDS_TO_SECONDS_MULTIPLIER: [0.000000001r64];

    currentTime.tv_sec initTime.tv_sec - Real64 cast currentTime.tv_nsec initTime.tv_nsec - Real64 cast NANOSECONDS_TO_SECONDS_MULTIPLIER * +
  ];

  private initTime: timespec;
};

@runningTimeInternal.init

runningTime: [@runningTimeInternal];
