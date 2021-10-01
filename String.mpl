# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"             use
"algorithm.cond"          use
"algorithm.countIter"     use
"algorithm.makeArrayIter" use
"algorithm.toIndex"       use
"algorithm.toIter"        use
"algorithm.toTextIter"    use
"control.&&"              use
"control.Cond"            use
"control.Cref"            use
"control.Int32"           use
"control.Int64"           use
"control.Nat32"           use
"control.Nat64"           use
"control.Nat8"            use
"control.Natx"            use
"control.Text"            use
"control.assert"          use
"control.between"         use
"control.drop"            use
"control.dup"             use
"control.hasSchemaName"   use
"control.isInt"           use
"control.isNat"           use
"control.isReal"          use
"control.pfunc"           use
"control.printf"          use
"control.times"           use
"control.when"            use
"control.while"           use
"control.within"          use
"control.||"              use
"conventions.cdecl"       use
"memory.memcmp"           use
"memory.memcpy"           use

hasLogs: [
  hasLogsImpl: [FALSE];
  hasLogsImpl: [@HAS_LOGS TRUE] ["Invalid value for HAS_LOGS" raiseStaticError] pfunc;
  hasLogsImpl: [HAS_LOGS Cond same] [HAS_LOGS] pfunc;
  hasLogsImpl: [HAS_LOGS () same] [TRUE] pfunc;
  hasLogsImpl
];

{arg: 0nx;} 0nx {convention: cdecl;} "strlen" importFunction

Char: [{
  codepoint: Int32;

  equal:   [dup Text same [toChar] when .codepoint codepoint =];
  greater: [dup Text same [toChar] when .codepoint codepoint >];
  hash:    [codepoint Nat32 cast];
  less:    [dup Text same [toChar] when .codepoint codepoint <];
}];

REPLACEMENT_CHARACTER: [0xFFFD toChar];

isHeadUnit: [unit:; unit 0x80n8 < [unit 0xC0n8 0xF8n8 within] ||];
isValidCodepoint: [codepoint:; codepoint 0 0xD7FF between [codepoint 0xE000 0x10FFFF between] ||];

toChar: [Int32 same] [
  codepoint:;
  [codepoint isValidCodepoint] "invalid UTF-8 code point" assert
  char: Char;
  codepoint @char.@codepoint set
  @char
] pfunc;

toChar: [Text same] [decode .next drop] pfunc;

intPow: [
  up:   new;
  down: new;
  up 0 = [
    1 down cast
  ] [
    up 0 < [
      up neg @up set
      1 down cast down / @down set
    ] when

    acc: 1 down cast;
    [
      up 4 mod 0 = [
        sqrDown: down down *;
        sqrDown sqrDown * @down set
        up 4 / @up set
      ] [
        up 2 mod 0 = [
          down down * @down set
          up 2 / @up set
        ] [
          down acc * @acc set
          up 1 - @up set
        ] if
      ] if

      up 0 = ~
    ] loop
    acc
  ] if
];

toStringView: [
  in:;
  @in (Nat8 Cref Int32) same [] [@in printStack drop "[toStringView], invalid argument, (Nat8 Cref Int32) expected" raiseStaticError] uif

  {
    virtual SCHEMA_NAME: "StringView";
    stringData: 0 in @;
    stringSize: 1 in @ new;

    data: [stringData];
    size: [stringSize new];

    hash: [
      result: 33n32;
      size [
        codeunit: data storageAddress i Natx cast + Nat8 addressToReference Nat32 cast;
        result 47n32 * codeunit + !result
      ] times

      result
    ];

    iter: [(data size) toTextIter];

    slice: [
      index: size:;;
      (data storageAddress index Natx cast + Nat8 addressToReference const size new) toStringView
    ];
  }
];

StringView: [(Nat8 Cref 0) toStringView];

makeStringView: [StringView same] [
  new
] pfunc;

