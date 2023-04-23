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
"control.||"          use

"control.nil?" use

controlTest: [];

# nil?
[
  abortStatic: {PRE: [Cond dynamic]; CALL: []; placeholder: Cond;};
  input: @abortStatic;

  check: [
    nil: ref: nilExpected: known: hasToValidateImpurity:;;;;;
    impurnessFound: hasToValidateImpurity [@input isDirty] &&;
    do: [
      predicate: message:;;
      header: known ["known "] ["unknown "] if nilExpected ["Nil"] ["reference"] if &;
      @predicate "[nil?] on statically " header " " message & & & ensure
    ];

    [impurnessFound ~    ] "makes an argument dirty"                                   do
    [ref ~               ] "produces reference"                                        do
    [nil isStatic known =] "produces statically " known ["un" &] when "known result" & do
    [nil nilExpected =   ] "produces wrong result"                                     do
  ];
  HasToValidateImpurity: IsNil: IsStatic: [TRUE] dup dup;;;

  @input                       nil? isRef IsNil ~ IsStatic   HasToValidateImpurity   check
  Cond AsRef dynamic .data     nil? isRef IsNil ~ IsStatic ~ HasToValidateImpurity ~ check
  Cond Ref                     nil? isRef IsNil   IsStatic   HasToValidateImpurity ~ check
  Cond Ref AsRef dynamic .data nil? isRef IsNil   IsStatic ~ HasToValidateImpurity ~ check
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["controlTest passed\n" print] when
