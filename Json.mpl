"Json" module
"ascii"     includeModule
"HashTable" includeModule
"String"    includeModule
"Variant"   includeModule

JSONNull:   [0 static] func;
JSONInt:    [1 static] func;
JSONReal:   [2 static] func;
JSONCond:   [3 static] func;
JSONString: [4 static] func;
JSONArray:  [5 static] func;
JSONObject: [6 static] func;

JSON: [{
  mem0: 0n64 dynamic;
  mem1: 0n64 dynamic;
  mem2: 0nx dynamic;
  mem3: 0nx dynamic;

  impl: [
    @self storageAddress addrAsJSONImpl
  ] func;

  getTag:    [impl.@data.getTag] func;
  setTag:    [impl.@data.setTag] func;

  getInt:    [JSONInt    impl.@data.get] func;
  getReal:   [JSONReal   impl.@data.get] func;
  getCond:   [JSONCond   impl.@data.get] func;
  getString: [JSONString impl.@data.get] func;
  getArray:  [JSONArray  impl.@data.get] func;
  getObject: [JSONObject impl.@data.get] func;

  INIT:   [               @closure storageAddress JSONInit];
  ASSIGN: [storageAddress @closure storageAddress JSONSet];
  DIE:    [               @closure storageAddress JSONDestroy];
}] func;

addrAsJSONImpl: [@JSONImplRef addressToReference] func;

{dst: 0nx;          } () {convention: "cdecl";} "JSONDestroy" importFunction
{dst: 0nx; src: 0nx;} () {convention: "cdecl";} "JSONSet"     importFunction
{dst: 0nx;          } () {convention: "cdecl";} "JSONInit"    importFunction

JSONImplArray: [JSON Array] func;
JSONImplObject: [String JSON HashTable] func;

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

  result storageSize JSON storageSize = not [0 .STORAGE_SIZE_FAIL] when
  result alignment   JSON alignment   = not [0 .ALIGNMENT_FAIL] when
  @result
] func;

schema JSONImplRef: JSONImpl;

{dst: 0nx;          } () {convention: "cdecl";} [
  addrAsJSONImpl manuallyInitVariable
] "JSONInit" exportFunction

{dst: 0nx; src: 0nx;} () {convention: "cdecl";} [
  dst: addrAsJSONImpl;
  src: addrAsJSONImpl;
  src @dst set
] "JSONSet" exportFunction

{dst: 0nx;          } () {convention: "cdecl";} [
  addrAsJSONImpl manuallyDestroyVariable
] "JSONDestroy" exportFunction

intAsJSON: [
  result: JSON;
  JSONInt @result.setTag
  @result.getInt set
  @result
] func;

realAsJSON: [
  result: JSON;
  JSONReal @result.setTag
  @result.getReal set
  @result
] func;

condAsJSON: [
  result: JSON;
  JSONCond @result.setTag
  @result.getCond set
  @result
] func;

stringAsJSON: [
  result: JSON;
  JSONString @result.setTag
  @result.getString set
  @result
] func;

arrayAsJSON: [
  result: JSON;
  JSONArray @result.setTag
  @result.getArray set
  @result
] func;

objectAsJSON: [
  result: JSON;
  JSONObject @result.setTag
  @result.getObject set
  @result
] func;

makeJSONParserPosition: [{
  column: copy;
  line: copy;
  offset: copy;
  currentSymbol: copy;
  currentCode: copy;
}] func;

JSONParserPosition: [0n32 dynamic StringView 0 dynamic 1 dynamic 1 dynamic makeJSONParserPosition] func;

JSONParserErrorInfo: [{
  message: String;
  position: JSONParserPosition;
}] func;

JSONParserResult: [{
  success: TRUE dynamic;
  finished: TRUE dynamic;
  errorInfo: JSONParserErrorInfo;
  json: JSON;
}] func;

fillPositionChars: [
  pos:;
  chars:;

  pos.offset chars.getSize < [
    pos.offset chars.at @pos.@currentSymbol set
    pos.currentSymbol stringMemory Nat8 addressToReference Nat32 cast @pos.@currentCode set
  ] [
    StringView @pos.@currentSymbol set
    ascii.null @pos.@currentCode set
  ] if
] func;

