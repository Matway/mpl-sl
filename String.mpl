"String" module
"Array" includeModule

{arg: 0nx;} 0nx {convention: cdecl;} "strlen" importFunction

getCodePointAndSize: [
  copy endSize:;
  copy buffer:;

  endSize 0 > not [
    0n32 0
  ] [
    cu0: buffer Nat8 addressToReference copy;
    cu0 0x80n8 < cu0 0xc0n8 < not cu0 0xf8n8 < and or not [
      0n32 0
    ] [
      cu0 0x80n8 < [
        cu0 0n32 cast
        1
      ] [
        endSize 1 > not [
          0n32 0
        ] [
          cu1: buffer 1nx + Nat8 addressToReference copy;
          cu1 0xc0n8 and 0x80n8 = not [
            0n32 0
          ] [
            cu0 0xe0n8 < [
              cu0 0n32 cast 0x1fn32 and 6n32 lshift
              cu1 0n32 cast 0x3fn32 and or
              2
            ] [
              endSize 2 > not [
                0n32 0
              ] [
                cu2: buffer 2nx + Nat8 addressToReference copy;
                cu2 0xc0n8 and 0x80n8 = not [
                  0n32 0
                ] [
                  cu0 0xf0n8 < [
                    cu0 0n32 cast 0x0fn32 and 12n32 lshift
                    cu1 0n32 cast 0x3fn32 and  6n32 lshift or
                    cu2 0n32 cast 0x3fn32 and or
                    3
                  ] [
                    endSize 3 > not [
                      0n32 0
                    ] [
                      cu3: buffer 3nx + Nat8 addressToReference copy;
                      cu3 0xc0n8 and 0x80n8 = not [
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
] func;

getCodePointSize: [
  copy endSize:;
  copy buffer:;

  endSize 0 > not [0] [
    cu0: buffer Nat8 addressToReference copy;
    cu0 0x80n8 < cu0 0xc0n8 < not cu0 0xf8n8 < and or not [0] [
      cu0 0x80n8 < [
        1
      ] [
        endSize 1 > not [0] [
          cu1: buffer 1nx + Nat8 addressToReference copy;
          cu1 0xc0n8 and 0x80n8 = not [0] [
            cu0 0xe0n8 < [
              2
            ] [
              endSize 2 > not [0] [
                cu2: buffer 2nx + Nat8 addressToReference copy;
                cu2 0xc0n8 and 0x80n8 = not [0] [
                  cu0 0xf0n8 < [
                    3
                  ] [
                    endSize 3 > not [0] [
                      cu3: buffer 3nx + Nat8 addressToReference copy;
                      cu3 0xc0n8 and 0x80n8 = not [0] [
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
] func;

previousCodePointSize: [
  copy begSize:;
  copy buffer:;

  begSize 0 > not [0] [
    cu0: buffer 1nx - Nat8 addressToReference copy;
    cu0 0xc0n8 and 0x80n8 = not [
      cu0 0x80n8 < [1][0] if
    ] [
      begSize 1 > not [0] [
        cu1: buffer 2nx - Nat8 addressToReference copy;
        cu1 0xc0n8 and 0x80n8 = not [
          cu0 0xe0n8 and 0xc0n8 = [2][0] if
        ] [
          begSize 2 > not [0] [
            cu2: buffer 3nx - Nat8 addressToReference copy;
            cu2 0xc0n8 and 0x80n8 = not [
              cu0 0xf0n8 and 0xe0n8 = [3][0] if
            ] [
              begSize 3 > not [0] [
                cu3: buffer 4nx - Nat8 addressToReference copy;
                cu3 0xf8n8 and 0xf0n8 = cu3 0n32 cast 0x07n32 and 0x6n32 lshift cu0 0n32 cast 0x3fn32 and or 0x110n32 < and [4][0] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
] func;

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
] func;

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

      up 0 = not
    ] loop
    acc
  ] if
] func;

makeStringViewRaw: [{
  virtual STRING_VIEW: ();
  dataBegin: storageAddress Nat8 addressToReference; #dynamize
  dataSize: copy dynamic;

  getTextSize: [
    dataSize copy
  ] func;

  split: [
    result: {
      success: TRUE dynamic;
      errorOffset: -1 dynamic;
      chars: StringView Array;
    };

    buffer: dataBegin storageAddress;
    endSize: dataSize copy;
    [endSize 0 > [result.success copy] &&] [
      nextSize: buffer endSize getCodePointSize;
      nextSize 0 = [
        buffer dataBegin storageAddress - Int32 cast @result.@errorOffset set
        FALSE @result.@success set
      ] [
        nextSize buffer Nat8 addressToReference makeStringViewRaw @result.@chars.pushBack
        buffer nextSize Natx cast + @buffer set
        endSize nextSize - @endSize set
      ] if
    ] while
    @result
  ] func;
}] func;

StringView: [0 Nat8 Ref makeStringViewRaw] func;

String: [{
  virtual STRING: ();
  chars: Nat8 Array;

  getTextSize: [
    chars.getSize 0 = [
      0
    ] [
      chars.getSize 1 -
    ] if
  ] func;

  getStringMemory: [chars.getBufferBegin] func;

  getStringView: [
    chars.getSize 0 = [
      StringView
    ] [
      chars.getSize 1 - 0 chars.at storageAddress Nat8 addressToReference makeStringViewRaw
    ] if
  ] func;

  makeNZ: [
    chars.getSize 0 > [@chars.popBack] when #end zero
  ] func;

  makeZ: [
    0n8 @chars.pushBack #end zero
  ] func;

  catAsciiSymbolCodeNZ: [
    copy codePoint:;
    [codePoint 128n32 <] "Is not ascii symbol code!" assert
    codePoint 0n8 cast @chars.pushBack #end zero
  ] func;

  catSymbolCodeNZ: [
    copy codePoint:;
    buf: (0n8 0n8 0n8 0n8);
    length: @buf storageAddress codePoint fromCodePoint;

    i: 0 dynamic;
    [i length <] [
      i buf @ @chars.pushBack
      i 1 + @i set
    ] while
  ] func;

  catStringNZ: [
    stringView: makeStringView;

    stringView.dataSize 0 > [
      i: 0 dynamic;
      [
        i stringView.dataSize < [
          char: stringView.dataBegin storageAddress i Natx cast + Nat8 addressToReference;
          char @chars.pushBack
          i 1 + @i set TRUE
        ] &&
      ] loop

    ] when
  ] func;

  catIntNZ: [
    copy number:;
    number number number - < [
      "-" catStringNZ
      number Int64 cast neg Nat64 cast catUintNZ
    ] [
      number Nat64 cast catUintNZ
    ] if
  ] func;

  catUintNZ: [
    copy number:;
    nc: [number cast] func;

    shifted: number 0n64 cast;
    rounded: 1n64 dynamic;

    shifted 10n64 < not [
      [
        rounded 10n64 * @rounded set
        rounded shifted 10n64 / > not
      ] loop
    ] when

    [
      digit: shifted rounded /;
      digit 0n32 cast 48n32 + catAsciiSymbolCodeNZ

      shifted digit rounded * - @shifted set
      rounded 10n64 / @rounded set

      rounded 0n64 >
    ] loop
  ] func;

  catHexNZ: [
    copy number:;
    nc: [number cast] func;

    shifted: number 0n64 cast;
    rounded: 1n64 dynamic;

    shifted 16n64 < not [
      [
        rounded 16n64 * @rounded set
        rounded 16n64 * shifted > not
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
  ] func;

  catFloatNZ: [
    copy number:;

    nc: [number cast] func;

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
        number number = not [
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

          nlog10 maxOrder > nlog10 maxOrder 2 / neg < or not [
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
          digitToCodePoint: [48n32 +] func;

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

            shifted 0n32 > [rp 0 < not] ||
          ] loop

          shift 0 = not [
            "e" catStringNZ
            shift catIntNZ
          ] when
        ] if
      ] if
    ] if
  ] func;

  catCondNZ: [
    [
      "TRUE" catStringNZ
    ] [
      "FALSE" catStringNZ
    ] if
  ] func;

  catNZ: [
    arg:;
    @arg "" same [@arg "STRING_VIEW" has] || [@arg "STRING" has] || [
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
              @arg
              0 .CANNOT_CAT_THIS_TYPE
            ] if
          ] if
        ] if
      ] if
    ] if
  ] func;

  catAsciiSymbolCode: [makeNZ catAsciiSymbolCodeNZ makeZ] func;
  catSymbolCode:      [makeNZ catSymbolCodeNZ      makeZ] func;
  catString:          [makeNZ catStringNZ          makeZ] func;
  catInt:             [makeNZ catIntNZ             makeZ] func;
  catUint:            [makeNZ catUintNZ            makeZ] func;
  catHex:             [makeNZ catHexNZ             makeZ] func;
  catFloat:           [makeNZ catFloatNZ           makeZ] func;
  cat:                [makeNZ catNZ                makeZ] func;

  catMany: [
    list:;
    makeNZ
    i: 0;
    [i list fieldCount <] [
      i 1 + list fieldCount < [i 1 + list @ "HEX" has] && [
        i list @ catHexNZ
        i 1 + @i set
      ] [
        i list @ catNZ
      ] if
      i 1 + @i set
    ] while
    makeZ
  ] func;
}] func;

Hex: [{
  virtual HEX: ();
}] func;

textSize: ["STRING_VIEW" has] [.getTextSize Natx cast] pfunc;
textSize: ["STRING" has] [.getTextSize Natx cast] pfunc;

makeStringView: [0 .CANNOT_MAKE_STRING_VIEW] func;

makeStringView: ["" same] [
  copy arg:;
  arg textSize Int32 cast dynamic arg storageAddress Nat8 addressToReference makeStringViewRaw
] pfunc;

makeStringView: ["STRING_VIEW" has] [
  copy
] pfunc;

makeStringView: ["STRING" has] [
  .getStringView
] pfunc;

makeStringViewByAddress: [
  copy arg:;
  arg strlen Int32 cast arg Nat8 addressToReference makeStringViewRaw
] func;

stringMemory: [0 .CANNOT_GET_STRING_MEMORY] func;
stringMemory: ["" same] [storageAddress] pfunc;
stringMemory: ["STRING_VIEW" has] [.dataBegin storageAddress] pfunc;
stringMemory: ["STRING" has] [.getStringMemory] pfunc;

toString: [
  arg:;
  result: String;
  @arg @result.cat
  @result
] func;

codepointToString: [
  arg:;
  result: String;
  arg @result.catSymbolCode
  @result
] func;

assembleString: [
  list:;
  result: String;
  list @result.catMany
  @result
] func;

stringness: [
  arg:;
  arg "" same [1][arg "STRING_VIEW" has [2][arg "STRING" has [2][0] if ] if] if
] func;

=: [
  p1: stringness;
  p2: stringness;
  p1 p2 + 2 >
] [
  arg1: makeStringView;
  arg2: makeStringView;
  arg1.dataSize arg2.dataSize = [
    result: TRUE dynamic;
    i: 0 dynamic;
    [i arg1.dataSize < [result copy] &&] [
      addr1: arg1.dataBegin storageAddress i Natx cast + Nat8 addressToReference;
      addr2: arg2.dataBegin storageAddress i Natx cast + Nat8 addressToReference;
      addr1 addr2 = @result set
      i 1 + @i set
    ] while
    result copy
  ] &&
] pfunc;

print: [
  toString stringMemory printAddr
] func;

print: ["" same] [
  stringMemory printAddr
] pfunc;

print: ["STRING" has] [
  stringMemory printAddr
] pfunc;

addLog: [
  HAS_LOGS [
    printList LF print
  ] [
    list:;
  ] if
] func;

printList: [
  assembleString print
] func;

hash: [makeStringView TRUE] [
  stringView: makeStringView;
  result: 33n32;

  i: 0;
  [i stringView.dataSize <] [
    curByte: stringView.dataBegin storageAddress i Natx cast + Nat8 addressToReference r:; @r Nat32 cast;
    result 47n32 * curByte + @result set
    i 1 + @i set
  ] while

  result
] pfunc;
