# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.printList"    use
"algorithm.="         use
"algorithm.each"      use
"algorithm.toIter"    use
"control.&&"          use
"control.compilable?" use
"control.drop"        use
"control.ensure"      use
"control.print"       use
"control.when"        use
"file.saveString"     use

"Process" use

"processCommon.<>"    use
"processCommon.check" use
"processCommon.name"  use
"processCommon.test"  use

CommandEncoderTest: [];

[
  [[("") toProcess] compilable? ~] "Compilable" ensure
  [[""   toProcess] compilable? ~] "Compilable" ensure

  #[(" ") "\" \""]
  #[("a") "\"a\""]

  (
    [
      (
        "\"a b c\""
        "d"
        "e"
      ) "(«\\«a b c\\»» «d» «e»)"
    ]

    [
      (
        "ab\"c"
        "\\\\"
        "d"
      ) "(«ab\\\"c» «\\\\\\\\» «d»)"
    ]

    [
      (
        "a\\\\\\b"
        "d\"e f\"g"
        "h"
      ) "(«a\\\\\\\\\\\\b» «d\\«e f\\»g» «h»)"
    ]

    [
      (
        "a\\\\b c"
        "d"
        "e"
      ) "(«a\\\\\\\\b c» «d» «e»)"
    ]

    [
      (
        "ab\" c d"
      ) "(«ab\\\" c d»)"
    ]
  ) [
    A: B: call;;
    filename: name;

    filename "«CommandLine» use
«String»      use
«algorithm»   use
«control»     use

A: " B & " toIter;

{
  argumentCount:   Int32;
  argumentAddress: Natx;
} Int32 () [
  arguments: toCommandLine2;
  @arguments.next [] «Command line is empty» ensure drop
  arguments A = ~ [
    arguments printCommandLine LF print
    A         printCommandLine LF print
    «Error, Command line mismatch\n» print
    1 exit
  ] when

  0
] «main» exportFunction" & <>.span.stringView saveString [] "Failed to save file" ensure

    filename A 0 test
  ] each
] _:;#call

[
  process: ref0: error: ref1: ("cmd.exe" "/c dir /og \"c:\\Program Files\\\"") toIter dynamic {encodeCommand: [CommandEncoder.plain];} toProcess2 isRef;; isRef;;
  @process ref0 error ref1 FALSE TRUE 0 check
] call

[
  text0: ("cmd.exe" "/c" "dir /og \"c:\\Program Files\\\"") toIter dynamic CommandEncoder.plain.span.stringView;
  text1: ("cmd.exe" "/c dir /og \"c:\\Program Files\\\"")   toIter dynamic CommandEncoder.plain.span.stringView;

  ("«" text0 "»" LF) printList
  ("«" text1 "»" LF) printList
  [text0 text1 = ] "Not equal" ensure
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["CommandEncoderTest passed\n" print] when
