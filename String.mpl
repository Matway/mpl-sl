"Array.Array"             use
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
"control.cond"            use
"control.drop"            use
"control.dup"             use
"control.hasSchemaName"   use
"control.isInt"           use
"control.isNat"           use
"control.isReal"          use
"control.new"             use
"control.pfunc"           use
"control.printf"          use
"control.set"             use
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

  equal:   [.codepoint codepoint =];
  greater: [.codepoint codepoint >];
  less:    [.codepoint codepoint <];
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

hash: [Char same] [.codepoint hash] pfunc;

encodeIter: [Char same] [
  codepoint: .codepoint Nat32 cast;
  {
    data: codepoint (
      [   0x80n32 <] [0xFFFFFF00n32                                                                                                                   codepoint             or]
      [  0x800n32 <] [0xFFFF80C0n32 codepoint 0x3Fn32 and  8n8 lshift or                                                                              codepoint  6n8 rshift or]
      [0x10000n32 <] [0xFF8080E0n32 codepoint 0x3Fn32 and 16n8 lshift or codepoint 0xFC0n32 and  2n8 lshift or                                        codepoint 12n8 rshift or]
      [               0x808080F0n32 codepoint 0x3Fn32 and 24n8 lshift or codepoint 0xFC0n32 and 10n8 lshift or codepoint 0x3F000n32 and 4n8 rshift or codepoint 18n8 rshift or]
    ) cond;

    get: [data Nat8 cast];
    next: [0xFF000000n32 data 8n8 rshift or !data];
    valid: [data 0xFFFFFFFFn32 = ~];
  }
] pfunc;

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

    equal: [
      other: dup Text same [makeStringView] when;
      size other.size = [size Natx cast other.data storageAddress data storageAddress memcmp 0 =] &&
    ];

    hash: [
      result: 33n32;
      size [
        codeunit: data storageAddress i Natx cast + Nat8 addressToReference Nat32 cast;
        result 47n32 * codeunit + !result
      ] times

      result
    ];

    slice: [
      index: size:;;
      (data storageAddress index Natx cast + Nat8 addressToReference const size new) toStringView
    ];

    # Deprecated
    iter: [data size makeStringIter2];
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

  equal: [
    other: makeStringView;
    self other.equal
  ];

  hash: [(data const size new) toStringView .hash];

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
    codePoint 0n8 cast @chars.pushBack #end zero
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
    () (
      [@arg isInt ] [@arg TRUE catIntNZ  ]
      [@arg isNat ] [@arg TRUE catNatNZ  ]
      [@arg isReal] [@arg TRUE catFloatNZ]
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
    chars.getSize 0 > [0n8 @chars.pushBack] when #end zero
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

  iter: [data size makeArrayIter];
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

assembleString: [
  list:;
  result: String;
  list @result.catMany
  @result
];

decode: [Text same                 ] [text:; (text storageAddress Nat8 addressToReference text textSize Int32 cast) toTextIter decodeChars] pfunc;
decode: ["TextIter"   hasSchemaName] [                                                                                         decodeChars] pfunc;
decode: ["StringView" hasSchemaName] [view:;   (view.data view.size) toTextIter                                                decodeChars] pfunc;
decode: ["String"     hasSchemaName] [string:; (string.data string.size) toTextIter                                            decodeChars] pfunc;

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
  string:;
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
decodeChars: [{
  source: toIter;
  codepoint: 0;

  get: [
    [valid] "decoder is not valid" assert
    codepoint toChar
  ];

  next: [
    [valid] "decoder is not valid" assert
    return3: [
      @source.next source.valid ~ [-1] [
        unit2: source.get new; unit2 0xC0n8 and 0x80n8 = ~ [-1] [
          @source.next
          unit0 0n32 cast 0x0Fn32 and 12n32 lshift
          unit1 0n32 cast 0x3Fn32 and  6n32 lshift or
          unit2 0n32 cast 0x3Fn32 and or
          Int32 cast
        ] if
      ] if
    ];

    return4: [
      @source.next source.valid ~ [-1] [
        unit2: source.get new; unit2 0xC0n8 and 0x80n8 = ~ [-1] [
          @source.next source.valid ~ [-1] [
            unit3: source.get new; unit3 0xC0n8 and 0x80n8 = ~ [-1] [
              @source.next
              unit0 0n32 cast 0x07n32 and 18n32 lshift
              unit1 0n32 cast 0x3Fn32 and 12n32 lshift or
              unit2 0n32 cast 0x3Fn32 and  6n32 lshift or
              unit3 0n32 cast 0x3Fn32 and or
              Int32 cast
            ] if
          ] if
        ] if
      ] if
    ];

    source.valid ~ [-1] [
      unit0: source.get new;
      unit0 (
        [0x80n8 <] [@source.next unit0 Int32 cast]
        [0xC2n8 <] [-1]
        [0xF5n8 <] [
          @source.next source.valid ~ [-1] [
            unit1: source.get new;
            unit0 (
              [0xE0n8 <] [
                unit1 0xC0n8 and 0x80n8 = ~ [-1] [
                  @source.next
                  unit0 0n32 cast 0x1Fn32 and 6n32 lshift
                  unit1 0n32 cast 0x3Fn32 and or
                  Int32 cast
                ] if
              ]
              [0xE0n8 =] [unit1 0xE0n8 and 0xA0n8 =  [return3] [-1] if]
              [0xEDn8 <] [unit1 0xC0n8 and 0x80n8 =  [return3] [-1] if]
              [0xEDn8 =] [unit1 0xE0n8 and 0x80n8 =  [return3] [-1] if]
              [0xF0n8 <] [unit1 0xC0n8 and 0x80n8 =  [return3] [-1] if]
              [0xF0n8 =] [unit1 0x90n8 0xC0n8 within [return4] [-1] if]
              [0xF4n8 <] [unit1 0xC0n8 and 0x80n8 =  [return4] [-1] if]
              [           unit1 0xF0n8 and 0x80n8 =  [return4] [-1] if]
            ) cond
          ] if
        ]
        [-1]
      ) cond
    ] if !codepoint
  ];

  valid: [codepoint -1 = ~];

  next
}];

getCodePointAndSize: [
  data: size:;;
  iter: {iter: data size makeArrayIter; count: 0; DIE: []; get: [iter.get]; next: [@iter.next count 1 + !count]; valid: [iter.valid];};
  decoder: @iter decodeChars;
  decoder.valid [
    decoder.get .codepoint Nat32 cast iter.count new
  ] [
    0n32 0
  ] if
];

getCodePointSize: [
  data: size:;;
  iter: {iter: data size makeArrayIter; count: 0; DIE: []; get: [iter.get]; next: [@iter.next count 1 + !count]; valid: [iter.valid];};
  decoder: @iter decodeChars;
  decoder.valid [iter.count new] [0] if
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
        (data codepointSize new) toStringView @result.@chars.pushBack
        data storageAddress codepointSize Natx cast + Nat8 addressToReference const !data
        size codepointSize - !size
        TRUE
      ] if
    ] if
  ] loop

  @result
];
