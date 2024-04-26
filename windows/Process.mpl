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
"kernel32.WAIT_OBJECT_0"       use
"kernel32.WaitForSingleObject" use

"unicode.utf16" use

Process: [{
  SCHEMA_NAME: "Process" virtual;

  close: [
    "close" assertCreated
    success: handle CloseHandle 0 = ~;
    success [0nx !handle] when

    success "CloseHandle" getErrorMessage
  ];

  create: [
    command:;
    [isCreated ~] "Attempted to initialize process twice" assert

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
        FALSE "CloseHandle" getErrorMessage reportError
      ] when
    ] when

    success "CreateProcessW" getErrorMessage
  ];

  exitCode: [
    "get exit status of" assertCreated
    out: Nat32;
    success: @out handle GetExitCodeProcess 0 = ~;
    out success "GetExitCodeProcess" getErrorMessage
  ];

  isCreated: [
    handle 0nx = ~
  ];

  # NOTE: There is a corner case. If process did exit with status code 259, the
  # function will report that the process is still active.
  running: [
    "get running status of" assertCreated
    statusCode: opExitCodeError: exitCode;;
    statusCode STILL_ACTIVE = opExitCodeError
  ];

  terminate: [
    exitStatus:;
    "terminate" assertCreated
    success: exitStatus handle TerminateProcess 0 = ~;
    success "TerminateProcess" getErrorMessage
  ];

  wait: [
    "wait" assertCreated
    success: INFINITE handle WaitForSingleObject WAIT_OBJECT_0 =;
    success "WaitForSingleObject" getErrorMessage
  ];

  private DIE: [
    isCreated [
      succeed?: [.size 0 =];

      active: opRunningError: running;;
      opRunningError succeed? [
        active [
          opWaitError: wait;
          opWaitError succeed? ~ [opWaitError reportError] when
        ] when
      ] [opRunningError reportError] if

      opCloseError: close;
      opCloseError succeed? ~ [opCloseError reportError] when
    ] when
  ];

  private INIT: [0nx !handle];

  private getErrorMessage: [
    success: functionName:;;
    success [String] [
      (operationName " failed, result=" GetLastError LF) assembleString
    ] if
  ];

  private reportError: [
    message:;
    (message LF) printList
  ];

  private assertCreated: [
    operationName:;
    [isCreated] "Attempted to " operationName & " a process that is not initialized" & assert
  ];

  private handle: 0nx;
}];

toProcess: [
  process: Process;
  result: @process.create; # Consumes command from the stack, returns result String
  process result
];