makeStringView: [Text same] [
  text:;
  (text storageAddress Nat8 addressToReference const text textSize Int32 cast) toStringView
] pfunc;

String: [{
  virtual SCHEMA_NAME: "String";
  chars: Nat8 Array;

  ASSIGN: [other:; @other.@chars @chars set];

  DIE: [];

  INIT: [];

  data: [@chars.@dataBegin];

  hash: [(data const size) toStringView .hash];

  iter: [data size makeArrayIter];

  size: [
    chars.getSize 0 = [
      0
    ] [
      chars.getSize 1 -
    ] if
  ];

  slice: [
    index: size:;;
    (data storageAddress index Natx cast + Nat8 addressToReference const size new) toStringView
  ];

  catAsciiSymbolCodeNZ: [
    codePoint:;
    [codePoint 128n32 <] "Is not ascii symbol code!" assert
    codePoint 0n8 cast @chars.append #end zero
  ];

  catCharNZ: [
    codepoint: .codepoint Nat32 cast;
    offset: chars.size;
    codepoint (
      [0x80n32 <] [
        offset 1 + @chars.enlarge
        codepoint 0n8 cast offset @chars.at set
      ]
      [0x800n32 <] [
        offset 2 + @chars.enlarge
        codepoint 6n32 rshift 0xC0n32 or 0n8 cast offset     @chars.at set
        codepoint 0x3Fn32 and 0x80n32 or 0n8 cast offset 1 + @chars.at set
      ]
      [0x10000n32 <] [
        offset 3 + @chars.enlarge
        codepoint 12n32 rshift             0xE0n32 or 0n8 cast offset     @chars.at set
        codepoint  6n32 rshift 0x3Fn32 and 0x80n32 or 0n8 cast offset 1 + @chars.at set
        codepoint              0x3Fn32 and 0x80n32 or 0n8 cast offset 2 + @chars.at set
      ] [
        offset 4 + @chars.enlarge
        codepoint 18n32 rshift             0xF0n32 or 0n8 cast offset     @chars.at set
        codepoint 12n32 rshift 0x3Fn32 and 0x80n32 or 0n8 cast offset 1 + @chars.at set
        codepoint  6n32 rshift 0x3Fn32 and 0x80n32 or 0n8 cast offset 2 + @chars.at set
        codepoint              0x3Fn32 and 0x80n32 or 0n8 cast offset 3 + @chars.at set
      ]
    ) cond
  ];

  catStringNZ: [
    string: makeStringView;
    string.size 0 = ~ [
      index: chars.getSize;
      index string.size + @chars.enlarge
      string.size Natx cast string.data storageAddress chars.getBufferBegin index Natx cast + memcpy drop
    ] when
  ];

  catIntNZ: [
    number: by3:;;
    number number number - < [
      "-" catStringNZ
      number Int64 cast neg Nat64 cast by3 catNatNZ
    ] [
      number Nat64 cast by3 catNatNZ
    ] if
  ];

  catNatNZ: [
    number: by3:;;
    nc: [number cast];

    shifted: number 0n64 cast;
    rounded: 1n64 dynamic;
    shift: 0 dynamic;

    shifted 10n64 < ~ [
      [
        shift 1 + !shift
        rounded 10n64 * @rounded set
        rounded shifted 10n64 / > ~
      ] loop
    ] when

    [
      digit: shifted rounded /;
      digit 0n32 cast 48n32 + catAsciiSymbolCodeNZ
      by3 [shift 0 >] && [shift 3 mod 0 =] && [44n32 catAsciiSymbolCodeNZ] when


      shifted digit rounded * - @shifted set
      rounded 10n64 / @rounded set

      shift 1 - !shift

      rounded 0n64 >
    ] loop
  ];

  catHexNZ: [
    number:;
    nc: [number cast];

    shifted: number 0n64 cast;
    rounded: 1n64 dynamic;

    shifted 16n64 < ~ [
      [
        rounded 16n64 * @rounded set
        rounded shifted 16n64 / > ~
      ] loop
    ] when

    [
      digit: shifted rounded /;

      digit 10n64 < [
        digit 0n32 cast 48n32 + catAsciiSymbolCodeNZ # '0'
      ] [
        digit 0n32 cast 55n32 + catAsciiSymbolCodeNZ # 'A'-10
      ] if

      shifted digit rounded * - @shifted set
      rounded 16n64 / @rounded set

      rounded 0n64 >
    ] loop
  ];

  catFloatNZ: [
    number: by3:; new;
    nc: [number cast];

    number 0 nc = [
      "0" catStringNZ
    ] [
      number number number + = [
        number 0 nc > [
          "inf" catStringNZ
        ] [
          "-inf" catStringNZ
        ] if
      ] [
        number number = ~ [
          "nan" catStringNZ
        ] [
          number 0 nc < [
            "-" catStringNZ
            number neg @number set
          ] when

          ten: 10 nc;
          nlog10: number log10 floor 0 cast;

          maxDigits: 6 dynamic;
          maxOrder: 8 dynamic;

          number 0.0r32 same [
            5 dynamic @maxDigits set
            7 dynamic @maxOrder set
          ] when

          digits: maxDigits new;
          shift: nlog10 new;

          nlog10 maxOrder > nlog10 maxOrder 2 / neg < or ~ [
            0 @shift set
            newDigits: maxOrder nlog10 -;
            newDigits digits < [
              newDigits @digits set
            ] when
          ] when

          rp: nlog10 shift -;
          rp 0 < [0 @rp set] when
          rounded: ten rp digits + intPow 0n32 cast;
          shifted: number ten digits shift - intPow * 0.5 nc + 0n32 cast;
          digitToCodePoint: [48n32 +];

          shifted rounded / 9n32 > [
            rounded 10n32 * @rounded set
            rp 1 + @rp set
          ] when

          rp 1 + @rp set

          [
            rp 0 = [
              46n32 catAsciiSymbolCodeNZ
            ] [
              by3 [rp 3 mod 0 =] && [
                44n32 catAsciiSymbolCodeNZ
              ] when
            ] if

            digit: shifted rounded /;
            digit digitToCodePoint catAsciiSymbolCodeNZ

            shifted digit rounded * - @shifted set
            rounded 10n32 / @rounded set
            rounded 0n32 = [1n32 @rounded set] when
            rp 1 - @rp set

            shifted 0n32 > [rp 0 < ~] ||
          ] loop

          shift 0 = ~ [
            101n32 catAsciiSymbolCodeNZ
            shift FALSE catIntNZ
          ] when
        ] if
      ] if
    ] if
  ];

  catBy3NZ: [
    arg:;
    @arg (
      [isInt ] [@arg TRUE catIntNZ  ]
      [isNat ] [@arg TRUE catNatNZ  ]
      [isReal] [@arg TRUE catFloatNZ]
      [
        @arg printStack
        "object is not supported for string concatenation" raiseStaticError
      ]
    ) cond
  ];

  catCondNZ: [
    [
      "TRUE" catStringNZ
    ] [
      "FALSE" catStringNZ
    ] if
  ];

  catNZ: [
    arg:;
    @arg (
      [Char same] [@arg catCharNZ]
      ["" same [@arg StringView same [@arg "SCHEMA_NAME" has [@arg.SCHEMA_NAME "String" =] &&] ||] ||] [@arg catStringNZ]
      [TRUE same] [@arg catCondNZ]
      [isInt ] [@arg FALSE catIntNZ  ]
      [isNat ] [@arg FALSE catNatNZ  ]
      [isReal] [@arg FALSE catFloatNZ]
      [
        @arg printStack
        "object is not supported for string concatenation" raiseStaticError
      ]
    ) cond
  ];

  catAsciiSymbolCode: [makeNZ catAsciiSymbolCodeNZ makeZ];
  catChar:            [makeNZ catCharNZ            makeZ];
  catString:          [makeNZ catStringNZ          makeZ];
  catInt:             [makeNZ catIntNZ             makeZ];
  catUint:            [makeNZ catUintNZ            makeZ];
  catHex:             [makeNZ catHexNZ             makeZ];
  catFloat:           [makeNZ catFloatNZ           makeZ];
  cat:                [makeNZ catNZ                makeZ];

  catMany: [
    list: toIndex;
    makeNZ
    i: 0;
    [i list.size <] [
      i 1 + list.size < [i 1 + list.at "HEX" has] && [
        i list.at catHexNZ
        i 1 + @i set
      ] [
        i 1 + list.size < [i 1 + list.at "BY3" has] && [
          i list.at catBy3NZ
          i 1 + @i set
        ] [
          i list.at catNZ
        ] if
      ] if
      i 1 + @i set
    ] while
    makeZ
  ];

  makeNZ: [
    chars.getSize 0 > [@chars.popBack] when #end zero
  ];

  makeZ: [
    chars.getSize 0 > [0n8 @chars.append] when #end zero
  ];

  resize: [
    size:;
    size @chars.resize
    makeZ
  ];

  # Deprecated
  virtual STRING: ();

  catSymbolCode: [
    Int32 cast toChar catChar
  ];

  getStringView: [
    chars.getSize 0 = [
      StringView
    ] [
      (chars.dataBegin chars.dataSize 1 -) toStringView
    ] if
  ];
}];

