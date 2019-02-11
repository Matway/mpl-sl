"Xml" module
"ascii"     includeModule
"HashTable" includeModule
"String"    includeModule
"Variant"   includeModule

XML: [{
  mem0:  0nx  dynamic;
  mem1:  0nx  dynamic;
  mem2:  0nx  dynamic;
  mem3:  0nx  dynamic;
  mem4:  0n32 dynamic;
  mem5:  0n32 dynamic;
  mem6:  0n32 dynamic;
  mem7:  0n32 dynamic;
  mem8:  0n32 dynamic;
  mem9:  0n32 dynamic;
  mem10: 0n32 dynamic;
  mem11: 0n32 dynamic;

  impl: [
    @self storageAddress addrAsXMLImpl
  ] func;

  INIT:   [               @closure storageAddress XMLInit];
  ASSIGN: [storageAddress @closure storageAddress XMLSet];
  DIE:    [               @closure storageAddress XMLDestroy];
}] func;

addrAsXMLImpl: [@XMLImplRef addressToReference] func;

{dst: 0nx;          } () {convention: cdecl;} "XMLDestroy" importFunction
{dst: 0nx; src: 0nx;} () {convention: cdecl;} "XMLSet"     importFunction
{dst: 0nx;          } () {convention: cdecl;} "XMLInit"    importFunction

XMLImplArray: [XML Array] func;
XMLImplObject: [String XML HashTable] func;

XMLAttribute: [{
  name: String;
  value: String;
}] func;

XMLImpl: [
  result: {
    name: String;
    attributes: XMLAttribute Array;
    children: XML Array;
    value: String;
  };

  result storageSize XML storageSize = not [0 .STORAGE_SIZE_FAIL] when
  result alignment   XML alignment   = not [0 .ALIGNMENT_FAIL] when
  @result
] func;

schema XMLImplRef: XMLImpl;

{dst: 0nx;          } () {convention: cdecl;} [
  addrAsXMLImpl manuallyInitVariable
] "XMLInit" exportFunction

{dst: 0nx; src: 0nx;} () {convention: cdecl;} [
  dst: addrAsXMLImpl;
  src: addrAsXMLImpl;
  src @dst set
] "XMLSet" exportFunction

{dst: 0nx;          } () {convention: cdecl;} [
  addrAsXMLImpl manuallyDestroyVariable
] "XMLDestroy" exportFunction

makeXMLParserPosition: [{
  column: copy;
  line: copy;
  offset: copy;
  currentSymbol: copy;
  currentCode: copy;
}] func;

XMLParserPosition: [0n32 dynamic StringView 0 dynamic 1 dynamic 1 dynamic makeXMLParserPosition] func;

XMLParserErrorInfo: [{
  message: String;
  position: XMLParserPosition;
}] func;

XMLParserResult: [{
  success: TRUE dynamic;
  finished: TRUE dynamic;
  errorInfo: XMLParserErrorInfo;
  xml: XML;
}] func;

