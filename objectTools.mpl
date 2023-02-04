# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.cond"  use
"control.&&"      use
"control.Cond"    use
"control.Int16"   use
"control.Int32"   use
"control.Int64"   use
"control.Int8"    use
"control.Intx"    use
"control.Nat16"   use
"control.Nat32"   use
"control.Nat64"   use
"control.Nat8"    use
"control.Natx"    use
"control.Real32"  use
"control.Text"    use
"control.assert"  use
"control.between" use
"control.int?"    use
"control.nat?"    use
"control.real?"   use
"control.sized?"  use
"control.swap"    use
"control.times"   use
"control.tuple?"  use
"control.when"    use
"control.while"   use
"control.within"  use
"control.||"      use

# Object formatting

formatCodeStatic: [
  code: options:;;
  @options "expandCode" has ~ [@options.expandCode ~] || ["Code"] [
    "["
    i: 0; [i @code codeTokenCount = ~] [
      i 0 = ~ [" " &] when
      @code i codeTokenRead &
      i 1 + !i
    ] while

    "]" &
  ] if
];

formatCodeRefStatic: [
  coderef: options:;;
  "CodeRef"
];

formatCondStatic: [
  cond: options:;;
  cond isStatic ~ ["Cond"] [
    cond ["TRUE"] ["FALSE"] if
  ] if
];

formatDictStatic: [
  dict: options: new;;
  "{"
  @options "dictIndent" has [@options.dictIndent 1 + @options.!dictIndent] when
  i: 0; [i @dict fieldCount = ~] [
    @options "dictIndent" has [
      "\n" & @options.dictIndent ["  " &] times
    ] [
      i 0 = ~ [" " &] when
    ] if

    @dict i fieldName & ": " &
    @dict i fieldRead @options formatObjectStatic &

    @dict i fieldIsRef [@dict i fieldRead sized?] && [
      @dict i fieldRead isConst [" Cref"] [" Ref"] if &
    ] when

    @dict i fieldIsVirtual [@dict i fieldRead virtual? ~] && [" virtual" &] when

    ";" &
    i 1 + !i
  ] while

  @options "dictIndent" has [
    @options.dictIndent 1 - @options.!dictIndent
    @dict fieldCount 0 = ~ [
      "\n" & @options.dictIndent ["  " &] times
    ] when
  ] when

  "}" &
];

formatIntegerStatic: [
  integer: options:;;
  integer isStatic [
    DIGITS: ("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F");
    integer: integer new;
    zero: 0 integer cast;
    base: @options "base" has [@options.base] [10] if integer cast;
    negative: integer zero <;

    "" [
      DIGITS integer base mod Int32 cast negative [neg] when fieldRead swap &
      integer base / !integer
      integer zero = ~
    ] loop

    @options "base" has [@options.base 16 =] && ["0x" swap &] when
    negative ["-" swap &] when

    integer (
      [Int16 same] ["i16" &]
      [Int32 same] [       ]
      [Int64 same] ["i64" &]
      [Int8  same] ["i8"  &]
      [Intx  same] ["ix"  &]
      [Nat16 same] ["n16" &]
      [Nat32 same] ["n32" &]
      [Nat64 same] ["n64" &]
      [Nat8  same] ["n8"  &]
      [Natx  same] ["nx"  &]
    ) cond
  ] [
    integer (
      [Int16 same] ["Int16"]
      [Int32 same] ["Int32"]
      [Int64 same] ["Int64"]
      [Int8  same] ["Int8" ]
      [Intx  same] ["Intx" ]
      [Nat16 same] ["Nat16"]
      [Nat32 same] ["Nat32"]
      [Nat64 same] ["Nat64"]
      [Nat8  same] ["Nat8" ]
      [Natx  same] ["Natx" ]
    ) cond
  ] if
];

formatRealStatic: [
  real: options:;;
  real Real32 same ["Real32"] ["Real64"] if
];

formatStructStatic: [
  struct: options:;;
  @struct @options @struct {} same [@struct tuple? ~] || [formatDictStatic] [formatTupleStatic] if
];

formatTextStatic: [
  text: options:;;
  text isStatic ["\"" text & "\"" &] ["Text"] if
];

formatTupleStatic: [
  tuple: options: new;;
  "("
  @options "tupleIndent" has [@options.tupleIndent 1 + @options.!tupleIndent] when
  i: 0; [i @tuple fieldCount = ~] [
    @options "tupleIndent" has [
      "\n" & @options.tupleIndent ["  " &] times
    ] [
      i 0 = ~ [" " &] when
    ] if

    @tuple i fieldRead @options formatObjectStatic &

    @tuple i fieldIsRef [@tuple i fieldRead sized?] && [
      @tuple i fieldRead isConst [" Cref"] [" Ref"] if &
    ] when

    i 1 + !i
  ] while

  @options "tupleIndent" has [
    @options.tupleIndent 1 - @options.!tupleIndent
    @tuple fieldCount 0 = ~ [
      "\n" & @options.tupleIndent ["  " &] times
    ] when
  ] when

  ")" &
];

formatObjectStatic: [
  object: options:;;
  @object (
    [Cond same  ] [ object @options formatCondStatic   ]
    [Text same  ] [ object @options formatTextStatic   ]
    [code?      ] [@object @options formatCodeStatic   ]
    [codeRef?   ] [@object @options formatCodeRefStatic]
    [int?       ] [ object @options formatIntegerStatic]
    [isCombined ] [@object @options formatStructStatic ]
    [nat?       ] [ object @options formatIntegerStatic]
    [real?      ] [ object @options formatRealStatic   ]
  ) cond
];

# Object manipulation

cloneDict: [
  dict:;
  iterate: [
    i @dict fieldCount = [] [
      @dict i @transferField ucall
      i 1 + !i
      @iterate ucall
    ] uif
  ];

  i: 0;
  {@iterate ucall}
];

fieldNeedsVirtual: [
  dict: ordinal:;;
  @dict ordinal fieldIsVirtual [@dict ordinal fieldRead virtual? ~] &&
];

insertField: [
  dict: value: name: ordinal:;;;;
  [ordinal 0 @dict fieldCount between] "[ordinal] is out of bounds" assert
  iterate: [
    i ordinal = ~ [] [
      @value 0 unwrapField
      @value 0 fieldNeedsVirtual [virtual] [] uif
      name def
    ] uif

    i @dict fieldCount = [] [
      @dict i @transferField ucall
      i 1 + !i
      @iterate ucall
    ] uif
  ];

  i: 0;
  {@iterate ucall}
];

removeField: [
  dict: ordinal:;;
  [ordinal 0 @dict fieldCount within] "[ordinal] is out of bounds" assert
  iterate: [
    i @dict fieldCount = [] [
      i ordinal = [] [@dict i @transferField ucall] uif
      i 1 + !i
      @iterate ucall
    ] uif
  ];

  i: 0;
  {@iterate ucall}
];

transferField: [ # Should be ucall'ed to work
  [
    dict: ordinal:;;
    @dict ordinal unwrapField
    @dict ordinal fieldName
    @dict ordinal fieldNeedsVirtual
  ] call

  [virtual] [] uif def
];

unwrapField: [
  dict: ordinal:;;
  @dict ordinal fieldRead
  @dict ordinal fieldIsRef ~ [
    @dict ordinal fieldRead isCombined [cloneDict] [
      @dict ordinal fieldRead isStatic [new] [newVarOfTheSameType] if
    ] if
  ] when
];

unwrapFields: [
  dict:;
  @dict fieldCount [
    @dict i unwrapField
  ] times
];
