"Array.Array" use
"HashTable.HashTable" use
"String.String" use
"String.StringView" use
"String.getCodePointAndSize" use
"String.splitString" use
"Variant.Variant" use
"ascii.ascii" use
"control.&&" use
"control.=" use
"control.Cond" use
"control.Cref" use
"control.Int32" use
"control.Int64" use
"control.Nat32" use
"control.Nat8" use
"control.Real64" use
"control.Ref" use
"control.assert" use
"control.each" use
"control.times" use
"control.when" use
"control.||" use
"conventions.cdecl" use

JSONNull:   [0 static];
JSONInt:    [1 static];
JSONReal:   [2 static];
JSONCond:   [3 static];
JSONString: [4 static];
JSONArray:  [5 static];
JSONObject: [6 static];

JSON: [{
  mem0: 0n64 dynamic;
  mem1: 0n64 dynamic;
  mem2: 0nx dynamic;
  mem3: 0nx dynamic;

  impl: [
    @self storageAddress addrAsJSONImpl
  ];

  getTag:    [impl.@data.getTag];
  setTag:    [impl.@data.setTag];

  getInt:    [JSONInt    impl.@data.get];
  getReal:   [JSONReal   impl.@data.get];
  getCond:   [JSONCond   impl.@data.get];
  getString: [JSONString impl.@data.get];
  getArray:  [JSONArray  impl.@data.get];
  getObject: [JSONObject impl.@data.get];

  INIT:   [               @closure storageAddress JSONInit];
  ASSIGN: [storageAddress @closure storageAddress JSONSet];
  DIE:    [               @closure storageAddress JSONDestroy];
}];

addrAsJSONImpl: [@JSONImplRef addressToReference];

{dst: 0nx;          } () {convention: cdecl;} "JSONDestroy" importFunction
{dst: 0nx; src: 0nx;} () {convention: cdecl;} "JSONSet"     importFunction
{dst: 0nx;          } () {convention: cdecl;} "JSONInit"    importFunction

JSONImplArray: [JSON Array];
JSONImplObject: [String JSON HashTable];

JSONImpl: [
  {
    data: (
      Cond
      Int64
      Real64
      Cond
      String
      JSONImplArray
      JSONImplObject
    ) Variant;
  } result:;

  result storageSize JSON storageSize = ~ [0 .STORAGE_SIZE_FAIL] when
  result alignment   JSON alignment   = ~ [0 .ALIGNMENT_FAIL] when
  @result
];

schema JSONImplRef: JSONImpl;

{dst: 0nx;          } () {convention: cdecl;} [
  addrAsJSONImpl manuallyInitVariable
] "JSONInit" exportFunction

{dst: 0nx; src: 0nx;} () {convention: cdecl;} [
  dst: addrAsJSONImpl;
  src: addrAsJSONImpl;
  src @dst set
] "JSONSet" exportFunction

{dst: 0nx;          } () {convention: cdecl;} [
  addrAsJSONImpl manuallyDestroyVariable
] "JSONDestroy" exportFunction

intAsJSON: [
  result: JSON;
  JSONInt @result.setTag
  @result.getInt set
  @result
];

realAsJSON: [
  result: JSON;
  JSONReal @result.setTag
  @result.getReal set
  @result
];

condAsJSON: [
  result: JSON;
  JSONCond @result.setTag
  @result.getCond set
  @result
];

stringAsJSON: [
  result: JSON;
  JSONString @result.setTag
  @result.getString set
  @result
];

arrayAsJSON: [
  result: JSON;
  JSONArray @result.setTag
  @result.getArray set
  @result
];

objectAsJSON: [
  result: JSON;
  JSONObject @result.setTag
  @result.getObject set
  @result
];

makeJSONParserPosition: [{
  column: copy;
  line: copy;
  offset: copy;
  currentSymbol: copy;
  currentCode: copy;
}];

JSONParserPosition: [0n32 dynamic StringView 0 dynamic 1 dynamic 1 dynamic makeJSONParserPosition];

