"Array.Array" use
"control.&&" use
"control.Int32" use
"control.Int64" use
"control.Nat32" use
"control.Nat64" use
"control.Nat8" use
"control.Natx" use
"control.Text" use
"control.asView" use
"control.assert" use
"control.drop" use
"control.dup" use
"control.pfunc" use
"control.printf" use
"control.times" use
"control.when" use
"control.while" use
"control.||" use
"conventions.cdecl" use
"memory.memcmp" use
"memory.memcpy" use

{arg: 0nx;} 0nx {convention: cdecl;} "strlen" importFunction

getCodePointAndSize: [
  copy endSize:;
  copy buffer:;

  endSize 0 > ~ [
    0n32 0
  ] [
    cu0: buffer Nat8 addressToReference copy;
    cu0 0x80n8 < cu0 0xc0n8 < ~ cu0 0xf8n8 < and or ~ [
      0n32 0
    ] [
      cu0 0x80n8 < [
        cu0 0n32 cast
        1
      ] [
        endSize 1 > ~ [
          0n32 0
        ] [
          cu1: buffer 1nx + Nat8 addressToReference copy;
          cu1 0xc0n8 and 0x80n8 = ~ [
            0n32 0
          ] [
            cu0 0xe0n8 < [
              cu0 0n32 cast 0x1fn32 and 6n32 lshift
              cu1 0n32 cast 0x3fn32 and or
              2
            ] [
              endSize 2 > ~ [
                0n32 0
              ] [
                cu2: buffer 2nx + Nat8 addressToReference copy;
                cu2 0xc0n8 and 0x80n8 = ~ [
                  0n32 0
                ] [
                  cu0 0xf0n8 < [
                    cu0 0n32 cast 0x0fn32 and 12n32 lshift
                    cu1 0n32 cast 0x3fn32 and  6n32 lshift or
                    cu2 0n32 cast 0x3fn32 and or
                    3
                  ] [
                    endSize 3 > ~ [
                      0n32 0
                    ] [
                      cu3: buffer 3nx + Nat8 addressToReference copy;
                      cu3 0xc0n8 and 0x80n8 = ~ [
                        0n32 0
                      ] [
                        cu0 0n32 cast 0x07n32 and 18n32 lshift
                        cu1 0n32 cast 0x3fn32 and 12n32 lshift or
                        cu2 0n32 cast 0x3fn32 and  6n32 lshift or
                        cu3 0n32 cast 0x3fn32 and or
                        4
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
];

getCodePointSize: [
  copy endSize:;
  copy buffer:;

  endSize 0 > ~ [0] [
    cu0: buffer Nat8 addressToReference copy;
    cu0 0x80n8 < cu0 0xc0n8 < ~ cu0 0xf8n8 < and or ~ [0] [
      cu0 0x80n8 < [
        1
      ] [
        endSize 1 > ~ [0] [
          cu1: buffer 1nx + Nat8 addressToReference copy;
          cu1 0xc0n8 and 0x80n8 = ~ [0] [
            cu0 0xe0n8 < [
              2
            ] [
              endSize 2 > ~ [0] [
                cu2: buffer 2nx + Nat8 addressToReference copy;
                cu2 0xc0n8 and 0x80n8 = ~ [0] [
                  cu0 0xf0n8 < [
                    3
                  ] [
                    endSize 3 > ~ [0] [
                      cu3: buffer 3nx + Nat8 addressToReference copy;
                      cu3 0xc0n8 and 0x80n8 = ~ [0] [
                        4
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
];

previousCodePointSize: [
  copy begSize:;
  copy buffer:;

  begSize 0 > ~ [0] [
    cu0: buffer 1nx - Nat8 addressToReference copy;
    cu0 0xc0n8 and 0x80n8 = ~ [
      cu0 0x80n8 < [1][0] if
    ] [
      begSize 1 > ~ [0] [
        cu1: buffer 2nx - Nat8 addressToReference copy;
        cu1 0xc0n8 and 0x80n8 = ~ [
          cu0 0xe0n8 and 0xc0n8 = [2][0] if
        ] [
          begSize 2 > ~ [0] [
            cu2: buffer 3nx - Nat8 addressToReference copy;
            cu2 0xc0n8 and 0x80n8 = ~ [
              cu0 0xf0n8 and 0xe0n8 = [3][0] if
            ] [
              begSize 3 > ~ [0] [
                cu3: buffer 4nx - Nat8 addressToReference copy;
                cu3 0xf8n8 and 0xf0n8 = cu3 0n32 cast 0x07n32 and 0x6n32 lshift cu0 0n32 cast 0x3fn32 and or 0x110n32 < and [4][0] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
];

fromCodePoint: [
  copy codePoint:;
  copy bufferAddr:;
  buffer: bufferAddr (0n8 0n8 0n8 0n8) addressToReference;
  codePoint 0x110000n32 < [
    codePoint 0x80n32 < [
      codePoint 0n8 cast 0 @buffer @ set
      1
    ] [
      codePoint 0x800n32 < [
        codePoint 6n32 rshift             0xc0n32 or 0n8 cast 0 @buffer @ set
        codePoint             0x3fn32 and 0x80n32 or 0n8 cast 1 @buffer @ set
        2
      ] [
        codePoint 0x10000n32 < [
          codePoint 12n32 rshift             0xe0n32 or 0n8 cast 0 @buffer @ set
          codePoint  6n32 rshift 0x3fn32 and 0x80n32 or 0n8 cast 1 @buffer @ set
          codePoint              0x3fn32 and 0x80n32 or 0n8 cast 2 @buffer @ set
          3
        ] [
          codePoint 18n32 rshift             0xf0n32 or 0n8 cast 0 @buffer @ set
          codePoint 12n32 rshift 0x3fn32 and 0x80n32 or 0n8 cast 1 @buffer @ set
          codePoint  6n32 rshift 0x3fn32 and 0x80n32 or 0n8 cast 2 @buffer @ set
          codePoint              0x3fn32 and 0x80n32 or 0n8 cast 3 @buffer @ set
          4
        ] if
      ] if
    ] if
  ] [
    0
  ] if
];

intPow: [
  copy up:;
  copy down:;
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

makeStringIter2: [{
  data: size: copy; copy;
  codepointSize: data size getCodePointSize;

  valid: [codepointSize 0 = ~];
  get: [data codepointSize makeStringView2];
  next: [
    data codepointSize Natx cast + !data
    size codepointSize - !size
    data size getCodePointSize !codepointSize
  ];
}];

StringIter: [0nx 0 makeStringIter2];

makeStringIter: [StringIter same] [
  copy
] pfunc;

makeStringIter: [Text same] [
  text:;
  text storageAddress text textSize Int32 cast makeStringIter2
] pfunc;

toIter: ["" same] [
  text:;
  text storageAddress text textSize Int32 cast makeStringIter2
] pfunc;

makeStringView2: [{
  data: size: copy; copy;

  equal: [
    other: dup "" same [asView] when;
    size other.size = [size Natx cast other.data data memcmp 0 =] &&
  ];

  hash: [
    result: 33n32;
    size [
      codeunit: data i Natx cast + Nat8 addressToReference Nat32 cast;
      result 47n32 * codeunit + !result
    ] times

    result
  ];

  iter: [data size makeStringIter2];

  view: [
    index: size:;;
    data index Natx cast + size makeStringView2
  ];
}];

StringView: [0nx 0 makeStringView2];

makeStringView: [StringView same] [
  copy
] pfunc;

makeStringView: [Text same] [
  text:;
  text storageAddress text textSize Int32 cast makeStringView2
] pfunc;

asView: ["" same] [
  text:;
  text storageAddress text textSize Int32 cast makeStringView2
] pfunc;

splitString: [
  string: makeStringView;
  result: {
    success: TRUE;
    errorOffset: -1;
    chars: StringView Array;
  };

  data: string.data copy;
  size: string.size copy;
  [
    size 0 = [FALSE] [
      codepointSize: data size getCodePointSize;
      codepointSize 0 = [
        FALSE @result.!success
        data string.data - Int32 cast @result.!errorOffset
        FALSE
      ] [
        data codepointSize makeStringView2 @result.@chars.pushBack
        data codepointSize Natx cast + !data
        size codepointSize - !size
        TRUE
      ] if
    ] if
  ] loop

  @result
];

String: [{
  virtual STRING: ();
  chars: Nat8 Array;

  data: [chars.getBufferBegin];

  size: [
    chars.getSize 0 = [
      0
    ] [
      chars.getSize 1 -
    ] if
  ];

  equal: [
    other: makeStringView;
    self other.equal
  ];

  hash: [getStringView.hash];

  iter: [data size makeStringIter2];

  view: [
    index: size:;;
    data index Natx cast + size makeStringView2
  ];

  getStringView: [
    chars.getSize 0 = [
      StringView
    ] [
      chars.getBufferBegin chars.dataSize 1 - makeStringView2
    ] if
  ];

  makeNZ: [
    chars.getSize 0 > [@chars.popBack] when #end zero
  ];

  makeZ: [
    chars.getSize 0 > [0n8 @chars.pushBack] when #end zero
  ];

  catAsciiSymbolCodeNZ: [
    copy codePoint:;
    [codePoint 128n32 <] "Is not ascii symbol code!" assert
    codePoint 0n8 cast @chars.pushBack #end zero
  ];

  catSymbolCodeNZ: [
    copy codePoint:;
    buf: (0n8 0n8 0n8 0n8);
    length: @buf storageAddress codePoint fromCodePoint;

    i: 0 dynamic;
    [i length <] [
      i buf @ @chars.pushBack
      i 1 + @i set
    ] while
  ];

  catStringNZ: [
    string: makeStringView;
    string.size 0 = ~ [
      index: chars.getSize;
      index string.size + @chars.enlarge
      string.size Natx cast string.data chars.getBufferBegin index Natx cast + memcpy drop
    ] when
  ];

  catIntNZ: [
    copy number:;
    number number number - < [
      "-" catStringNZ
      number Int64 cast neg Nat64 cast catUintNZ
    ] [
      number Nat64 cast catUintNZ
    ] if
  ];

  catUintNZ: [
    copy number:;
    nc: [number cast];

    shifted: number 0n64 cast;
    rounded: 1n64 dynamic;

    shifted 10n64 < ~ [
      [
        rounded 10n64 * @rounded set
        rounded shifted 10n64 / > ~
      ] loop
    ] when

    [
      digit: shifted rounded /;
      digit 0n32 cast 48n32 + catAsciiSymbolCodeNZ

      shifted digit rounded * - @shifted set
      rounded 10n64 / @rounded set

      rounded 0n64 >
    ] loop
  ];

  catHexNZ: [
    copy number:;
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
        digit 0n32 cast 48n32 + catAsciiSymbolCodeNZ  # '0'
      ] [
        digit 0n32 cast 55n32 + catAsciiSymbolCodeNZ  # 'A'-10
      ] if

      shifted digit rounded * - @shifted set
      rounded 16n64 / @rounded set

      rounded 0n64 >
    ] loop
  ];

  catFloatNZ: [
    copy number:;

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

          digits: maxDigits copy;
          shift: nlog10 copy;

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
              "." catStringNZ
            ] when


            digit: shifted rounded /;
            digit digitToCodePoint catAsciiSymbolCodeNZ

            shifted digit rounded * - @shifted set
            rounded 10n32 / @rounded set
            rounded 0n32 = [1n32 @rounded set] when
            rp 1 - @rp set

            shifted 0n32 > [rp 0 < ~] ||
          ] loop

          shift 0 = ~ [
            "e" catStringNZ
            shift catIntNZ
          ] when
        ] if
      ] if
    ] if
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
    @arg "" same [@arg StringView same] || [@arg "STRING" has] || [
      @arg catStringNZ
    ] [
      @arg 0.0r64 same [@arg 0.0r32 same] || [
        @arg catFloatNZ
      ] [
        @arg 0i8 same [@arg 0i16 same] || [@arg 0i32 same] || [@arg 0i64 same] || [@arg 0ix same] || [
          @arg catIntNZ
        ] [
          @arg 0n8 same [@arg 0n16 same] || [@arg 0n32 same] || [@arg 0n64 same] || [@arg 0nx same] || [
            @arg catUintNZ
          ] [
            @arg TRUE same [
              @arg catCondNZ
            ] [
              @arg printStack
              0 .CANNOT_CAT_THIS_TYPE
            ] if
          ] if
        ] if
      ] if
    ] if
  ];

  catAsciiSymbolCode: [makeNZ catAsciiSymbolCodeNZ makeZ];
  catSymbolCode:      [makeNZ catSymbolCodeNZ      makeZ];
  catString:          [makeNZ catStringNZ          makeZ];
  catInt:             [makeNZ catIntNZ             makeZ];
  catUint:            [makeNZ catUintNZ            makeZ];
  catHex:             [makeNZ catHexNZ             makeZ];
  catFloat:           [makeNZ catFloatNZ           makeZ];
  cat:                [makeNZ catNZ                makeZ];

  catMany: [
    list: asView;
    makeNZ
    i: 0;
    [i list.size <] [
      i 1 + list.size < [i 1 + list.at "HEX" has] && [
        i list.at catHexNZ
        i 1 + @i set
      ] [
        i list.at catNZ
      ] if
      i 1 + @i set
    ] while
    makeZ
  ];
}];

Hex: [{
  virtual HEX: ();
}];

makeStringView: ["STRING" has] [
  .getStringView
] pfunc;

makeStringViewByAddress: [
  address:;
  address address strlen Int32 cast makeStringView2
];

toString: [
  arg:;
  result: String;
  @arg @result.cat
  @result
];

codepointToString: [
  arg:;
  result: String;
  arg @result.catSymbolCode
  @result
];

assembleString: [
  list:;
  result: String;
  list @result.catMany
  @result
];

print: ["" same ~] [toString print] pfunc;

print: ["STRING" has] [
  string:;
  (string.data) "%s\00" printf
] pfunc;

addLog: [
  HAS_LOGS [
    printList LF print
  ] [
    list:;
  ] if
];

printList: [
  assembleString print
];

hash: ["" same] [makeStringView.hash] pfunc;
