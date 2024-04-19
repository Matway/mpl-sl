# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.printList" use
"control.Nat32"    use
"control.exit"     use
"control.when"     use
"control.||"       use

"kernel32.CONDITION_VARIABLE"        use
"kernel32.ERROR_TIMEOUT"             use
"kernel32.GetLastError"              use
"kernel32.INFINITE"                  use
"kernel32.SleepConditionVariableSRW" use
"kernel32.WakeAllConditionVariable"  use
"kernel32.WakeConditionVariable"     use

ConditionVariable: [{
  SCHEMA_NAME: "ConditionVariable" virtual;

  DIE: [
  ];

  INIT: [
    0nx @conditionVariable.!Ptr
  ];

  wait: [
    srwLock: time: shared:;;;
    shared [CONDITION_VARIABLE_LOCKMODE_SHARED] [0n32] if
    time -1 = [INFINITE] [time Nat32 cast] if
    @srwLock.@srwLock
    @conditionVariable
    SleepConditionVariableSRW 1 = [TRUE] [
      error: GetLastError;
      error ERROR_TIMEOUT = ~ [time -1 =] || [
        ("SleepConditionVariableSRW failed, result=" error LF) printList 1 exit # There is no good way to handle this, report and abort
      ] when

      FALSE
    ] if
  ];

  wakeAll: [
    @conditionVariable WakeAllConditionVariable
  ];

  wakeOne: [
    @conditionVariable WakeConditionVariable
  ];

  # Private

  conditionVariable: CONDITION_VARIABLE;
}];
