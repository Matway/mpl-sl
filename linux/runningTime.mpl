# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.printList" use
"control.Real64"   use
"control.failProc" use
"control.when"     use

"posix.CLOCK_BOOTTIME" use
"posix.clock_gettime"  use
"posix.timespec"       use

"errno.errno" use

runningTimeInternal: {
  get: [
    time1: timespec;
    @time1 CLOCK_BOOTTIME clock_gettime -1 = [("FATAL: clock_gettime failed, result=" errno LF) printList "" failProc] when
    NANOSECONDS_TO_SECONDS_MULTIPLIER: [0.000000001r64];
    time1.tv_sec  time0.tv_sec  - Real64 cast
    time1.tv_nsec time0.tv_nsec - Real64 cast NANOSECONDS_TO_SECONDS_MULTIPLIER * +
  ];

  private time0: timespec;

  @time0 CLOCK_BOOTTIME clock_gettime -1 = [("FATAL: clock_gettime failed, result=" errno LF) printList "" failProc] when
};

runningTime: [runningTimeInternal];