Utf8DecoderMode: {
  REPORT:  [0]; # Produce Int32 code points; stop as soon as an error is detected and return -1
  TRUST:   [1]; # Produce Chars; an ill-formed sequence is an undefined behavior
  REPLACE: [2]; # Produce Chars; replace each maximal subpart of an ill-formed sequence with the replacement character
};

decodeUtf8: [{
  mode: virtual new;
  source: toIter;

  next: [
    check: [
      predicate: action:;;
      mode Utf8DecoderMode.TRUST = [
        @predicate "ill-formed UTF-8 sequence" assert
        action
      ] [
        predicate @action [
          mode Utf8DecoderMode.REPORT = [-1] [REPLACEMENT_CHARACTER] if
        ] if
      ] if
    ];

    produce: [
      Int32 cast mode Utf8DecoderMode.REPORT = ~ [toChar] when
    ];

    unit0: valid: @source.next;; valid ~ [mode Utf8DecoderMode.REPORT = [-1] [REPLACEMENT_CHARACTER] if FALSE] [
      unit0 0x80n8 < [unit0 produce] [
        unit0 0xE0n8 < [
          [unit0 0xC2n8 < ~] [
            unit1: @source.next !valid;
            [valid [unit1 0xC0n8 and 0x80n8 =] &&] [
              unit0 0x1Fn8 and Nat32 cast 6n8 lshift
              unit1 0x3Fn8 and Nat32 cast or
              produce
            ] check
          ] check
        ] [
          unit0 0xF0n8 < [
            unit1: @source.next !valid;
            [
              valid [
                unit1 unit0 0xE0n8 = [0xE0n8 and 0xA0n8] [
                  unit0 0xEDn8 = [0xE0n8 and 0x80n8] [0xC0n8 and 0x80n8] if
                ] if =
              ] &&
            ] [
              unit2: @source.next !valid;
              [valid [unit2 0xC0n8 and 0x80n8 =] &&] [
                unit0 0x0Fn8 and Nat32 cast 12n8 lshift
                unit1 0x3Fn8 and Nat32 cast  6n8 lshift or
                unit2 0x3Fn8 and Nat32 cast             or
                produce
              ] check
            ] check
          ] [
            [unit0 0xF5n8 <] [
              unit1: @source.next !valid;
              [
                valid [
                  unit1 unit0 0xF0n8 = [0x90n8 0xC0n8 within] [
                    unit0 0xF4n8 = [0xF0n8] [0xC0n8] if and 0x80n8 =
                  ] if
                ] &&
              ] [
                unit2: @source.next !valid;
                [valid [unit2 0xC0n8 and 0x80n8 =] &&] [
                  unit3: @source.next !valid;
                  [valid [unit3 0xC0n8 and 0x80n8 =] &&] [
                    unit0 0x07n8 and Nat32 cast 18n8 lshift
                    unit1 0x3Fn8 and Nat32 cast 12n8 lshift or
                    unit2 0x3Fn8 and Nat32 cast  6n8 lshift or
                    unit3 0x3Fn8 and Nat32 cast             or
                    produce
                  ] check
                ] check
              ] check
            ] check
          ] if
        ] if
      ] if

      TRUE
    ] if
  ];
}];