JSONParserErrorInfo: [{
  message: String;
  position: JSONParserPosition;
}];

JSONParserResult: [{
  success: TRUE dynamic;
  finished: TRUE dynamic;
  errorInfo: JSONParserErrorInfo;
  json: JSON;
}];

jsonInternalFillPositionChars: [
  pos:;
  chars:;

  pos.offset chars.getSize < [
    pos.offset chars.at @pos.@currentSymbol set
    pos.currentSymbol.data Nat8 addressToReference Nat32 cast @pos.@currentCode set
  ] [
    StringView @pos.@currentSymbol set
    ascii.null @pos.@currentCode set
  ] if
];

parseStringToJSON: [
  mainResult: JSONParserResult;
  splittedString: splitString;
  splittedString.success [
    position: JSONParserPosition;
    splittedString.chars @position jsonInternalFillPositionChars

    @mainResult.@json @mainResult splittedString.chars @position parseJSONNode

    position.offset splittedString.chars.getSize < [
      FALSE @mainResult.@finished set
      position @mainResult.@errorInfo.@position set
    ] when
  ] [
    FALSE @mainResult.@success set
    "Wrong encoding, can not recognize line and column, offset in bytes" toString @mainResult.@errorInfo.@message set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@offset set
    0 @mainResult.@errorInfo.@position.@line set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@column set
  ] if

  @mainResult
];

