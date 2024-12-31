"Process"   use
"String"    use
"algorithm" use
"control"   use

# THE TRANSITION: Remove the function so that built-in one will be used.
# Without this function only the first two items of [tasks] will be handled correctly, and the rest will be replaced with the first item(s).
&: [2 wrap assembleString];

tasks: (
  [["-D" "TCP_PORT=6600" "-D" "DEBUG=TRUE"] "-O3" "assertO3"]
  [["-D" "TCP_PORT=6601"                  ] "-O3" "ndebugO3"]
  [["-D" "TCP_PORT=6602" "-D" "DEBUG=TRUE"] "-O0" "assertO0"]
  [["-D" "TCP_PORT=6603"                  ] "-O0" "ndebugO0"]
);

mplc: ["mplc"];
mplc: [MPLC TRUE] [MPLC] pfunc;

additionalLibrary: [
  PLATFORM (
    "linux"   ["m"]
    "windows" ["ws2_32.lib"]
    [
      "Unknown platform" raiseStaticError
    ]
  ) case
];

executableExtension: [
  PLATFORM (
    "linux"   [""]
    "windows" [".exe"]
    [
      "Unknown platform" raiseStaticError
    ]
  ) case
];

clangArguments: [
  additional: filenameSuffix:;;
  additional
  "-l" additionalLibrary &
  "-o" "out/tests" filenameSuffix & executableExtension &
  "out/tests" filenameSuffix & ".ll"  &
];

mplcArguments: [
  additional: filenameSuffix:;;
  additional
  "-D" "PLATFORM_TESTS=\"" PLATFORM & "/tests\"" &
  "-I" ""
  "-I" "tests"
  "-I" PLATFORM
  "-ndebug"
  "-o" "out/tests" filenameSuffix & ".ll" &
  ".github/workflows/entryPoint.mpl"
];

taskArguments: [
  extraArgMplc: extraArgClang: configurationName: call;;;
  filenameSuffix: "_" configurationName &;
  (
    "out/sequentialTasks"

    "<separator>"
    mplc
    @extraArgMplc filenameSuffix mplcArguments

    "<separator>"
    "clang"
    extraArgClang filenameSuffix clangArguments

    "<separator>"
    "out/tests" filenameSuffix &
  )
];

offloadTask: [
  task:;
  @task taskArguments toProcess
];

{} Int32 {} [
  result: 0;

  [
    (
      "MPL Compiler: «" mplc "»"                LF
      "Parallel tasks count: " tasks fieldCount LF
    ) printList

    processes: (
      tasks [
        task:;
        process: error: @task offloadTask;;

        error "" = ~ [
          1 !result
          configurationName: task; drop drop
          ("Failed to start child for \"" configurationName "\", " error) printList
        ] when

        process
      ] each
    );

    @processes [
      process:;
      process.isCreated [
        exitStatus: TRUE @process.wait;
        # TODO: Do not [cast]
        exitStatus Int32 cast 0 = ~ [
          ("Child terminated with non-zero exit status: " exitStatus LF) printList
          1 !result
        ] when
      ] when
    ] each
  ] call

  result
] "main" exportFunction
