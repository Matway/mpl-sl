# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"           use
"Array.toArray"         use
"String.String"         use
"String.StringView"     use
"String.assembleString" use
"String.makeStringView" use
"String.printList"      use
"Process.toProcess"     use
"algorithm.="           use
"algorithm.>"           use
"algorithm.map"         use
"algorithm.toIter"      use
"control.&&"            use
"control.Nat8"          use
"control.drop"          use
"control.dup"           use
"control.ensure"        use
"control.exit"          use
"control.keep"          use
"control.pfunc"         use
"control.swap"          use
"control.when"          use
"control.||"            use

filenameSuffix: ["_default"];
filenameSuffix: [FILENAME_SUFFIX TRUE] [FILENAME_SUFFIX] pfunc;

mplc: ["mplc"];
mplc: [MPLC TRUE] [MPLC] pfunc;

<>: [
  source: toIter;
  result: source.size Nat8 Array [.setReserve] keep;
  [
    first: @source.next swap; [
      #[first 0x22n8 = ~] "«\"» is not supported yet" ensure
      first "«" toIter.next drop = [
        second: @source.next [] "Unterminated character" ensure;
        [
          second "«" toIter [.next drop drop] keep.next drop = [
            second "»" toIter [.next drop drop] keep.next drop =
          ] ||
        ] "Invalid character terminator" ensure

        "\"" toIter.next drop
      ] [first] if @result.append TRUE
    ] &&
  ] loop

  result
];

name: {
  names: String Array;

  CALL: [
    ("out/test" filenameSuffix "_" names.size ".mpl") assembleString @names.append
    names.last makeStringView
  ];
};

check: [
  process: ref0: error: ref1: hasError: created: exitStatus:;;;;;;;
  valid: ref2: process.isCreated isRef;;
  [ref2 ~                                             ] "Wrong reference status2"                         ensure
  [ref1 ~                                             ] "Wrong reference status1"                         ensure
  [ref0 ~                                             ] "Wrong reference status0"                         ensure
  [error () hasError [>] [=] if                       ] "Invalid error trait"                             ensure
  [process.SCHEMA_NAME "Process" =                    ] "[Process] produced a wrong [.SCHEMA_NAME]"       ensure
  [process dup "SCHEMA_NAME" fieldIndex fieldIsVirtual] "[Process] produced a non-virtual [.SCHEMA_NAME]" ensure
  [process.isCreated created =                        ] "[Process.isCreated] produced a wrong result"     ensure
  [created [TRUE @process.wait exitStatus = ~] && ~   ] "[process.wait] produced a wrong result"          ensure
];

test: [
  filename: arguments: status:;;;
  command:
    (
      mplc filename "-o" (filename ".ll") assembleString "-I" "" "-I" "windows"
    ) [makeStringView] @StringView map toArray
  ;
  #("«" command CommandEncoder.crt.span.stringView toString "»" LF) printList
  compiler: command toProcess [() =] "[toProcess] has been failed" ensure;
  TRUE @compiler.wait [0 =] mplc " has been failed" & ensure

  command:
    (
      "clang" (filename ".ll") assembleString "-o" (filename ".exe") assembleString
    ) [makeStringView] @StringView map toArray
  ;
  #("«" command CommandEncoder.crt.span.stringView toString "»" LF) printList
  clang: command toProcess [() =] "[toProcess] has been failed" ensure;
  TRUE @clang.wait [0 =] "clang has been failed" ensure

  command:
    (
      (filename ".exe") assembleString #A unwrap
    ) [makeStringView] @StringView map toArray
    arguments toIter [makeStringView] @StringView map dynamic swap [.append] keep
  ;
  #("«" command CommandEncoder.crt.span.stringView toString "»" LF) printList
  program: command toProcess [() =] "[toProcess] has been failed" ensure;
  exitStatus: TRUE @program.wait;
  exitStatus status = ~ [
    ("Program terminated with a wrong status " exitStatus ", while expected " status LF) printList
    1 exit
  ] when
];
