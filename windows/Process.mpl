# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.String"         use
"String.assembleString" use
"String.printList"      use
"control.Cref"          use
"control.Nat32"         use
"control.assert"        use
"control.exit"          use
"control.when"          use

"kernel32.CloseHandle"         use
"kernel32.CreateProcessW"      use
"kernel32.GetExitCodeProcess"  use
"kernel32.GetLastError"        use
"kernel32.INFINITE"            use
"kernel32.PROCESS_INFORMATION" use
"kernel32.SECURITY_ATTRIBUTES" use
"kernel32.STARTUPINFOW"        use
"kernel32.STILL_ACTIVE"        use
"kernel32.TerminateProcess"    use
"kernel32.WAIT_FAILED"         use
"kernel32.WAIT_OBJECT_0"       use
"kernel32.WaitForSingleObject" use

"unicode.utf16" use

Process: [{
  SCHEMA_NAME: "Process" virtual;

  create: [
    command:;
    [isCreated ~] "Attempted to initialize a process twice" assert

    processInformation: PROCESS_INFORMATION;
    startupInfo:        STARTUPINFOW;
    startupInfo storageSize Nat32 cast @startupInfo.!cb

    success:
      @processInformation
      startupInfo
      0nx
      0nx
      0n32
      0
      SECURITY_ATTRIBUTES Cref
      SECURITY_ATTRIBUTES Cref
      command utf16.data storageAddress
      0nx
      CreateProcessW 0 = ~
    ;

    success [
      processInformation.hProcess new !handle

      processInformation.hThread CloseHandle 0 = [
        "CloseHandle" reportError
      ] when

      String
    ] [
      "CreateProcessW" getErrorMessage
    ] if
  ];

  isCreated: [
    handle 0nx = ~
  ];

  isRunning: [
    "get running status of" assertCreated

    waitResult: 0n32 handle WaitForSingleObject;

    waitResult WAIT_FAILED = [
      "WaitForSingleObject" reportError
      1 exit
    ] when

    waitResult WAIT_OBJECT_0 = ~
  ];

  kill: [
    exitCode:;
    "kill" assertCreated

    exitCode handle TerminateProcess 0 = [
      "TerminateProcess" reportError
      1 exit
    ] when

    closeHandle
  ];

  wait: [
    needExitCode:;
    [needExitCode isStatic] "[needExitCode] must be static" assert

    "wait" assertCreated

    INFINITE handle WaitForSingleObject WAIT_OBJECT_0 = ~ [
      "WaitForSingleObject" reportError
      1 exit
    ] when

    needExitCode [
      result: Nat32;

      @result handle GetExitCodeProcess 0 = [
        "GetExitCodeProcess" reportError
        1 exit
      ] when

      result
    ] when

    closeHandle
  ];

  private handle: 0nx;

  private DIE: [
    isCreated [
      FALSE wait
    ] when
  ];

  private INIT: [
    0nx !handle
  ];

  private assertCreated: [
    operationName:;
    [isCreated] "Attempted to " operationName & " a process that is not initialized" & assert
  ];

  private closeHandle: [
    handle CloseHandle 0 = [
      "CloseHandle" reportError
    ] when

    0nx !handle
  ];

  private getErrorMessage: [
    functionName:;
    (functionName " failed, result=" GetLastError LF) assembleString
  ];

  private reportError: [
    functionName:;
    (functionName getErrorMessage LF) printList
  ];
}];

toProcess: [
  process: Process;
  result: @process.create;
  @process @result
];
