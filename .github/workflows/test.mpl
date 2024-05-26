"Array"     use
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
  "" (
    additional
    "-o build/tests" filenameSuffix & ".exe" &
    "   build/tests" filenameSuffix & ".ll"  &
  ) [" " swap & &] each
];

mplcArguments: [
  additional: filenameSuffix:;;
  "" (
    additional unwrap

    "-I \"\""
    "-I tests"
    "-I windows"

    "-linker_option /DEFAULTLIB:ws2_32.lib"

    "-ndebug"

    "-o build/tests" filenameSuffix & ".ll" &

    ".github/workflows/entryPoint.mpl"
  ) [" " swap & &] each
];

showTiming: [(runningTime.get LF) printList];

runCommand: [
  command: arguments:;;
  needsExitStatus: TRUE;
  exitStatus: needsExitStatus command arguments & toProcess ["" =] "[toProcess] on \"" command & "\" failed" & ensure.wait;
  [exitStatus 0n32 =] "\n" command & " filed" & ensure
  showTiming
];

runClang: [additionalArguments: filenameSuffix:;; "clang" additionalArguments filenameSuffix clangArguments runCommand];
runMplc:  [additionalArguments: filenameSuffix:;; mplc    additionalArguments filenameSuffix mplcArguments  runCommand];
runTests: [filenameSuffix:;                       "build/tests" filenameSuffix & ""                         runCommand];

testConfiguration: [
  extraArgMplc: extraArgClang: configurationName:;;;
  filenameSuffix: "_" configurationName &;
  showTiming
  extraArgMplc  filenameSuffix runMplc
  extraArgClang filenameSuffix runClang
  filenameSuffix               runTests
];

tasks: (
  [("-D TCP_PORT=6600" "-D DEBUG=TRUE") "-O3" "assertO3" testConfiguration]
  [("-D TCP_PORT=6601"                ) "-O3" "ndebugO3" testConfiguration]
  [("-D TCP_PORT=6602" "-D DEBUG=TRUE") "-O0" "assertO0" testConfiguration]
  [("-D TCP_PORT=6603"                ) "-O0" "ndebugO0" testConfiguration]
);

[
  FALSE "cmd /C chcp 65001" toProcess "" = [.wait] [drop drop] if

  (
    "MPL Compiler: «" mplc "»" LF

    "Working threads count: " getHardwareConcurrency LF
    "Parallel tasks count:  " tasks fieldCount       LF
  ) printList

  threads: Thread Array [tasks fieldCount swap.setReserve] keep;
  tasks [
    task:;
    [drop task 0n32] 0nx 0 toThread3 @threads.append # Attaching thread to the array so that corresponding execution outlive the scope it will be started in
  ] each
] call

{} Int32 {} [0] "main" exportFunction
