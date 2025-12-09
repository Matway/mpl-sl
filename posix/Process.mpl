# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"            use
"Array.toArray"          use
"String.String"          use
"String.assembleString"  use
"String.makeStringView"  use
"String.print"           use
"algorithm.any"          use
"algorithm.case"         use
"algorithm.cond"         use
"algorithm.each"         use
"algorithm.map"          use
"algorithm.objectValues" use
"algorithm.toIndex"      use
"algorithm.toIter"       use
"control.Int32"          use
"control.Intx"           use
"control.Natx"           use
"control.Ref"            use
"control.assert"         use
"control.compilable?"    use
"control.drop"           use
"control.exit"           use
"control.keep"           use
"control.pfunc"          use
"control.print"          use
"control.swap"           use
"control.touch"          use
"control.when"           use

"common.SIGKILL"     use
"common.WEXITSTATUS" use
"common.WIFEXITED"   use
"common.close"       use
"common.execvp"      use
"common.fcntl"       use
"common.fork"        use
"common.kill"        use
"common.pipe"        use
"common.read"        use
"common.waitpid"     use
"common.write"       use

"errno.errno"       use
"posix.FD_CLOEXEC"  use
"posix.F_SETFD"     use

Process: [{
  SCHEMA_NAME: "Process" virtual;

  create: [
    commands:;
    [@commands toIndex.size 0 >                                                                                       ] "Lack of commands"                        assert
    [([0 @commands toIndex dynamic.at makeStringView] [@commands toIter [makeStringView drop] each]) [compilable?] any] "Invalid item schema"                     assert
    [isCreated ~                                                                                                      ] "Attempted to initialize a Process twice" assert

    result: String;

    closeDescriptor: [
      descriptor:;
      descriptor close -1 = [
        "close" 1 errorExit
      ] when
    ];

    childPipe: {in: Int32; out: Int32;};
    @childPipe pipe -1 = ["pipe" errorMessage !result] [
      (FD_CLOEXEC) F_SETFD childPipe.out fcntl -1 = [
        "fcntl" errorMessage !result
        childPipe objectValues [closeDescriptor] each
      ] [
        r/w: [
          op: descriptor: buffer:;;;
          opName: @op 0 codeTokenRead virtual;
          [opName "read" = opName "write" = or] "Invalid operatin name" assert

          result: TRUE;

          size:      buffer storageSize;
          byteCount: size buffer storageAddress descriptor op;
          byteCount (
            [-1ix =] [opName 1 errorExit]

            [0ix =] [
              [opName "write" = ~ dynamic] "[write] transferred nothing" assert
              FALSE !result
            ]

            [size Intx cast <] [
              "insufficient [" opName & "]\n" & print
              1 exit
            ]

            [
              [byteCount size Intx cast =] "Size mismatch" assert
            ]
          ) cond

          result
        ];

        sources:   @commands [(1 touch "\00") assembleString] [String] map toArray;
        arguments: Natx Array;
        sources.size 1 + @arguments.setReserve
        sources [.data storageAddress] [Natx] map @arguments.append
        0nx                                       @arguments.append

        pid: fork;
        pid (
          -1 ["fork" errorMessage !result]

          0 [ # A child's body, not a parent's one
            childPipe.in closeDescriptor
            arguments.data storageAddress arguments.data execvp drop
            [write] childPipe.out errno r/w drop
            childPipe.out closeDescriptor
            1 exit
          ]

          [
            pid new !processId
            childPipe.out closeDescriptor

            buffer: Int32;
            [read] childPipe.in buffer r/w [
              "execvp" buffer errorMessage2 !result
              FALSE wait
            ] when

            childPipe.in closeDescriptor
          ]
        ) case
      ] if
    ] if

    result
  ];

  create: [makeStringView TRUE] [
    (1 touch) create
  ] pfunc;

  isCreated: [
    processId -1 = ~
  ];

  kill: [
    "kill" assertCreated
    "common.kill" use
    SIGKILL processId kill -1 = [
      "kill" 1 errorExit
    ] when
  ];

  wait: [
    needExitStatus: new virtual;
    "wait on" assertCreated

    statusCode: Int32;

    0 @statusCode needExitStatus ~ [Ref] when processId waitpid -1 = ["waitpid" 1 errorExit] when

    needExitStatus [
      statusCode WIFEXITED [statusCode WEXITSTATUS] [statusCode neg] if
    ] when
    -1 !processId
  ];

  private processId: -1;

  private DIE: [
    isCreated [
      FALSE wait
    ] when
  ];

  private INIT: [
    -1 !processId
  ];

  private assertCreated: [
    operationName:;
    [isCreated] "Attempted to " operationName & " a Process that is not initialized" & assert
  ];

  private errorExit: [
    name: statusCode:;;
    name errorMessage print
    statusCode exit
  ];

  private errorMessage: [
    functionName:;
    functionName errno errorMessage2
  ];

  private errorMessage2: [
    functionName: errorCode:;;
    (functionName " failed, result=" errorCode LF) assembleString
  ];
}];

toProcess: [
  Process [.create] keep swap
];