xmlInternal: {
  fillPositionChars: [
    pos:;
    chars:;

    position.offset chars.getSize < [
      position.offset chars.at @position.@currentSymbol set
      position.currentSymbol stringMemory Nat8 addressToReference Nat32 cast @position.@currentCode set
    ] [
      StringView @position.@currentSymbol set
      ascii.null @position.@currentCode set
    ] if
  ] func;

  iterate: [
    mainResult.success [
      position.currentCode ascii.lf = [
        0 dynamic @position.@column set
        position.line 1 + @position.@line set
      ] when

      position.offset 1 + @position.@offset set
      position.column 1 + @position.@column set

      chars @position fillPositionChars
    ] when
  ] func;

  iterateToNextChar: [
    mainResult.success [
      [
        iterate
        position.currentCode ascii.null = not [position.currentCode ascii.space > not] &&
      ] loop
    ] when
  ] func;

  onlySpaces: [
    result: TRUE dynamic;
    .chars [
      code: .value;
      result [code Nat32 cast ascii.space >] && [FALSE !result] when
    ] each
    result
  ] func;

  startFrom: [
    pat: makeStringView;
    str: makeStringView;
    pat.dataSize str.dataSize > not [
      result: TRUE dynamic;
      i: 0 dynamic;
      [result copy [i pat.dataSize <] &&] [
        addr1: str.dataBegin storageAddress i Natx cast + Nat8 addressToReference;
        addr2: pat.dataBegin storageAddress i Natx cast + Nat8 addressToReference;
        addr1 addr2 = @result set
        i 1 + @i set
      ] while
      result copy
    ] &&
  ] func;

  iterateToNextCharAfterIterate: [
    mainResult.success [
      [
        position.currentCode ascii.null = not [position.currentCode ascii.space > not] && [iterate TRUE] &&
      ] loop
    ] when
  ] func;

  lexicalError: [
    mainResult.success [
      (makeStringView ", " position.currentSymbol " found") assembleString @mainResult.@errorInfo.@message set
      position @mainResult.@errorInfo.@position set
      FALSE @mainResult.@success set
    ] [
      m:;
    ] if
  ] func;

  XMLTag: [{
    name: String;
    attributes: XMLAttribute Array;
    comment: FALSE dynamic;
    noBody: FALSE dynamic;
    closed: FALSE dynamic;
  }] func;

  inSet: [
    where:;
    what:;

    result: FALSE;
    where [v: .value; result not [v what =] && [TRUE !result] when] each
    result
  ] func;

  parseString: [
    position.currentCode ascii.quote = [
      result: String;
      [
        iterate
        position.currentCode ascii.quote = not [
          position.currentCode ascii.space < [
            "unterminated string" lexicalError
          ] [
            position.currentCode ascii.backSlash = [
              iterate
              position.currentCode ascii.space < [
                "unterminated string" lexicalError
              ] [
                position.currentCode ascii.quote = [position.currentCode ascii.slash =] || [position.currentCode ascii.backSlash =] || [
                  position.currentSymbol @result.cat
                ] [
                  position.currentCode ascii.bCode = [
                    ascii.backSpace @result.catAsciiSymbolCode
                  ] [
                    position.currentCode ascii.fCode = [
                      ascii.ff @result.catAsciiSymbolCode
                    ] [
                      position.currentCode ascii.tCode = [
                        ascii.tab @result.catAsciiSymbolCode
                      ] [
                        position.currentCode ascii.nCode = [
                          ascii.lf @result.catAsciiSymbolCode
                        ] [
                          position.currentCode ascii.rCode = [
                            ascii.cr @result.catAsciiSymbolCode
                          ] [
                            position.currentCode ascii.uCode = [
                              unicode: 0n32 dynamic;
                              4 dynamic [
                                unicode 16n32 * @unicode set
                                iterate
                                position.currentCode ascii.zero < not [position.currentCode ascii.zero 10n32 + <] && [
                                  position.currentCode ascii.zero - unicode + @unicode set
                                ] [
                                  position.currentCode ascii.aCode < not [position.currentCode ascii.aCode 6n32 + <] && [
                                    position.currentCode ascii.aCode - 10n32 + unicode + @unicode set
                                  ] [
                                    position.currentCode ascii.aCodeBig < not [position.currentCode ascii.aCodeBig 6n32 + <] && [
                                      position.currentCode ascii.aCodeBig - 10n32 + unicode + @unicode set
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
              position.currentSymbol @result.cat
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

  parseIdentifier: [
    badSymbols:;
    endSymbols:;
    result: String;

    [
      position.currentSymbol badSymbols inSet [
        (position.currentSymbol " not expected here") assembleString lexicalError
        FALSE
      ] [
        position.currentCode ascii.null = [
          "end of string not expected here" lexicalError
          FALSE
        ] [
          position.currentSymbol endSymbols inSet [
            result "" = ["empty identifier" lexicalError] when
            FALSE
          ] [
            position.currentSymbol @result.catString
            iterate
            TRUE
          ] if
        ] if
      ] if
    ] loop

    iterateToNextCharAfterIterate
    result
  ] func;

  tryParseTag: [
    begin: position.offset 0 =;
    hasQuestion: FALSE dynamic;
    result: XMLTag;
    iterateToNextCharAfterIterate
    position.currentSymbol "<" = [
      iterateToNextChar
      position.currentSymbol "/" = [
        iterate
        TRUE @result.!closed
      ] when

      position.currentSymbol "?" = [
        iterate
        TRUE !hasQuestion
      ] when

      (">" " " "/") ("=") parseIdentifier @result.@name set

      result.name "!--" startFrom [
        TRUE @result.!comment
        stage: 0 dynamic;
        [
          position.currentCode ascii.null = [
            "comment must be closed" lexicalError
            FALSE
          ] [
            stage (
              0 [position.currentSymbol "-" = [1][0] if @stage set]
              1 [position.currentSymbol "-" = [2][0] if @stage set]
              2 [position.currentSymbol ">" = [3][0] if @stage set]
              [0 @stage set]
            ) case
            iterate
            stage 3 <
          ] if
        ] loop
      ] [
        [
          mainResult.success [
            iterateToNextCharAfterIterate
            position.currentSymbol "?" = [hasQuestion copy] && [
              iterate
              position.currentSymbol ">" = not ["expected > after ?" lexicalError] when
              iterate
              FALSE
            ] [
              position.currentSymbol ">" = [
                iterate
                FALSE
              ] [
                result.closed ["expected > here, closed tag can not have attributes" lexicalError] when

                position.currentSymbol "/" = [
                  iterate
                  position.currentSymbol ">" = not ["expected > after /" lexicalError] when
                  iterate
                  TRUE @result.!noBody
                  FALSE
                ] [
                  newAttribute: XMLAttribute;
                  ("=") ("/" ">" " ") parseIdentifier @newAttribute.@name set
                  mainResult.success [
                    iterateToNextChar
                    parseString @newAttribute.@value set
                    mainResult.success [
                      @newAttribute move @result.@attributes.pushBack
                      TRUE
                    ] &&
                  ] &&
                ] if
              ] if
            ] if
          ] &&
        ] loop
      ] if
    ] [
      "expected < while parsing new tag" lexicalError
    ] if

    hasQuestion [
      begin [result.name "xml" =] && [
        TRUE @result.!comment
      ] [
        "tag with ? not expected here" lexicalError
      ] if
    ] when

    @result
  ] func;

  parseTag: [
    result: XMLTag;
    [
      tryParseTag !result
      mainResult.success result.comment and
    ] loop

    @result
  ] func;
};

parseStringToXML: [
  mainResult: XMLParserResult;
  splittedString: makeStringView.split;
  splittedString.success [
    @mainResult.@xml.impl @mainResult splittedString.chars XMLParserPosition parseStringToXMLImpl
  ] [
    FALSE @mainResult.@success set
    "Wrong encoding, can not recognize line and column, offset in bytes" toString @mainResult.@errorInfo.@message set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@offset set
    0 @mainResult.@errorInfo.@position.@line set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@column set
  ] if

  @mainResult
] func;

{
  lastTag: xmlInternal.XMLTag Ref;
  position: XMLParserPosition Ref;
  chars: StringView Array Cref;
  mainResult: XMLParserResult Ref;
  xml: XMLImpl Ref;
} () {convention: cdecl;} "parseXMLNodeFromTag" importFunction

{
  lastTag: xmlInternal.XMLTag Ref;
  position: XMLParserPosition Ref;
  chars: StringView Array Cref;
  mainResult: XMLParserResult Ref;
  xml: XMLImpl Ref;
} () {convention: cdecl;} [
  lastTag:;
  position:;
  chars:;
  mainResult:;
  xml:;

  mainResult.success [
    lastTag.closed ["closed tag not expected here" xmlInternal.lexicalError] when

    mainResult.success [
      @lastTag.@name       move @xml.@name       set
      @lastTag.@attributes move @xml.@attributes set

      lastTag.noBody not [
        position.currentSymbol "<" = not [
          ("<") () xmlInternal.parseIdentifier @xml.@value set
        ] when

        xml.value xmlInternal.onlySpaces [
          @xml.@value.@chars.clear
          position.currentSymbol "<" = [
            [
              xmlInternal.parseTag @lastTag set
              mainResult.success [lastTag.closed not] && [
                child: XML;
                child.impl @mainResult chars @position @lastTag parseXMLNodeFromTag
                mainResult.success [
                  @child move @xml.@children.pushBack
                  TRUE
                ] &&
              ] &&
            ] loop
          ] [
            "expected < here" xmlInternal.lexicalError
          ] if
        ] [
          xmlInternal.parseTag @lastTag set
          mainResult.success [lastTag.closed not] && [
            "closed tag expected" xmlInternal.lexicalError
          ] when
        ] if

        lastTag.name xml.name = not ["opened and closed tag has different name" xmlInternal.lexicalError] when
      ] when
    ] when
  ] when
] "parseXMLNodeFromTag" exportFunction

{
  position: XMLParserPosition Ref;
  chars: StringView Array Cref;
  mainResult: XMLParserResult Ref;
  xml: XMLImpl Ref;
} () {convention: cdecl;} [
  position:;
  chars:;
  mainResult:;
  xml:;

  chars @position xmlInternal.fillPositionChars
  @mainResult.@xml.impl @mainResult chars @position xmlInternal.parseTag parseXMLNodeFromTag

  position.offset chars.getSize < [
    FALSE @mainResult.@finished set
    position @mainResult.@errorInfo.@position set
  ] when
] "parseStringToXMLImpl" exportFunction

saveXMLToString: [
  xml:;
  result: String;

  @result 0 xml.impl catXMLNodeWithPadding
  @result
] func;

{
  xml: XMLImpl Cref;
  padding: Int32;
  result: String Ref;
} () {convention: cdecl;} "catXMLNodeWithPadding" importFunction

{
  xml: XMLImpl Cref;
  padding: Int32;
  result: String Ref;
} () {convention: cdecl;} [
  xml:;
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
    [splitted.success copy] "Wrong encoding in XML string!" assert
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
                        [codePoint 0x10000n32 <] "Rare codepoint XML string!" assert
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

  FALSE catPad
  "<" @result.cat
  xml.name @result.cat
  xml.attributes [
    current: .value;
    " " @result.cat
    current.name @result.cat
    "=" @result.cat
    current.value catString
  ] each

  xml.value "" = [
    xml.children.getSize 0 = [
      "/>" @result.cat
    ] [
      ">" @result.cat
      xml.children [
        current: .value;
        @result padding 2 + current.impl catXMLNodeWithPadding
      ] each

      FALSE catPad
      ("</" xml.name ">" LF) @result.catMany
    ] if
  ] [
    (">" xml.value "</" xml.name ">") @result.catMany
  ] if
] "catXMLNodeWithPadding" exportFunction
