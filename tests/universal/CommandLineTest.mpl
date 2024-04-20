# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Span.Span"           use
"String.StringView"   use
"algorithm.each"      use
"control.&&"          use
"control.Cond"        use
"control.Int32"       use
"control.Natx"        use
"control.callable?"   use
"control.compilable?" use
"control.drop"        use
"control.ensure"      use
"control.print"       use
"control.times"       use
"control.when"        use

"CommandLine" use

[
  Natx 0 toCommandLine2 CommandLine set
] call

testConstructor: [
  size: ctor:;;
  address: size Natx cast;
  commands: ref: address size ctor isRef;;

  [ref ~                                       ] "Produced reference" ensure
  [@commands callable? ~                       ] "Produced callable" ensure
  [commands storageSize Natx Span storageSize =] "Produced huge object" ensure
  [commands.size size =                        ] "Produced wrong size" ensure
];

[
  0 [drop drop CommandLine dynamic] testConstructor
  0 [drop drop CommandLine        ] testConstructor
] call

[
  sizes: (0 1);
  do: [@toCommandLine2 testConstructor];
  sizes         @do each
  sizes dynamic @do each
] call

[
  check: [
    size:;
    address: size Natx cast;
    command: commandIsRef: valid: validIsRef: address size toCommandLine2.next isRef;; isRef;;

    [commandIsRef ~          ] "Produced reference" ensure
    [validIsRef ~            ] "Produced reference" ensure

    [@command StringView same] "Produced wrong result" ensure
    [@valid   Cond same      ] "Produced wrong result" ensure

    [command.size 0 =        ] "Produced wrong length" ensure
    [valid ~                 ] "Produced wrong result" ensure
  ];

  (0 0 dynamic) [check] each
] call

[
  strzs: (
    "\00"
    "a\00"
    "aa\00"
    "aaa\00"
    "aaab\00"
    "aaabb\00"
    "aaabbb\00"
  );

  argvs: (strzs [storageAddress] each);

  argv: argvs storageAddress;
  argc: argvs fieldCount;

  commands0: argv argc toCommandLine2;
  commands1: commands0 new;

  [commands0.source.data commands1.source.data =] "Produced wrong source" ensure
  [commands0.source.size commands1.source.size =] "Produced wrong size" ensure
  [commands0.size argc =                        ] "Produced wrong size" ensure

  argc [
    check: [
      view: text:;;
      [view.data storageAddress text storageAddress =     ] "Produced wrong source" ensure
      [view.size 1 +            text textSize Int32 cast =] "Produced wrong length" ensure
    ];

    command0:                i commands0.at;
    strz:                    i strzs @;
    command1: command1Valid: @commands1.next;;

    [command1Valid] "Produced invalid result" ensure
    command0 strz check
    command1 strz check
  ] times

  [commands0.size argc =] "Produced wrong size" ensure
  [commands1.size 0 =   ] "Produced wrong size" ensure

  command1: valid: @commands1.next;;
  [valid ~          ] "Produced wrong result" ensure
  [command1.size 0 =] "Produced wrong length" ensure
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["CommandLineTest passed\n" print] when
