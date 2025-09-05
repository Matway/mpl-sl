"String"    use
"algorithm" use
"control"   use

"Process"             use
"Thread"              use
"hardwareConcurrency" use
"runningTime"         use

mplc: ["mplc"];
mplc: [MPLC TRUE] [MPLC] pfunc;

clangArguments: [
  additional: filenameSuffix:;;
  additional unwrap
  "-o" "out/tests" filenameSuffix & ".exe" &
  "out/tests"      filenameSuffix & ".ll"  &
];

mplcArguments: [
  additional: filenameSuffix:;;

  additional unwrap

  "-D" "PLATFORM_TESTS=\"windows/tests\""

  "-I" ""
  "-I" "tests"
  "-I" "windows"

  "-linker_option" "/DEFAULTLIB:ws2_32.lib"

  "-ndebug"

  "-o" "out/tests" filenameSuffix & ".ll" &

  ".github/workflows/entryPoint.mpl"
];

showTiming: [(runningTime.get LF) printList];

runCommand: [
  arguments:;
  command: 0 arguments @;
  needsExitStatus: TRUE;
  process: error: needsExitStatus arguments dynamic toProcess;;
  [error         "" =] "[toProcess] on \"" command & "\" failed" & ensure
  [@process.wait 0  =] "\n"                command & " failed"   & ensure
  showTiming
];

runClang: [additionalArguments: filenameSuffix:;; ("clang"                      additionalArguments filenameSuffix clangArguments) runCommand];
runMplc:  [additionalArguments: filenameSuffix:;; (mplc                         additionalArguments filenameSuffix mplcArguments ) runCommand];
runTests: [                     filenameSuffix:;  ("out/tests" filenameSuffix &                                                  ) runCommand];

testConfiguration: [
  extraArgMplc: extraArgClang: configurationName:;;;
  filenameSuffix: "_" configurationName &;
  showTiming
  extraArgMplc  filenameSuffix runMplc
  extraArgClang filenameSuffix runClang
  filenameSuffix               runTests
];

tasks: (
  [("-D" "TCP_PORT=6600" "-D" "DEBUG=TRUE") ("-O3") "assertO3" testConfiguration]
  [("-D" "TCP_PORT=6601"                  ) ("-O3") "ndebugO3" testConfiguration]
  [("-D" "TCP_PORT=6602" "-D" "DEBUG=TRUE") ("-O0") "assertO0" testConfiguration]
  [("-D" "TCP_PORT=6603"                  ) ("-O0") "ndebugO0" testConfiguration]
);

{} Int32 {} [
  [
    (
      "MPL Compiler: «" mplc "»" LF

      "Working threads count: " getHardwareConcurrency LF
      "Parallel tasks count:  " tasks fieldCount       LF
    ) printList

    threads: (tasks fieldCount [Thread] times);
    (@threads tasks) wrapIter [
      thread: task: unwrap;;
      [drop task 0n32] 0nx 0 @thread.create
    ] each
  ] call

  0
] "main" exportFunction
