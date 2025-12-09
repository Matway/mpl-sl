"String"    use
"algorithm" use
"control"   use

"Process" use

# THE TRANSITION: 0) Remove the function so that built-in one will be used. See the item #1
&: [2 wrap assembleString];

tasks: (
  [[("-D" "TCP_PORT=6600" "-D" "DEBUG=TRUE") dynamic unwrap] ("-O3" "assertO3") dynamic unwrap] # THE TRANSITION: 1) Do not make references unknown. Only first tasks handled correctly, but not the rest ones
  [[("-D" "TCP_PORT=6601"                  ) dynamic unwrap] ("-O3" "ndebugO3") dynamic unwrap] #
  [[("-D" "TCP_PORT=6602" "-D" "DEBUG=TRUE") dynamic unwrap] ("-O0" "assertO0") dynamic unwrap] #
  [[("-D" "TCP_PORT=6603"                  ) dynamic unwrap] ("-O0" "ndebugO0") dynamic unwrap] #
);

mplc: ["mplc"];
mplc: [MPLC TRUE] [MPLC] pfunc;

additionalLibrary: [
  PLATFORM (
    "linux"   ["m"]
    "macos"   [""]
    "windows" ["ws2_32.lib"]
    [
      "Unknown platform" raiseStaticError
    ]
  ) case
];

executableExtension: [
  PLATFORM (
    [(["linux" =] ["macos" =]) meetsAny] [""]
    ["windows" =]                        [".exe"]
    [
      "Unknown platform" raiseStaticError
    ]
  ) cond
];

clangArguments: [
  additional: filenameSuffix:;;
  additional
  additionalLibrary () = ~ ["-l" additionalLibrary &] when
  "-o" "out/tests" filenameSuffix & executableExtension &
  "out/tests" filenameSuffix & ".ll"  &
];

mplcArguments: [
  additional: filenameSuffix:;;
  additional
  "-D" "FILENAME_SUFFIX=\"" filenameSuffix &       "\"" &
  "-D" "MPLC=\""            mplc           &       "\"" &
  "-D" "PLATFORM_TESTS=\""  PLATFORM       & "/tests\"" &
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
          ("Failed to start child for configuration \"" configurationName "\", " error) printList
        ] when

        process
      ] each
    );

    @processes [
      process:;
      process.isCreated [
        exitStatus: TRUE @process.wait;
        exitStatus 0 = ~ [
          ("Child terminated with non-zero exit status: " exitStatus LF) printList
          1 !result
        ] when
      ] when
    ] each
  ] call

  result
] "main" exportFunction
