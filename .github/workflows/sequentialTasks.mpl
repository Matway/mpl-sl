# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"       use
"CommandLine" use
"String"      use
"algorithm"   use
"control"     use

"Process"     use
"runningTime" use

{
  argumentCount:   Int32;
  argumentAddress: Natx;
} Int32 {} [
  arguments: toCommandLine2;
  [arguments.size 1 >] "[sequentialTasks], Not enough arguments\n" ensure

  buildInputs: [
    arguments: toIter;
    [arguments new.next ["<separator>" =] [drop TRUE] if] "There is argument before \"<separator>\"\n" ensure
    result: StringView Array Array dynamic; # THE TRANSITION: Do not make object unknown. Regardless of function's input [result] is empty

    # Preconditions: arguments have to match ("<separator>", (freeFormText)*)*
    doUnchecked: [
      recursive
      @arguments.next [
        argument:;
        argument "<separator>" = [StringView Array @result.append] [argument @result dynamic.last.append] if
        doUnchecked
      ] [drop] if
    ];

    doUnchecked

    result
  ];

  launch: [
    commands:;
    [commands.size 0 >] "Attempted to start a process without specifying a command\n" ensure
    startPoint:     runningTime.get;
    process: error: commands toProcess;;

    error "" = ~ [
      error print
      1 exit
    ] when

    exitStatus: TRUE @process.wait;
    time:       runningTime.get startPoint -;

    exitStatus 0 = ~ [
      ("\"" commands.data "\"" " terminated with status " exitStatus LF) printList
      1 exit
    ] when

    (time " \"" commands.data "\"\n") printList
  ];

  @arguments 1 unhead buildInputs [launch] each

  0
] "main" exportFunction
