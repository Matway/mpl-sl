# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.String"         use
"String.assembleString" use
"algorithm.eachStatic"  use
"algorithm.toIter"      use
"control.Int32"         use
"control.Nat16"         use
"control.Nat32"         use
"control.Natx"          use
"control.drop"          use
"conventions.stdcall"   use

"kernel32.CloseHandle"  use
"kernel32.GetLastError" use
"kernel32.INFINITE"     use
"unicode.toUtf16"       use

WAIT_FAILED: [0xFFFFFFFFn32];

STARTUPINFOW: [
  result: {
    cb:              Nat32;
    lpReserved:      Natx;
    lpDesktop:       Natx;
    lpTitle:         Natx;
    dwX:             Nat32;
    dwY:             Nat32;
    dwXSize:         Nat32;
    dwYSize:         Nat32;
    dwXCountChars:   Nat32;
    dwYCountChars:   Nat32;
    dwFillAttribute: Nat32;
    dwFlags:         Nat32;
    wShowWindow:     Nat16;
    cbReserved2:     Nat16;
    lpReserved2:     Natx;
    hStdInput:       Natx;
    hStdOutput:      Natx;
    hStdError:       Natx;
  };

  result storageSize Nat32 cast @result.!cb

  @result
];

PROCESS_INFORMATION: [{
  hProcess:    Natx;
  hThread:     Natx;
  dwProcessId: Nat32;
  dwThreadId:  Nat32;
}];

{
  lpApplicationName:    Natx;
  lpCommandLine:        Natx;
  lpProcessAttributes:  Natx;
  lpThreadAttributes:   Natx;
  bInheritHandles:      Int32;
  dwCreationFlags:      Nat32;
  lpEnvironment:        Natx;
  lpCurrentDirectory:   Natx;
  lpStartupInfo:        Natx;
  lpProcessInformation: Natx;
} Int32 {convention: stdcall;} "CreateProcessW" importFunction

{
  hHandle:        Natx;
  dwMilliseconds: Nat32;
} Nat32 {convention: stdcall;} "WaitForSingleObject" importFunction

{
  hProcess:  Natx;
  uExitCode: Nat32;
} Int32 {convention: stdcall;} "TerminateProcess" importFunction

{
  hProcess:   Natx;
  lpExitCode: Natx;
} Int32 {convention: stdcall;} "GetExitCodeProcess" importFunction

Process: [{
  private startupInfo: STARTUPINFOW;
  private processInfo: PROCESS_INFORMATION;

  start: [
    command: toUtf16;
    result: processInfo storageAddress
      startupInfo storageAddress
      0nx
      0nx
      0n32
      0
      0nx
      0nx
      command.data storageAddress
      0nx
      CreateProcessW;

    result 0 "CreateProcessW" getErrorMessage
  ];

  wait: [
    result: INFINITE processInfo.hProcess WaitForSingleObject;
    result WAIT_FAILED "WaitForSingleObject" getErrorMessage
  ];

  terminate: [
    exitCode:;
    result: exitCode processInfo.hProcess TerminateProcess;
    result 0 "TerminateProcess" getErrorMessage
  ];

  getExitCode: [
    out: {
      exitCode: Nat32;
      error:    String;
    };

    result:
      out.exitCode storageAddress
      processInfo.hProcess
      GetExitCodeProcess;

    result 0 "GetExitCodeProcess" getErrorMessage @out.!error

    @out
  ];

  private getErrorMessage: [
    code: failCode: functionName:;;;
    code failCode = ~ [String] [
      (functionName " failed, error code: " GetLastError) assembleString
    ] if
  ];

  private DIE: [
    (
      processInfo.hProcess
      processInfo.hThread
      startupInfo.hStdInput
      startupInfo.hStdOutput
      startupInfo.hStdError
    ) toIter [CloseHandle drop] eachStatic

    1n32 terminate drop
  ];

  private INIT: [
    STARTUPINFOW        !startupInfo
    PROCESS_INFORMATION !processInfo
  ];
}];