parseStringToJSON: [
  mainResult: JSONParserResult;
  splittedString: makeStringView.split;
  splittedString.success [
    position: JSONParserPosition;
    splittedString.chars @position fillPositionChars

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
] func;

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

      chars @pos fillPositionChars
    ] when
  ] func;

  iterateToNextChar: [
    mainResult.success [
      [
        iterate
        pos.currentCode ascii.null = not [pos.currentCode ascii.space > not] &&
      ] loop
    ] when
  ] func;

  iterateToNextCharAfterIterate: [
    mainResult.success [
      [
        pos.currentCode ascii.null = not [pos.currentCode ascii.space > not] && [iterate TRUE] &&
      ] loop
    ] when
  ] func;

  lexicalError: [
    mainResult.success [
      (makeStringView ", " pos.currentSymbol " found") assembleString @mainResult.@errorInfo.@message set
      pos @mainResult.@errorInfo.@position set
      FALSE @mainResult.@success set
    ] [
      m:;
    ] if
  ] func;


  isDigit: [copy code:; code ascii.zero < not code ascii.zero 10n32 + < and] func;

  parseString: [
    pos.currentCode ascii.quote = [
      result: String;
      [
        iterate
        pos.currentCode ascii.quote = not [
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
                                pos.currentCode ascii.zero < not [pos.currentCode ascii.zero 10n32 + <] && [
                                  pos.currentCode ascii.zero - unicode + @unicode set
                                ] [
                                  pos.currentCode ascii.aCode < not [pos.currentCode ascii.aCode 6n32 + <] && [
                                    pos.currentCode ascii.aCode - 10n32 + unicode + @unicode set
                                  ] [
                                    pos.currentCode ascii.aCodeBig < not [pos.currentCode ascii.aCodeBig 6n32 + <] && [
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
  ] func;

  parseStringJSON: [
    parseString stringAsJSON
  ] func;

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
      break not [mainResult.success copy] && [iterate TRUE] &&
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
  ] func;

  parseCondJSON: [
    pos.currentCode ascii.tCode = [
      pos.currentCode ascii.tCode = not ["failed to read \"true\"" lexicalError] when
      iterate
      pos.currentCode ascii.rCode = not ["failed to read \"true\"" lexicalError] when
      iterate
      pos.currentCode ascii.uCode = not ["failed to read \"true\"" lexicalError] when
      iterate
      pos.currentCode ascii.eCode = not ["failed to read \"true\"" lexicalError] when
      iterateToNextChar
      TRUE condAsJSON
    ] [
      pos.currentCode ascii.fCode = not ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.aCode = not ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.lCode = not ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.sCode = not ["failed to read \"false\"" lexicalError] when
      iterate
      pos.currentCode ascii.eCode = not ["failed to read \"false\"" lexicalError] when
      iterateToNextChar
      FALSE condAsJSON
    ] if
  ] func;

  parseNull: [
    pos.currentCode ascii.nCode = not ["failed to read \"null\"" lexicalError] when
    iterate
    pos.currentCode ascii.uCode = not ["failed to read \"null\"" lexicalError] when
    iterate
    pos.currentCode ascii.lCode = not ["failed to read \"null\"" lexicalError] when
    iterate
    pos.currentCode ascii.lCode = not ["failed to read \"null\"" lexicalError] when
    iterateToNextChar
    JSON
  ] func;

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
          pos.currentCode ascii.colon = not [
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
      break not [mainResult.success copy] &&
    ] loop
    iterateToNextChar
    @result move objectAsJSON
  ] func;

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
      break not [mainResult.success copy] &&
    ] loop
    iterateToNextChar
    @result move arrayAsJSON
  ] func;

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
] func;

{
  position: JSONParserPosition Ref;
  splittedText: StringView Array Cref;
  parserResultInfo: JSONParserResult Ref;
  json: JSON Ref;
} () {convention: "cdecl";} "parseJSONNode" importFunction

{
  position: JSONParserPosition Ref;
  splittedText: StringView Array Cref;
  parserResultInfo: JSONParserResult Ref;
  json: JSON Ref;
} () {convention: "cdecl";} [
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
] func;

catJSONNodeWithPaddingImpl: [
  json:;
  copy padding:;
  result:;

  catPad: [
    copy nested:;
    LF @result.cat
    nested [padding 2 +] [padding copy] if [" " @result.cat] times
  ] func;

  catString: [
    splitted: makeStringView.split;
    "\"" @result.cat
    [splitted.success copy] "Wrong encoding in JSON string!" assert
    splitted.chars [
      symbol: .value copy;
      code: symbol stringMemory Nat8 addressToReference Nat32 cast;
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
                      code ascii.space < not code ascii.tilda > not and [
                        symbol @result.cat
                      ] [
                        codePoint:size: symbol stringMemory symbol.dataSize getCodePointAndSize;;
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
  ] func;

  catArrayJSON: [
    "[" @result.cat
    first: TRUE;
    json.getArray [
      pair:;
      first not ["," @result.cat] [FALSE @first set] if
      TRUE catPad

      @result
      padding 2 +
      pair.value catJSONNodeWithPadding
    ] each
    FALSE catPad
    "]" @result.cat
  ] func;

  catObjectJSON: [
    "{" @result.cat
    first: TRUE;
    json.getObject [
      pair:;
      first not ["," @result.cat] [FALSE @first set] if
      TRUE catPad
      pair.key catString
      ": " @result.cat

      @result padding 2 + pair.value catJSONNodeWithPadding
    ] each
    FALSE catPad
    "}" @result.cat
  ] func;

  catStringJSON: [
    json.getString catString
  ] func;

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
] func;


{
  json: JSON Cref;
  padding: Int32;
  result: String Ref;
} () {convention: "cdecl";} "catJSONNodeWithPadding" importFunction


{
  json: JSON Cref;
  padding: Int32;
  result: String Ref;
} () {convention: "cdecl";} [
  json:;
  padding:;
  result:;
  @result padding json catJSONNodeWithPaddingImpl
] "catJSONNodeWithPadding" exportFunction