parseJSONNodeImpl: [
  pos:;
  chars:;
  mainResult:;
  result:;

  iterate: [
    mainResult.success [
      pos.currentCode ascii.lf = [
        0 dynamic @pos.@column set
        pos.line 1 + @pos.@line set
      ] when

      pos.offset 1 + @pos.@offset set
      pos.column 1 + @pos.@column set

      chars @pos jsonInternalFillPositionChars
    ] when
  ];

  iterateToNextChar: [
    mainResult.success [
      [
        iterate
        pos.currentCode ascii.null = ~ [pos.currentCode ascii.space > ~] &&
      ] loop
    ] when
  ];

  iterateToNextCharAfterIterate: [
    mainResult.success [
      [
        pos.currentCode ascii.null = ~ [pos.currentCode ascii.space > ~] && [iterate TRUE] &&
      ] loop
    ] when
  ];

  lexicalError: [
    message:;
    mainResult.success [
      (message ", " pos.currentSymbol " found") @mainResult.@errorInfo.@message.catMany
      pos @mainResult.@errorInfo.@position set
      FALSE @mainResult.@success set
    ] when
  ];


  isDigit: [copy code:; code ascii.zero < ~ code ascii.zero 10n32 + < and];

  parseString: [
    pos.currentCode ascii.quote = [
      result: String;
      [
        iterate
        pos.currentCode ascii.quote = ~ [
          pos.currentCode ascii.space < [
            "unterminated string" lexicalError
          ] [
            pos.currentCode ascii.backSlash = [
              iterate
              pos.currentCode ascii.space < [
                "unterminated string" lexicalError
              ] [
                pos.currentCode ascii.quote = [pos.currentCode ascii.slash =] || [pos.currentCode ascii.backSlash =] || [
                  pos.currentSymbol @result.cat
                ] [
                  pos.currentCode ascii.bCode = [
                    ascii.backSpace @result.catAsciiSymbolCode
                  ] [
                    pos.currentCode ascii.fCode = [
                      ascii.ff @result.catAsciiSymbolCode
                    ] [
                      pos.currentCode ascii.tCode = [
                        ascii.tab @result.catAsciiSymbolCode
                      ] [
                        pos.currentCode ascii.nCode = [
                          ascii.lf @result.catAsciiSymbolCode
                        ] [
                          pos.currentCode ascii.rCode = [
                            ascii.cr @result.catAsciiSymbolCode
                          ] [
                            pos.currentCode ascii.uCode = [
                              unicode: 0n32 dynamic;
                              4 dynamic [
                                unicode 16n32 * @unicode set
                                iterate
                                pos.currentCode ascii.zero < ~ [pos.currentCode ascii.zero 10n32 + <] && [
                                  pos.currentCode ascii.zero - unicode + @unicode set
                                ] [
                                  pos.currentCode ascii.aCode < ~ [pos.currentCode ascii.aCode 6n32 + <] && [
                                    pos.currentCode ascii.aCode - 10n32 + unicode + @unicode set
                                  ] [
                                    pos.currentCode ascii.aCodeBig < ~ [pos.currentCode ascii.aCodeBig 6n32 + <] && [
                                      pos.currentCode ascii.aCodeBig - 10n32 + unicode + @unicode set
                                    ] [
                                      "error in unicode" lexicalError
                                    ] if
                                  ] if
                                ] if
                              ] times
                              unicode @result.catSymbolCode
                            ] [
                              "wrong code after \\" lexicalError
                            ] if
                          ] if
                        ] if
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] [
              pos.currentSymbol @result.cat
            ] if
          ] if
          mainResult.success copy
        ] &&
      ] loop

      iterateToNextChar
      @result
    ] [
      "quote expected" lexicalError
      String
    ] if
  ];

  parseStringJSON: [
    parseString stringAsJSON
  ];

  parseNumberJSON: [
    n0: {vi:0i64 dynamic; vf: 0.0r64 dynamic; c:0 dynamic; m:FALSE dynamic;};
    n1: {vi:0i64 dynamic; vf: 0.0r64 dynamic; c:0 dynamic; m:FALSE dynamic;};
    n2: {vi:0i64 dynamic; vf: 0.0r64 dynamic; c:0 dynamic; m:FALSE dynamic;};
    cur: @n0;
    s: 0;

    break: FALSE;
    ov: FALSE;
    [
      pos.currentCode isDigit [
        s 0 = [cur.c 0 >] && [cur.vi 0i64 =] && ["not allowed digits after leading zero" lexicalError] when
        cur.c 1 + @cur.@c set
        digit: pos.currentCode ascii.zero -;
        digiti: digit 0n64 cast 0i64 cast;
        cur.vi 0x7fffffffffffi64 digiti - 10i64 / > [TRUE @ov set] when

        cur.vi 10i64   * digiti            + @cur.@vi set
        cur.vf 10.0r64 * digit 0.0r64 cast + @cur.@vf set
      ] [
        pos.currentCode ascii.dot = [
          s 0 = [cur.c 0 >] && [
            1 @s set
            @n1 !cur
          ] ["wrong number constant" lexicalError] if
        ] [
          pos.currentCode ascii.eCode = [pos.currentCode ascii.eCodeBig =] || [
            s 2 < [cur.c 0 >] && [
              2 @s set
              @n2 !cur
            ] ["wrong number constant" lexicalError] if
          ] [
            pos.currentCode ascii.plus = [
              s 2 = [cur.c 0 =] && [] ["wrong number constant" lexicalError] if
            ] [
              pos.currentCode ascii.minus = [
                s 0 = [s 2 =] || [cur.c 0 =] && [
                  TRUE @cur.@m set
                ] ["wrong number constant" lexicalError] if
              ] [
                TRUE @break set
              ] if
            ] if
          ] if
        ] if
      ] if
      break ~ [mainResult.success copy] && [iterate TRUE] &&
    ] loop

    n1.c 0 = [n2.c 0 =] && [
      ov ["integer constant overflow" lexicalError] when
      n0.m [n0.vi neg][n0.vi copy] if intAsJSON
    ] [
      value: n0.m [n0.vf neg] [n0.vf copy] if;
      frac: n1.vf 10.0r64 n1.c neg 0.0r64 cast ^ *;
      order: n2.m [n2.vf neg] [n2.vf copy] if;
      value frac + 10.0r64 order ^ * realAsJSON
    ] if

    iterateToNextCharAfterIterate
  ];

  parseCondJSON: [
    pos.currentCode ascii.tCode = [
      pos.currentCode ascii.tCode = ~ ["failed to read \"true\"" lexicalError] when
      iterate
      pos.currentCode ascii.rCode = ~ ["failed to read \"true\"" lexicalError] when
      iterate
      pos.currentCode ascii.uCode = ~ ["failed to read \"true\"" lexicalError] when
      iterate
      pos.currentCode ascii.eCode = ~ ["failed to read \"true\"" lexicalError] when
      iterateToNextChar
      TRUE condAsJSON
    ] [
      pos.currentCode ascii.fCode = ~ ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.aCode = ~ ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.lCode = ~ ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.sCode = ~ ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.eCode = ~ ["failed to read \"false\"" lexicalError] when
      iterateToNextChar
      FALSE condAsJSON
    ] if
  ];

  parseNull: [
    pos.currentCode ascii.nCode = ~ ["failed to read \"null\"" lexicalError] when
    iterate
    pos.currentCode ascii.uCode = ~ ["failed to read \"null\"" lexicalError] when
    iterate
    pos.currentCode ascii.lCode = ~ ["failed to read \"null\"" lexicalError] when
    iterate
    pos.currentCode ascii.lCode = ~ ["failed to read \"null\"" lexicalError] when
    iterateToNextChar
    JSON
  ];

  parseObjectJSON: [
    result: String JSON HashTable;
    break: FALSE;
    iterateToNextChar
    [
      pos.currentCode ascii.closeFBr = [
        TRUE @break set
      ] [
        key: parseString;
        key result.find.success [
          "duplicate key" lexicalError
        ] [
          pos.currentCode ascii.colon = ~ [
            ": expected here" lexicalError
          ] [
            iterateToNextChar

            value: JSON;
            @value @mainResult chars @pos parseJSONNode

            @key move @value move @result.insert

            pos.currentCode ascii.comma = [
              iterateToNextChar
            ] [
              pos.currentCode ascii.closeFBr = [
                TRUE @break set
              ] [
                ", or } expected here" lexicalError
              ] if
            ] if
          ] if
        ] if
      ] if
      break ~ [mainResult.success copy] &&
    ] loop
    iterateToNextChar
    @result move objectAsJSON
  ];

  parseArrayJSON: [
    result: JSON Array;
    break: FALSE;
    iterateToNextChar
    [
      pos.currentCode ascii.closeSBr = [
        TRUE @break set
      ] [
        value: JSON;
        @value @mainResult chars @pos parseJSONNode

        @value move @result.pushBack

        pos.currentCode ascii.comma = [
          iterateToNextChar
        ] [
          pos.currentCode ascii.closeSBr = [
            TRUE @break set
          ] [
            ", or ] expected here" lexicalError
          ] if
        ] if
      ] if
      break ~ [mainResult.success copy] &&
    ] loop
    iterateToNextChar
    @result move arrayAsJSON
  ];

  iterateToNextCharAfterIterate

  pos.currentCode ascii.openFBr = [
    parseObjectJSON
  ] [
    pos.currentCode ascii.openSBr = [
      parseArrayJSON
    ] [
      pos.currentCode ascii.quote = [
        parseStringJSON
      ] [
        pos.currentCode isDigit [pos.currentCode ascii.minus =] || [
          parseNumberJSON
        ] [
          pos.currentCode ascii.tCode = [pos.currentCode ascii.fCode =] || [
            parseCondJSON
          ] [
            pos.currentCode ascii.nCode = [
              parseNull
            ] [
              "unexpected symbol" lexicalError
              JSON
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if

  @result set
];

{
  position: JSONParserPosition Ref;
  splittedText: StringView Array Cref;
  parserResultInfo: JSONParserResult Ref;
  json: JSON Ref;
} () {convention: cdecl;} "parseJSONNode" importFunction

{
  position: JSONParserPosition Ref;
  splittedText: StringView Array Cref;
  parserResultInfo: JSONParserResult Ref;
  json: JSON Ref;
} () {convention: cdecl;} [
  position:;
  splittedText:;
  parserResultInfo:;
  json:;

  @json
  @parserResultInfo
  splittedText
  @position parseJSONNodeImpl
] "parseJSONNode" exportFunction


saveJSONToString: [
  json:;
  result: String;

  @result 0 @json catJSONNodeWithPadding

  @result
];

catJSONNodeWithPaddingImpl: [
  json:;
  copy padding:;
  result:;

  catPad: [
    copy nested:;
    LF @result.cat
    nested [padding 2 +] [padding copy] if [" " @result.cat] times
  ];

  catString: [
    splitted: splitString;
    "\"" @result.cat
    [splitted.success copy] "Wrong encoding in JSON string!" assert
    splitted.chars [
      symbol: copy;
      code: symbol.data Nat8 addressToReference Nat32 cast;
      code ascii.quote = [
        "\\\"" @result.cat
      ] [
        code ascii.backSlash = [
          "\\\\" @result.cat
        ] [
          code ascii.slash = [
            "\\/" @result.cat
          ] [
            code ascii.backSpace = [
              "\\b" @result.cat
            ] [
              code ascii.ff = [
                "\\f" @result.cat
              ] [
                code ascii.cr = [
                  "\\r" @result.cat
                ] [
                  code ascii.lf = [
                    "\\n" @result.cat
                  ] [
                    code ascii.tab = [
                      "\\t" @result.cat
                    ] [
                      code ascii.space < ~ code ascii.tilda > ~ and [
                        symbol @result.cat
                      ] [
                        codePoint: size: symbol.data symbol.size getCodePointAndSize;;
                        [size 0 >] "Wrong encoding in splitted array!" assert
                        [codePoint 0x10000n32 <] "Rare codepoint JSON string!" assert
                        "\\u" @result.cat
                        4 [
                          current: codePoint 3 i - 4 * 0n32 cast rshift 0xfn32 and;
                          current 10n32 < [
                            ascii.zero current + @result.catAsciiSymbolCode
                          ] [
                            ascii.aCode current + 10n32 - @result.catAsciiSymbolCode
                          ] if
                        ] times
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] each
    "\"" @result.cat
  ];

  catArrayJSON: [
    "[" @result.cat
    first: TRUE;
    json.getArray [
      item:;
      first ~ ["," @result.cat] [FALSE @first set] if
      TRUE catPad

      @result
      padding 2 +
      item catJSONNodeWithPadding
    ] each
    FALSE catPad
    "]" @result.cat
  ];

  catObjectJSON: [
    "{" @result.cat
    first: TRUE;
    json.getObject [
      pair:;
      first ~ ["," @result.cat] [FALSE @first set] if
      TRUE catPad
      pair.key catString
      ": " @result.cat

      @result padding 2 + pair.value catJSONNodeWithPadding
    ] each
    FALSE catPad
    "}" @result.cat
  ];

  catStringJSON: [
    json.getString catString
  ];

  json.getTag JSONNull = [
    "null" @result.cat
  ] [
    json.getTag JSONInt = [
      json.getInt @result.cat
    ] [
      json.getTag JSONReal = [
        json.getReal @result.cat
      ] [
        json.getTag JSONCond = [
          json.getCond ["true" @result.cat]["false" @result.cat] if
        ] [
          json.getTag JSONString = [
            catStringJSON
          ] [
            json.getTag JSONArray = [
              catArrayJSON
            ] [
              json.getTag JSONObject = [
                catObjectJSON
              ] [
                [FALSE] "Unknown JSON tag!" assert
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
];

{
  json: JSON Cref;
  padding: Int32;
  result: String Ref;
} () {convention: cdecl;} "catJSONNodeWithPadding" importFunction

{
  json: JSON Cref;
  padding: Int32;
  result: String Ref;
} () {convention: cdecl;} [
  json:;
  padding:;
  result:;
  @result padding json catJSONNodeWithPaddingImpl
] "catJSONNodeWithPadding" exportFunction
