# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"           use
"Array.toArray"         use
"String.String"         use
"String.assembleString" use
"String.makeStringView" use
"String.printList"      use
"algorithm.any"         use
"algorithm.case"        use
"algorithm.each"        use
"algorithm.toIter"      use
"control.Int32"         use
"control.Nat32"         use
"control.Nat8"          use
"control.Ref"           use
"control.assert"        use
"control.drop"          use
"control.exit"          use
"control.keep"          use
"control.pfunc"         use
"control.swap"          use
"control.when"          use
"control.wrap"          use

"kernel32.CloseHandle"         use
"kernel32.CreateProcessW"      use
"kernel32.GetExitCodeProcess"  use
"kernel32.GetLastError"        use
"kernel32.INFINITE"            use
"kernel32.PROCESS_INFORMATION" use
"kernel32.SECURITY_ATTRIBUTES" use
"kernel32.STARTUPINFOW"        use
"kernel32.TerminateProcess"    use
"kernel32.WAIT_OBJECT_0"       use
"kernel32.WaitForSingleObject" use
"unicode.utf16"                use

CommandEncoder: {
  crt: [
    arguments: toIter;
    result: Nat8 Array;

    @arguments.next [
      program: makeStringView;
      [program [0x22n8 =] any ~] "[CommandEncoder.crt], first argument (program) contains quote character «\22»" assert

      "\22"   @result.append
      program @result.append
      "\22"   @result.append

      last: Nat8;
      @arguments [
        argument: makeStringView;
        freeQuoteCount: 0;

        0n8 !last
        " \22" @result.append
        argument [
          character: new;
          character (
            0x22n8 ["\5C\22" @result.append]
            0x5Cn8 ["\5C\5C" @result.append]
            [
              last 0x5Cn8 = [
                freeQuoteCount 1 + !freeQuoteCount
                "\22" @result.append
              ] when
              character @result.append
            ]
          ) case
          character new !last
        ] each

        freeQuoteCount 2 mod 0 = ["\22"] ["\22\22"] if @result.append
      ] each
    ] [
      drop
      DEBUG ["[CommandEncoder.crt], command (program) is not provided" failProc] when
    ] if

    @result
  ];

  plain: [
    arguments: toIter;

    argument: valid: @arguments.next;;
    [valid] "Provided empty iterator" assert
    result: argument makeStringView toArray;

    @arguments [
      " "            @result.append
      makeStringView @result.append
    ] each

    @result
  ];
};

Process: [{
  SCHEMA_NAME: "Process" virtual;

  create: [{} create2];

  create2: [
    arguments: options:;;

    processInformation: PROCESS_INFORMATION;
    startupInfo:        STARTUPINFOW;
    startupInfo storageSize Nat32 cast @startupInfo.!cb

    @processInformation
    @startupInfo
    0nx
    0nx
    0n32
    0
    SECURITY_ATTRIBUTES Ref
    SECURITY_ATTRIBUTES Ref
    @arguments @options "encodeCommand" has [@options.encodeCommand] [CommandEncoder.crt] uif.span.stringView utf16.data storageAddress
    0nx
    CreateProcessW 0 = ~ [
      processInformation.hThread CloseHandle 0 = [
        "CloseHandle" reportError
      ] when

      processInformation.hProcess new !handle

      String
    ] [
      "CreateProcessW" errorMessage
    ] if
  ];

  create2: [drop makeStringView TRUE] [
    swap 1 wrap swap create2
  ] pfunc;

  isCreated: [
    handle 0nx = ~
  ];

  kill: [
    "kill" assertCreated

    1n32 handle TerminateProcess 0 = [
      "TerminateProcess" reportError
      1 exit
    ] when
  ];

  wait: [
    needExitCode: new virtual;
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

      result Int32 cast
    ] when

    handle CloseHandle 0 = ["CloseHandle" reportError] when

    0nx !handle
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
    [isCreated] "Attempted to " operationName & " a Process that is not initialized" & assert
  ];

  private errorMessage: [
    functionName:;
    (functionName " failed, result=" GetLastError LF) assembleString
  ];

  private reportError: [
    functionName:;
    (functionName errorMessage LF) printList
  ];
}];

toProcess: [
  {} toProcess2
];

toProcess2: [
  Process [.create2] keep swap
];
