# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.assembleString" use
"String.print"          use
"control.Nat32"         use
"control.Ref"           use
"control.assert"        use
"control.drop"          use
"control.exit"          use
"control.when"          use

"kernel32.kernel32" use

Thread: [{
  INIT: [0nx !handle];

  DIE: [handle 0nx = ~ [join drop] when];

  isRunning: [handle 0nx = ~];

  init: [
    context: function:;;
    Nat32 Ref 0n32 context @function 4096nx kernel32.SECURITY_ATTRIBUTES Ref kernel32.CreateThread !handle handle 0nx = [
      ("CreateThread failed, result=" kernel32.GetLastError LF) assembleString print 1 exit # there is no good way to handle this, report and abort
    ] when
  ];

  join: [
    [handle 0nx = ~] "attempted to join a not running Thread" assert
    kernel32.INFINITE handle kernel32.WaitForSingleObject kernel32.WAIT_OBJECT_0 = ~ [
      ("WaitForSingleObject failed, result=" kernel32.GetLastError LF) assembleString print 1 exit # there is no good way to handle this, report and abort
    ] when

    code: Nat32;
    @code handle kernel32.GetExitCodeThread 1 = ~ [
      ("GetExitCodeThread failed, result=" kernel32.GetLastError LF) assembleString print 1 exit # there is no good way to handle this, report and abort
    ] when

    handle kernel32.CloseHandle 1 = ~ [
      ("CloseHandle failed, result=" kernel32.GetLastError LF) assembleString print 1 exit # there is no good way to handle this, just report
    ] when

    0nx !handle
    code
  ];

  handle: 0nx;
}];

thread: [
  thread: Thread;
  @thread.init
  @thread
];