By3: [{
  virtual BY3: ();
}];

Hex: [{
  virtual HEX: ();
}];

addLog: [
  hasLogs [
    printList LF print
  ] [
    list:;
  ] if
];

addTerminator: [
  source:;
  @source Text same [source "\00" &] [
    string: @source toString;
    "\00" @string.cat
    string
  ] if
];

assembleString: [
  list:;
  result: String;
  list @result.catMany
  @result
];

decode: [Text same                 ] [toIter dynamic Utf8DecoderMode.TRUST decodeUtf8] pfunc;
decode: ["TextIter"   hasSchemaName] [Utf8DecoderMode.TRUST decodeUtf8] pfunc;
decode: ["StringView" hasSchemaName] [Utf8DecoderMode.TRUST decodeUtf8] pfunc;
decode: ["String"     hasSchemaName] [Utf8DecoderMode.TRUST decodeUtf8] pfunc;

hash: ["" same] [makeStringView.hash] pfunc;

makeStringView: [object:; @object "SCHEMA_NAME" has [@object.SCHEMA_NAME "String" =] &&] [
  string:;
  (string.data string.size) toStringView
] pfunc;

makeStringViewByAddress: [
  address:;
  (address Nat8 addressToReference const address strlen Int32 cast) toStringView
];

print: ["" same ~] [toString print] pfunc;

