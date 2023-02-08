# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.printList" use
"control.Nat32"    use
"control.Natx"     use
"control.Ref"      use
"control.assert"   use
"control.drop"     use
"control.exit"     use
"control.when"     use

"kernel32.kernel32" use

Thread: [{
  SCHEMA_NAME: "Thread" virtual;

  DIE: [
    isRunning [
      join drop
    ] when
  ];

  INIT: [
    0nx !handle
  ];

  create: [
    code: context: stackSize:;;;
    [isRunning ~] "Attempted to initialize a Thread that is already running" assert
    Nat32 Ref 0n32 context @code stackSize Natx cast kernel32.SECURITY_ATTRIBUTES Ref kernel32.CreateThread !handle handle 0nx = [
      ("CreateThread failed, result=" kernel32.GetLastError LF) printList 1 exit # There is no good way to handle this, report and abort
    ] when
  ];

  isRunning: [
    handle 0nx = ~
  ];

  join: [
    [isRunning] "Attempted to join a Thread that is not running" assert
    kernel32.INFINITE handle kernel32.WaitForSingleObject kernel32.WAIT_OBJECT_0 = ~ [
      ("WaitForSingleObject failed, result=" kernel32.GetLastError LF) printList 1 exit # There is no good way to handle this, report and abort
    ] when

    result: Nat32;
    @result handle kernel32.GetExitCodeThread 1 = ~ [
      ("GetExitCodeThread failed, result=" kernel32.GetLastError LF) printList 1 exit # There is no good way to handle this, report and abort
    ] when

    handle kernel32.CloseHandle 1 = ~ [
      ("CloseHandle failed, result=" kernel32.GetLastError LF) printList # There is no good way to handle this, just report
    ] when

    0nx !handle
    result
  ];

  # Private

  handle: 0nx;
}];

toThread3: [
  thread: Thread;
  @thread.create
  @thread
];
