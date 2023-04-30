# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"          use
"control.AsRef"       use
"control.Cond"        use
"control.Ref"         use
"control.compilable?" use
"control.dup"         use
"control.ensure"      use
"control.print"       use
"control.when"        use

"control.nil?" use

controlTest: [];

# nil?
[
  check: [
    source: nilExpected: known: dirty:;;;;
    nil: ref: @source nil? isRef;;

    do: [
      predicate: message:;;
      @predicate "[nil?] on statically " known ["known "] ["unknown "] if nilExpected ["Nil"] ["reference"] if " " message & & & & ensure
    ];

    [@source isDirty dirty =] "changed argument's purity"                                 do
    [ref ~                  ] "produced reference"                                        do
    [nil isStatic known =   ] "produced statically " known ["un" &] when "known result" & do
    [nil nilExpected =      ] "produced wrong result"                                     do
  ];
  abortStatic: {PRE: [Cond dynamic]; CALL: []; placeholder: Cond;};
  IsDirty: IsNil: IsStatic: [TRUE] dup dup;;;

  @abortStatic                 IsNil ~ IsStatic   IsDirty ~ check
  Cond AsRef dynamic .data     IsNil ~ IsStatic ~ IsDirty   check
  Cond Ref                     IsNil   IsStatic   IsDirty   check
  Cond Ref AsRef dynamic .data IsNil   IsStatic ~ IsDirty   check
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["controlTest passed\n" print] when
