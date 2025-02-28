"String"               use
"control"              use
"posix.CLOCK_REALTIME" use
"posix.clock_gettime"  use
"posix.gmtime_r"       use
"posix.time_t"         use
"posix.timespec"       use
"posix.tm"             use

gmtime: [
  sec: time_t cast;
  now: tm;
  @now sec storageAddress gmtime_r 0nx = [("FATAL: gmtime failed" LF) printList "" failProc] when
  now
];

clockGetTime: [
  ts: timespec;
  @ts CLOCK_REALTIME clock_gettime -1 = [("FATAL: clock_gettime failed" LF) printList "" failProc] when
  ts
];