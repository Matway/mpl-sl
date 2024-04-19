# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"            use
"control.Cond"          use
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
"kernel32.WAIT_OBJECT_0"       use
"kernel32.WaitForSingleObject" use

"unicode.utf16" use

Process: [{
  SCHEMA_NAME: "Process" virtual;

  startupInfo:               STARTUPINFOW;
  processInformation:        PROCESS_INFORMATION;
  processSecurityAttributes: SECURITY_ATTRIBUTES Cref; # We want it to be Nil by default
  threadSecurityAttributes:  SECURITY_ATTRIBUTES Cref; #

  init: [startupInfo storageSize Nat32 cast @startupInfo.!cb];

  start: [
    command:;
    result:
      @processInformation
      startupInfo
      0nx
      0nx
      0n32
      0
      threadSecurityAttributes
      processSecurityAttributes
      command.data storageAddress
      0nx
      CreateProcessW 0 = ~
    ;

    result
  ];

  wait: [INFINITE processInformation.hProcess WaitForSingleObject WAIT_OBJECT_0 =];

  close: [
    processInformation.hProcess CloseHandle 0 = ~ [processInformation.hThread CloseHandle 0 = ~] &&
  ];

  exitCode: [
    out:;
    errorTrait: @out processInformation.hProcess GetExitCodeProcess;
    errorTrait 0 = ~
  ];
}];

# Start 'process' represented by 'command'
# in:
#   command
# out:
#   process
#
# Examples:
#   1) "program" startProcess drop
#
#   2) "program programArgument" startProcess drop
#
#   3) program: "program" startProcess;
#      program.isSuccessfulOperation ~ [("Failed to start program: " program.operationError) printList] when
#
#   4) program: "program" startProcess;
#      program.wait
#      exitCode: program.exitCode;
startProcess: [
  command:;
  {
    process: Process;

    operationError: [operationErrorCode new];

    isSuccessfulOperation: [operationError 0n32 =];

    wait: [process.wait updateOperationError];

    close: [
      process.close updateOperationError
      FALSE !toBeClosed
    ];

    # NOTE: There is a corner case. If process did exit with status code 259, the function will report that the process is still active
    isActive: [exitCode STILL_ACTIVE =];

    exitCode: [
      status: Nat32;
      [@status process.exitCode] "[exitCode] failed" assert
      status
    ];

    private command:            command utf16;
    private operationErrorCode: Nat32;
    private toBeClosed:         Cond;

    private DIE: [
      toBeClosed [close] when
    ];

    private INIT: [FALSE !toBeClosed];

    private updateOperationError: [
      determiner:;
      determiner ~ [GetLastError !operationErrorCode] when
    ];

    [
      @process.init
      @command @process.start updateOperationError
      isSuccessfulOperation !toBeClosed
    ] call
  }
];