print: [object:; @object "SCHEMA_NAME" has [@object.SCHEMA_NAME "String" =] &&] [
  string: addTerminator;
  (string.data) "%s\00" printf drop
] pfunc;

printList: [
  assembleString print
];

toString: [
  arg:;
  result: String;
  @arg @result.cat
  @result
];

# Deprecated
getCodePointAndSize: [
  data: size:;;
  count: 0;
  decoder: data size makeArrayIter @count countIter Utf8DecoderMode.REPLACE decodeUtf8;
  @decoder.next drop .codepoint Nat32 cast count
];

getCodePointSize: [
  data: size:;;
  count: 0;
  decoder: data size makeArrayIter @count countIter Utf8DecoderMode.REPLACE decodeUtf8;
  @decoder.next drop drop count
];

makeStringIter2: [{
  data: size: new;;
  codepointSize: data size getCodePointSize;

  valid: [codepointSize 0 = ~];
  get: [(data codepointSize new) toStringView];
  next: [
    data storageAddress codepointSize Natx cast + Nat8 addressToReference const !data
    size codepointSize - !size
    data size getCodePointSize !codepointSize
  ];
}];

splitString: [
  string: makeStringView;
  result: {
    success: TRUE;
    errorOffset: -1;
    chars: StringView Array;
  };

  data: string.data;
  size: string.size;
  [
    size 0 = [FALSE] [
      codepointSize: data size getCodePointSize;
      codepointSize 0 = [
        FALSE @result.!success
        data storageAddress string.data storageAddress - Int32 cast @result.!errorOffset
        FALSE
      ] [
        (data codepointSize new) toStringView @result.@chars.append
        data storageAddress codepointSize Natx cast + Nat8 addressToReference const !data
        size codepointSize - !size
        TRUE
      ] if
    ] if
  ] loop

  @result
];
