# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"          use
"control.compilable?" use
"control.ensure"      use
"control.print"       use
"control.when"        use
"file.saveString"     use

"Process" use

"processCommon.<>"    use
"processCommon.check" use
"processCommon.mplc"  use
"processCommon.name"  use
"processCommon.test"  use

ProcessTest: [];

[
  process0: ref0: error0: ref1: mplc              toProcess isRef;; isRef;;
  process1: ref2: error1: ref3: (mplc "-version") toProcess isRef;; isRef;;
  process2: ref4: error2: ref5: "<INVALID>"       toProcess isRef;; isRef;;

  Process   isRef (    ) FALSE FALSE FALSE () check
  @process0 ref0  error0 ref1  FALSE TRUE  1  check
  @process1 ref2  error1 ref3  FALSE TRUE  0  check
  @process2 ref4  error2 ref5  TRUE  FALSE () check
] call

[
  filename: name;
  filename "«CommandLine» use
«Process»     use
«Span»        use
«String»      use
«algorithm»   use
«ascii»       use
«control»     use

natNumber: [
  source: Item:; toSpan;
  result: 0 Item cast;

  p10: 1 Item cast;
  source.iterReverse [
    digit: char: Nat32 cast [ascii.zero -] keep;;
    digit Item cast p10 * result + !result
    10 Item cast p10 * !p10
  ] each

  result
];

nat32: [@Nat32 natNumber];
nat64: [@Nat64 natNumber];

{argumentCount: Int32; argumentAddress: Natx;} Int32 () [
  arguments: toCommandLine2;
  arguments.size [3 =] «Exactly three arguments expected (program n acc)» ensure

  program: @arguments.next drop;
  n:       @arguments.next drop nat64;
  acc:     @arguments.next drop nat32 Int32 cast;
  n 1n64 > [
    TRUE (
      program
      n   2n64 / toString
      acc 1    + toString
    ) toProcess [() =] «[toProcess] failed» ensure 1 touch.wait
  ] [acc new] if
] «main» exportFunction" <>.span.stringView saveString [] "Failed to save file" ensure

  logCount: [
    n: acc:;;
    n 1n64 > [n 1n8 rshift acc 1 + logCount] [acc new] if
  ];

  filename ("18446744073709551615" "0") [18446744073709551615n64 0 logCount] test
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["ProcessTest passed\n" print] when
