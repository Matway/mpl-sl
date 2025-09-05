# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"           use
"String.String"         use
"String.assembleString" use
"String.makeStringView" use
"String.printList"      use
"algorithm.any"         use
"algorithm.case"        use
"algorithm.each"        use
"algorithm.tail"        use
"algorithm.toIter"      use
"control.Int32"         use
"control.Nat32"         use
"control.Nat8"          use
"control.assert"        use
"control.drop"          use
"control.exit"          use
"control.keep"          use
"control.pfunc"         use
"control.swap"          use
"control.times"         use
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
    result: @arguments 3 getBuffer; # Two quotes per argument, plus one space between arguments (we do not count any quotes or slashes that may be present in a command)

    program: @arguments consume makeStringView;
    [program [0x22n8 =] any ~] "[CommandEncoder.crt], First argument (program) contains quote character «\"»" assert
    "\""    @result.append
    program @result.append
    "\""    @result.append

    @arguments [
      argument: makeStringView;
      freeSlashCount: 0;
      " \"" @result.append
      argument [
        codeUnit: new;
        codeUnit (
          0x22n8 [
            result.size freeSlashCount 2 + + @result.enlarge # [2 +] for \"
            unassigned: @result freeSlashCount 2 + tail;
            freeSlashCount 1 + [0x5Cn8 i @unassigned.at set] times
            0x22n8 @result.last set
            0
          ]

          0x5Cn8 [
            "\\" @result.append
            freeSlashCount 1 +
          ]

          [
            codeUnit @result.append
            0
          ]
        ) case !freeSlashCount
      ] each
      freeSlashCount 0 = ~ [
        result.size freeSlashCount + @result.enlarge
        slashes: @result freeSlashCount tail;
        freeSlashCount [0x5Cn8 i @slashes.at set] times
      ] when
      "\"" @result.append
    ] each

    result
  ];

  plain: [
    arguments: toIter;
    result: @arguments 1 getBuffer; # One space between arguments

    program: @arguments consume makeStringView;
    program @result.append
    @arguments [
      " "            @result.append
      makeStringView @result.append
    ] each

    result
  ];

  # Internal

  consume: [
    source:;
    first: valid: @source.next;;
    [valid] "Command (program) is not provided" assert
    result: first;
    [result makeStringView.size 0 = ~] "Command (program) is empty" assert

    result
  ];

  getBuffer: [
    source: multiplier:;;
    iter: @source toIter;
    @source @iter is [ # We should not try to exhaust the source
      Nat8 Array
    ] [
      count: 0;
      size:  0;
      @iter [
        1                   count + !count
        makeStringView.size size  + !size
      ] each
      [count 0 = ~] "The source is empty" assert
      count multiplier * 1 - size + Nat8 Array [.setReserve] keep # One space less
    ] if
  ];
};

Process: [{
  SCHEMA_NAME: "Process" virtual;

  create: [
    {} create2
  ];

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
    0nx SECURITY_ATTRIBUTES addressToReference
    0nx SECURITY_ATTRIBUTES addressToReference
    @arguments @options "encodeCommand" has [@options.encodeCommand] [CommandEncoder.crt] if.span.stringView utf16.data storageAddress
    0nx
    CreateProcessW 0 = ~ [
      processInformation.hThread closeHandle

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

    handle closeHandle
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
    [isCreated] "Attempted to apply " operationName & " on a Process that is not initialized" & assert
  ];

  private closeHandle: [
    handle:;
    handle CloseHandle 0 = ["CloseHandle" reportError] when
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

ProcessSchema: 0nx Process addressToReference virtual;

toProcess: [
  {} toProcess2
];

toProcess2: [
  Process [.create2] keep swap
];
