"Array.Array" use
"String.String" use
"String.StringView" use
"String.assembleString" use
"String.getCodePointAndSize" use
"String.splitString" use
"Variant.Variant" use
"ascii.ascii" use
"control.&&" use
"control.=" use
"control.Cref" use
"control.Int32" use
"control.Nat32" use
"control.Natx" use
"control.Ref" use
"control.assert" use
"control.case" use
"control.cond" use
"control.drop" use
"control.each" use
"control.times" use
"control.when" use
"control.while" use
"conventions.cdecl" use

XMLParserResult: [{
  success: TRUE dynamic;
  finished: TRUE dynamic;
  errorInfo: XMLParserErrorInfo;
  xml: XMLDocument;
}];

XMLParserPosition: [{
  column: Int32;
  line: Int32;
  offset: Int32;
  currentSymbol: StringView;
  currentCodepoint: Nat32;
}];

XMLParserErrorInfo: [{
  message: String;
  position: XMLParserPosition;
}];

XMLDocument: [{
  root: XMLElement;
}];

XMLVALUE_ELEMENT: [0];

XMLVALUE_CHARDATA: [1];

XMLValue: [(XMLElement String) Variant];

XMLAttribute: [{
  name: String;
  value: String;
}];

XMLElement: [
  result: {
    name: String;
    attributes: XMLAttribute Array;

    getChildren: [
      childrenStorage storageAddress XMLValue Array addressToReference
    ];

    childrenStorage: XMLValueHelper Array;
  };

  result storageSize XMLElementHelper storageSize = ~ [0 .STORAGE_SIZE_FAIL] when
  result alignment   XMLElementHelper alignment   = ~ [0 .ALIGNMENT_FAIL] when
  @result
];

XMLValueHelper: [(XMLElementHelper String) Variant];

XMLElementHelper: [{
  ArrayHelper ".padding" def
  ArrayHelper ".padding" def
  ArrayHelper ".padding" def

  INIT:   [               @closure storageAddress XMLElementInit];
  ASSIGN: [storageAddress @closure storageAddress XMLElementSet];
  DIE:    [               @closure storageAddress XMLElementDestroy];
}];

ArrayHelper: [{
  dataBegin: Natx;
  dataSize: Int32;
  dataReserve: Int32;
}];

{dst: 0nx;          } () {convention: cdecl;} "XMLElementDestroy" importFunction
{dst: 0nx; src: 0nx;} () {convention: cdecl;} "XMLElementSet"     importFunction
{dst: 0nx;          } () {convention: cdecl;} "XMLElementInit"    importFunction

schema XMLElementRef: XMLElement;

asXMLElement: [@XMLElementRef addressToReference];

{dst: 0nx;          } () {convention: cdecl;} [
  asXMLElement manuallyInitVariable
] "XMLElementInit" exportFunction

{dst: 0nx; src: 0nx;} () {convention: cdecl;} [
  dst: asXMLElement;
  src: asXMLElement;
  src @dst set
] "XMLElementSet" exportFunction

{dst: 0nx;          } () {convention: cdecl;} [
  asXMLElement manuallyDestroyVariable
] "XMLElementDestroy" exportFunction

{
  position: XMLParserPosition Ref;
  chars: StringView Array Cref;
  mainResult: XMLParserResult Ref;
  xml: XMLDocument Ref;
} () {convention: cdecl;} "parseStringToXMLImpl" importFunction

parseStringToXML: [
  mainResult: XMLParserResult;
  splittedString: makeStringView.split;
  splittedString.success [
    @mainResult.@xml @mainResult splittedString.chars XMLParserPosition parseStringToXMLImpl
  ] [
    FALSE @mainResult.@success set
    "Wrong encoding, can not recognize line and column, offset in bytes" toString @mainResult.@errorInfo.@message set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@offset set
    0 @mainResult.@errorInfo.@position.@line set
    splittedString.errorOffset 0 cast @mainResult.@errorInfo.@position.@column set
  ] if

  @mainResult
];

saveXMLToString: [
  xml:;
  result: String;

  @result 0 dynamic xml.root xmlInternal.printElementToString
  @result
];

xmlInternal: {
  printElementToString: [
    recursive
    string:depth:xml:;;;
    catPad: [depth 2 * [" " @string.cat] times];
    catPad ("<" xml.name) @string.catMany
    xml.attributes [
      attrib:;
      (" " attrib.name "=\"" attrib.value "\"") @string.catMany
    ] each

    xml.getChildren.getSize 0 = [
      "/>" @string.cat
    ] [
      ">" @string.cat
      hasNondataChild: FALSE;
      xml.getChildren [
        child:;
        child.getTag (
          XMLVALUE_CHARDATA [
            data: XMLVALUE_CHARDATA child.get;
            data @string.cat
          ]
          XMLVALUE_ELEMENT [
            TRUE !hasNondataChild
            LF @string.cat
            @string depth 1 + XMLVALUE_ELEMENT child.get printElementToString
          ]
          []
        ) case
      ] each

      hasNondataChild [
        LF @string.cat
        catPad
      ] when

      ("</" xml.name ">") @string.catMany
    ] if
  ];

  makeXMLParserPosition: [
    column: copy;
    line: copy;
    offset: copy;
    currentSymbol: copy;
    currentCodepoint: copy;
    position: XMLParsrPosition;
    column @position.@column set
    line @position.@line set
    offset @position.@offset set
    currentSymbol move @position.@currentSymbol set
    currentCodepoint @position.@currentCodepoint set
  ];

  fillPositionChars: [
    pos:;
    chars:;

    position.offset chars.getSize < [
      position.offset chars.at @position.@currentSymbol set
      cpMemory: position.currentSymbol.data;
      cpSize: position.currentSymbol.size;
      cpMemory cpSize getCodePointAndSize drop @position.@currentCodepoint set
    ] [
      StringView @position.@currentSymbol set
      ascii.null @position.@currentCodepoint set
    ] if
  ];

  iterate: [
    mainResult.success [
      position.currentCodepoint ascii.lf = [
        0 dynamic @position.@column set
        position.line 1 + @position.@line set
      ] when

      position.offset 1 + @position.@offset set
      position.column 1 + @position.@column set

      chars @position fillPositionChars
    ] when
  ];

  lexicalError: [
    message:;
    mainResult.success [
      (message ", " position.currentSymbol " found") @mainResult.@errorInfo.@message.catMany
      position @mainResult.@errorInfo.@position set
      FALSE @mainResult.@success set
    ] when
  ];

  parseDocument: [
    document: XMLDocument;
    parseProlog
    parseElementFromOpenTag @document.@root set
    parseDocumentEnd
    @document
  ];

  parseProlog: [
    elementFound: FALSE;
    position.currentCodepoint ascii.less = [
      iterateChecked
      position.currentCodepoint ascii.question = [
        iterateChecked
        parseXMLDecl
        skipWhiteSpaces
        "<" skipString
      ] when
    ] [
      skipWhiteSpaces
      "<" skipString
    ] if

    [
      position.currentCodepoint ascii.exclamation = [
        iterateChecked
        position.currentSymbol "-" = [
          "--" skipString
          parseComment
        ] [
          "unsupported feature - PI or doctypedecl" lexicalError
        ] if
      ] [
        TRUE !elementFound
      ] if

      elementFound ~ [
        skipWhiteSpaces
        "<" skipString
      ] when

      elementFound ~ mainResult.success and
    ] loop
  ];

  parseXMLDecl: [
    mainResult.success [
      "xml" skipString
      skipWhiteSpacesRequired
      parseVersionDecl
      isSpaceSkipped: position.currentCodepoint isWhiteSpace;
      skipWhiteSpaces
      position.currentCodepoint ascii.eCode = [
        isSpaceSkipped [
          parseEncodingDecl
          position.currentCodepoint isWhiteSpace !isSpaceSkipped
          skipWhiteSpaces
        ] [
          "expected whitespace" lexicalError
        ] if
      ] when

      position.currentCodepoint ascii.sCode = [
        isSpaceSkipped [
          parseSDDecl
        ] [
          "expected whitespace" lexicalError
        ] if
      ] when

      skipWhiteSpaces
      "?>" skipString
    ] when
  ];

  parseVersionDecl: [
    "version" skipString
    parseEq
    position.currentCodepoint (
      ascii.apostrophe [
        iterateChecked
        parseVerisonNum
        "'" skipString
      ]
      ascii.quote [
        iterateChecked
        parseVerisonNum
        "\"" skipString
      ]
      ["expected \" or '" lexicalError]
    ) case
  ];

  parseVerisonNum: [
    validRanges: (
      # must be sorted
      (ascii.minus     ascii.minus    )
      (ascii.dot       ascii.dot      )
      (ascii.zero      ascii.nine     )
      (ascii.colon     ascii.colon    )
      (ascii.aCodeBig  ascii.zCodeBig )
      (ascii.underline ascii.underline)
      (ascii.aCode     ascii.zCode    )
    );

    position.currentCodepoint validRanges isInRanges ~ [
      "expected [a-zA-Z0-9_.:] | '-'" lexicalError
    ] when

    [
      iterateChecked
      position.currentCodepoint @validRanges isInRanges mainResult.success and
    ] loop
  ];

  parseEncodingDecl: [
    "encoding" skipString
    parseEq
    position.currentCodepoint (
      ascii.apostrophe [
        iterateChecked
        parseEncName
        "'" skipString
      ]
      ascii.quote [
        iterateChecked
        parseEncName
        "\"" skipString
      ]
      ["expected \" or '" lexicalError]
    ) case
  ];

  parseEncName: [
    validRangesFirst: (
      (ascii.aCodeBig ascii.zCodeBig)
      (ascii.aCode    ascii.zCode   )
    );

    validRangesRemaining: (
      (ascii.minus     ascii.minus    )
      (ascii.dot       ascii.dot      )
      (ascii.zero      ascii.nine     )
      (ascii.underline ascii.underline)
    );

    position.currentCodepoint validRangesFirst isInRanges ~ [
      "expected [A-Za-z]" lexicalError
    ] when

    [
      iterateChecked
      position.currentCodepoint (
        [validRangesFirst isInRanges]
        [validRangesRemaining isInRanges]
      ) anyOf mainResult.success and
    ] loop
  ];

  parseSDDecl: [
    "standalone" skipString
    parseEq
    position.currentCodepoint (
      ascii.apostrophe [
        iterateChecked
        position.currentCodepoint (
          ascii.yCode ["yes" skipString]
          ascii.nCode ["no" skipString]
          ["expected y or n" lexicalError]
        ) case

        "'" skipString
      ]
      ascii.quote [
        iterateChecked
        position.currentCodepoint (
          ascii.yCode ["yes" skipString]
          ascii.nCode ["no" skipString]
          ["expected y or n" lexicalError]
        ) case
        "\"" skipString
      ]
      ["expected \" or '" lexicalError]
    ) case
  ];

  parseElement: [
    result: XMLValue;
    mainResult.success [
      skipWhiteSpaces
      "<" skipString
      parseElementFromOpenTag @result set
    ] when

    @result
  ];

  parseEq: [
    skipWhiteSpaces
    "=" skipString
    skipWhiteSpaces
  ];

  parseDocumentEnd: [
    stringEndFound: FALSE;
    position.currentCodepoint ascii.null = [
      TRUE !stringEndFound
    ] [
      [
        position.currentCodepoint (
          [ascii.null =] [
            TRUE !stringEndFound
          ]
          [isWhiteSpace] [
            iterateChecked
          ]
          [
            "<!--" skipString
            parseComment
          ]
        ) cond
        mainResult.success stringEndFound ~ and
      ] loop
    ] if

    stringEndFound ~ [
      "expected whitespace or comment or eof" lexicalError
    ] when
  ];

  parseElementFromOpenTag: [
    recursive
    result: XMLElement;
    mainResult.success [
      skipWhiteSpaces
      parseName @result.@name set
      parseAttributes @result.@attributes set
      position.currentCodepoint ascii.slash = [
        iterateChecked
        ">" skipString
      ] [
        ">" skipString
        @result parseElementContentAndClosingTag @result.getChildren set
      ] if
    ] when

    @result
  ];

  parseElementContentAndClosingTag: [
    parentTag:;
    result: XMLValue Array;
    closingTagFound: FALSE;
    mainResult.success [
      [
        #skipWhiteSpaces
        position.currentSymbol (
          "<" [
            iterateChecked
            position.currentSymbol (
              "/" [
                parentTag.name parseClosingTag
                mainResult.success copy !closingTagFound
              ]

              "!" [
                iterateChecked
                position.currentSymbol "-" = [
                  "-" skipString
                  parseComment
                ] [
                  "Unsupported feature - PI" lexicalError
                ] if
              ]

              "?" [
                "Unsupported feature - CDSect" lexicalError
              ]

              [
                element: parseElementFromOpenTag;
                result.getSize 1 + @result.resize
                XMLVALUE_ELEMENT @result.last.setTag
                @element move XMLVALUE_ELEMENT @result.last.get set
              ]
            ) case
          ]

          "&" ["Unsupported feature - Reference" lexicalError]

          [
            data: parseCharData;
            data.size 0 > [
              result.getSize 1 + @result.resize
              XMLVALUE_CHARDATA @result.last.setTag
              @data move XMLVALUE_CHARDATA @result.last.get set
            ] when
          ]
        ) case

        mainResult.success closingTagFound ~ and
      ] loop
    ] when

    @result
  ];

  parseComment: [
    tagEnded: FALSE;
    [
      position.currentCodepoint (
        ascii.minus [
          iterateChecked
          position.currentCodepoint ascii.minus = [
            "->" skipString
            TRUE !tagEnded
          ] [
            iterateChecked
          ] if
        ]
        [
          iterateChecked
        ]
      ) case

      mainResult.success tagEnded ~ and
    ] loop
  ];

  parseCharData: [
    result: String;
    mainResult.success [
      # charData cannot contain ']]>'
      invalidSequencePrefixLength: 0;
      invalidSequenceLength: "]]>" textSize;
      hasNonWS: FALSE;
      charDataEnded: FALSE;
      [
        position.currentSymbol (
          "<" [
            TRUE !charDataEnded
          ]
          "&" [
            TRUE !charDataEnded
          ]
          "]" [
            invalidSequencePrefixLength (
              0 [1]
              1 [2]
              2 [2]
              [-1 [FALSE] "Unreachable" assert]
            ) case !invalidSequencePrefixLength
            position.currentSymbol @result.catString
            TRUE !hasNonWS
            iterateChecked
          ]
          ">" [
            invalidSequencePrefixLength 2 = [
              "CharData cannot contain ]]>" lexicalError
            ] [
              position.currentSymbol @result.catString
              TRUE !hasNonWS
              iterateChecked
            ] if
          ]
          [
            position.currentSymbol @result.catString
            position.currentCodepoint isWhiteSpace ~ [
              TRUE !hasNonWS
            ] when

            iterateChecked
          ]
        ) case
        mainResult.success charDataEnded ~ and
      ] loop

      hasNonWS ~ [
        String !result
      ] when
    ] when

    @result
  ];

  parseClosingTag: [
    parentName:;
    ("/" parentName) assembleString skipString
    skipWhiteSpaces
    ">" skipString
  ];

  parseName: [
    result: String;
    mainResult.success [
      position.currentCodepoint (
        [ascii.underline =]
        [ascii.colon =]
        @isLetter
      ) anyOf [
        position.currentSymbol @result.catString
        iterateChecked
        [
          position.currentCodepoint isNameChar [
            position.currentSymbol @result.catString
            iterateChecked
            TRUE
          ] [
            FALSE
          ] if
        ] loop
      ] [
        ("expected (Letter | '_' | ':')") assembleString lexicalError
      ] if
    ] when

    result
  ];

  parseAttributes: [
    result: XMLAttribute Array;
    mainResult.success [
      [
        skipWhiteSpaces
        position.currentSymbol "/" = ~
        [position.currentSymbol ">" = ~] && [
          attribute: parseAttribute;
          alreadyUsed: FALSE;
          result [.name attribute.name = alreadyUsed or !alreadyUsed] each
          alreadyUsed [
            ("Duplicated attribute " attribute.name) assembleString lexicalError
            FALSE
          ] [
            @attribute move @result.pushBack
            TRUE
          ] if
        ] [
          FALSE
        ] if

        mainResult.success and
      ] loop
    ] when

    @result
  ];

  parseAttribute: [
    result: XMLAttribute;
    mainResult.success [
      skipWhiteSpaces
      parseName @result.@name set
      parseEq
      parseAttValue @result.@value set
    ] when

    @result
  ];

  parseAttValue: [
    result: String;
    mainResult.success [
      position.currentSymbol (
        "\"" [
          continueLoop: TRUE;
          [
            iterateChecked
            position.currentSymbol (
              "\"" [FALSE !continueLoop iterateChecked]
              "&" ["Unsupported feature: Reference" lexicalError]
              "<" ["attrubute value cannot contain <" lexicalError]
              [position.currentSymbol @result.catString]
            ) case

            mainResult.success continueLoop and
          ] loop
        ]

        "'" [
          continueLoop: TRUE;
          [
            iterateChecked
            position.currentSymbol (
              "'" [FALSE !continueLoop iterateChecked]
              "&" ["Unsupported feature: references in attributes" lexicalError]
              "<" ["attrubute value cannot contain <" lexicalError]
              [position.currentSymbol @result.catString]
            ) case

            mainResult.success continueLoop and
          ] loop
        ]
        [("expected ' or \", found " position.currentSymbol) assembleString lexicalError]
      ) case
    ] when

    @result
  ];

  skipString: [
    string:;
    mainResult.success [
      stringSplitResult: string splitString;
      [stringSplitResult.success] "string must be valid utf-8 sequence" assert
      stringChars: stringSplitResult.chars;
      [stringChars.size 0 >] "string must not be empty" assert
      i: 0;
      [
        position.currentSymbol i stringChars.at = ~ [
          ("expected " i stringChars.at) assembleString lexicalError
        ] when

        iterateChecked
        i 1 + !i
        i stringChars.getSize < mainResult.success and
      ] loop
    ] when
  ];

  iterateChecked: [
    position.currentCodepoint ascii.null = [
      "Unexpected end of document" lexicalError
    ] when

    iterate
    position.currentCodepoint ascii.null = ~
    [position.currentCodepoint isChar ~] && [
      "invalid character" lexicalError
    ] when
  ];

  skipWhiteSpaces: [
    [position.currentCodepoint isWhiteSpace mainResult.success and] [
      iterateChecked
    ] while
  ];

  skipWhiteSpacesRequired: [
    position.currentCodepoint isWhiteSpace ~ [
      "expected whitespace" lexicalError
    ] when

    [position.currentCodepoint isWhiteSpace mainResult.success and] [
      iterateChecked
    ] while
  ];

  isChar: [CharRanges isInRanges];

  isNameChar: [
    (
      [ascii.dot =]
      [ascii.minus =]
      [ascii.underline =]
      [ascii.colon =]
      @isDigit
      @isLetter
      @isCombiningChar
      @isExtender
    ) anyOf
  ];

  isLetter: [
    (
      @isBaseChar
      @isIdeographic
    ) anyOf
  ];

  isCombiningChar: [CombiningCharRanges isInRanges];

  isBaseChar: [BaseCharRanges isInRanges];

  isDigit: [DigitRanges isInRanges];

  isExtender: [ExtenderRanges isInRanges];

  isIdeographic: [IdeographicRanges isInRanges];

  isWhiteSpace: [
    (
      [ascii.tab   =]
      [ascii.lf    =]
      [ascii.cr    =]
      [ascii.space =]
    ) anyOf
  ];

  isInRanges: [
    ranges:;
    codepoint: copy;
    # maybe change search method
    result: FALSE;
    ranges fieldCount [
      range: i ranges @;
      codepoint 0 range @ < ~
      codepoint 1 range @ > ~ and [
        ranges fieldCount !i
        TRUE !result
      ] when
    ] times

    result
  ];

  anyOf: [
    x:predicates:;;
    result: FALSE;
    predicates fieldCount [
      x i predicates @ call result or !result
    ] times

    @result
  ];

  CharRanges: ((0x9n32 0x9n32) (0xAn32 0xAn32) (0xDn32 0xDn32) (0x20n32 0xD7FFn32) (0xE000n32 0xFFFDn32) (0x10000n32 0x10FFFFn32));
  BaseCharRanges: ((0x0041n32 0x005An32) (0x0061n32 0x007An32) (0x00C0n32 0x00D6n32) (0x00D8n32 0x00F6n32) (0x00F8n32 0x00FFn32) (0x0100n32 0x0131n32) (0x0134n32 0x013En32) (0x0141n32 0x0148n32) (0x014An32 0x017En32) (0x0180n32 0x01C3n32) (0x01CDn32 0x01F0n32) (0x01F4n32 0x01F5n32) (0x01FAn32 0x0217n32) (0x0250n32 0x02A8n32) (0x02BBn32 0x02C1n32) (0x0386n32 0x0386n32) (0x0388n32 0x038An32) (0x038Cn32 0x038Cn32) (0x038En32 0x03A1n32) (0x03A3n32 0x03CEn32) (0x03D0n32 0x03D6n32) (0x03DAn32 0x03DAn32) (0x03DCn32 0x03DCn32) (0x03DEn32 0x03DEn32) (0x03E0n32 0x03E0n32) (0x03E2n32 0x03F3n32) (0x0401n32 0x040Cn32) (0x040En32 0x044Fn32) (0x0451n32 0x045Cn32) (0x045En32 0x0481n32) (0x0490n32 0x04C4n32) (0x04C7n32 0x04C8n32) (0x04CBn32 0x04CCn32) (0x04D0n32 0x04EBn32) (0x04EEn32 0x04F5n32) (0x04F8n32 0x04F9n32) (0x0531n32 0x0556n32) (0x0559n32 0x0559n32) (0x0561n32 0x0586n32) (0x05D0n32 0x05EAn32) (0x05F0n32 0x05F2n32) (0x0621n32 0x063An32) (0x0641n32 0x064An32) (0x0671n32 0x06B7n32) (0x06BAn32 0x06BEn32) (0x06C0n32 0x06CEn32) (0x06D0n32 0x06D3n32) (0x06D5n32 0x06D5n32) (0x06E5n32 0x06E6n32) (0x0905n32 0x0939n32) (0x093Dn32 0x093Dn32) (0x0958n32 0x0961n32) (0x0985n32 0x098Cn32) (0x098Fn32 0x0990n32) (0x0993n32 0x09A8n32) (0x09AAn32 0x09B0n32) (0x09B2n32 0x09B2n32) (0x09B6n32 0x09B9n32) (0x09DCn32 0x09DDn32) (0x09DFn32 0x09E1n32) (0x09F0n32 0x09F1n32) (0x0A05n32 0x0A0An32) (0x0A0Fn32 0x0A10n32) (0x0A13n32 0x0A28n32) (0x0A2An32 0x0A30n32) (0x0A32n32 0x0A33n32) (0x0A35n32 0x0A36n32) (0x0A38n32 0x0A39n32) (0x0A59n32 0x0A5Cn32) (0x0A5En32 0x0A5En32) (0x0A72n32 0x0A74n32) (0x0A85n32 0x0A8Bn32) (0x0A8Dn32 0x0A8Dn32) (0x0A8Fn32 0x0A91n32) (0x0A93n32 0x0AA8n32) (0x0AAAn32 0x0AB0n32) (0x0AB2n32 0x0AB3n32) (0x0AB5n32 0x0AB9n32) (0x0ABDn32 0x0ABDn32) (0x0AE0n32 0x0AE0n32) (0x0B05n32 0x0B0Cn32) (0x0B0Fn32 0x0B10n32) (0x0B13n32 0x0B28n32) (0x0B2An32 0x0B30n32) (0x0B32n32 0x0B33n32) (0x0B36n32 0x0B39n32) (0x0B3Dn32 0x0B3Dn32) (0x0B5Cn32 0x0B5Dn32) (0x0B5Fn32 0x0B61n32) (0x0B85n32 0x0B8An32) (0x0B8En32 0x0B90n32) (0x0B92n32 0x0B95n32) (0x0B99n32 0x0B9An32) (0x0B9Cn32 0x0B9Cn32) (0x0B9En32 0x0B9Fn32) (0x0BA3n32 0x0BA4n32) (0x0BA8n32 0x0BAAn32) (0x0BAEn32 0x0BB5n32) (0x0BB7n32 0x0BB9n32) (0x0C05n32 0x0C0Cn32) (0x0C0En32 0x0C10n32) (0x0C12n32 0x0C28n32) (0x0C2An32 0x0C33n32) (0x0C35n32 0x0C39n32) (0x0C60n32 0x0C61n32) (0x0C85n32 0x0C8Cn32) (0x0C8En32 0x0C90n32) (0x0C92n32 0x0CA8n32) (0x0CAAn32 0x0CB3n32) (0x0CB5n32 0x0CB9n32) (0x0CDEn32 0x0CDEn32) (0x0CE0n32 0x0CE1n32) (0x0D05n32 0x0D0Cn32) (0x0D0En32 0x0D10n32) (0x0D12n32 0x0D28n32) (0x0D2An32 0x0D39n32) (0x0D60n32 0x0D61n32) (0x0E01n32 0x0E2En32) (0x0E30n32 0x0E30n32) (0x0E32n32 0x0E33n32) (0x0E40n32 0x0E45n32) (0x0E81n32 0x0E82n32) (0x0E84n32 0x0E84n32) (0x0E87n32 0x0E88n32) (0x0E8An32 0x0E8An32) (0x0E8Dn32 0x0E8Dn32) (0x0E94n32 0x0E97n32) (0x0E99n32 0x0E9Fn32) (0x0EA1n32 0x0EA3n32) (0x0EA5n32 0x0EA5n32) (0x0EA7n32 0x0EA7n32) (0x0EAAn32 0x0EABn32) (0x0EADn32 0x0EAEn32) (0x0EB0n32 0x0EB0n32) (0x0EB2n32 0x0EB3n32) (0x0EBDn32 0x0EBDn32) (0x0EC0n32 0x0EC4n32) (0x0F40n32 0x0F47n32) (0x0F49n32 0x0F69n32) (0x10A0n32 0x10C5n32) (0x10D0n32 0x10F6n32) (0x1100n32 0x1100n32) (0x1102n32 0x1103n32) (0x1105n32 0x1107n32) (0x1109n32 0x1109n32) (0x110Bn32 0x110Cn32) (0x110En32 0x1112n32) (0x113Cn32 0x113Cn32) (0x113En32 0x113En32) (0x1140n32 0x1140n32) (0x114Cn32 0x114Cn32) (0x114En32 0x114En32) (0x1150n32 0x1150n32) (0x1154n32 0x1155n32) (0x1159n32 0x1159n32) (0x115Fn32 0x1161n32) (0x1163n32 0x1163n32) (0x1165n32 0x1165n32) (0x1167n32 0x1167n32) (0x1169n32 0x1169n32) (0x116Dn32 0x116En32) (0x1172n32 0x1173n32) (0x1175n32 0x1175n32) (0x119En32 0x119En32) (0x11A8n32 0x11A8n32) (0x11ABn32 0x11ABn32) (0x11AEn32 0x11AFn32) (0x11B7n32 0x11B8n32) (0x11BAn32 0x11BAn32) (0x11BCn32 0x11C2n32) (0x11EBn32 0x11EBn32) (0x11F0n32 0x11F0n32) (0x11F9n32 0x11F9n32) (0x1E00n32 0x1E9Bn32) (0x1EA0n32 0x1EF9n32) (0x1F00n32 0x1F15n32) (0x1F18n32 0x1F1Dn32) (0x1F20n32 0x1F45n32) (0x1F48n32 0x1F4Dn32) (0x1F50n32 0x1F57n32) (0x1F59n32 0x1F59n32) (0x1F5Bn32 0x1F5Bn32) (0x1F5Dn32 0x1F5Dn32) (0x1F5Fn32 0x1F7Dn32) (0x1F80n32 0x1FB4n32) (0x1FB6n32 0x1FBCn32) (0x1FBEn32 0x1FBEn32) (0x1FC2n32 0x1FC4n32) (0x1FC6n32 0x1FCCn32) (0x1FD0n32 0x1FD3n32) (0x1FD6n32 0x1FDBn32) (0x1FE0n32 0x1FECn32) (0x1FF2n32 0x1FF4n32) (0x1FF6n32 0x1FFCn32) (0x2126n32 0x2126n32) (0x212An32 0x212Bn32) (0x212En32 0x212En32) (0x2180n32 0x2182n32) (0x3041n32 0x3094n32) (0x30A1n32 0x30FAn32) (0x3105n32 0x312Cn32) (0xAC00n32 0xD7A3n32));
  IdeographicRanges: ((0x4E00n32 0x9FA5n32) (0x3007n32 0x3007n32) (0x3021n32 0x3029n32));
  CombiningCharRanges: ((0x0300n32 0x0345n32) (0x0360n32 0x0361n32) (0x0483n32 0x0486n32) (0x0591n32 0x05A1n32) (0x05A3n32 0x05B9n32) (0x05BBn32 0x05BDn32) (0x05BFn32 0x05BFn32) (0x05C1n32 0x05C2n32) (0x05C4n32 0x05C4n32) (0x064Bn32 0x0652n32) (0x0670n32 0x0670n32) (0x06D6n32 0x06DCn32) (0x06DDn32 0x06DFn32) (0x06E0n32 0x06E4n32) (0x06E7n32 0x06E8n32) (0x06EAn32 0x06EDn32) (0x0901n32 0x0903n32) (0x093Cn32 0x093Cn32) (0x093En32 0x094Cn32) (0x094Dn32 0x094Dn32) (0x0951n32 0x0954n32) (0x0962n32 0x0963n32) (0x0981n32 0x0983n32) (0x09BCn32 0x09BCn32) (0x09BEn32 0x09BEn32) (0x09BFn32 0x09BFn32) (0x09C0n32 0x09C4n32) (0x09C7n32 0x09C8n32) (0x09CBn32 0x09CDn32) (0x09D7n32 0x09D7n32) (0x09E2n32 0x09E3n32) (0x0A02n32 0x0A02n32) (0x0A3Cn32 0x0A3Cn32) (0x0A3En32 0x0A3En32) (0x0A3Fn32 0x0A3Fn32) (0x0A40n32 0x0A42n32) (0x0A47n32 0x0A48n32) (0x0A4Bn32 0x0A4Dn32) (0x0A70n32 0x0A71n32) (0x0A81n32 0x0A83n32) (0x0ABCn32 0x0ABCn32) (0x0ABEn32 0x0AC5n32) (0x0AC7n32 0x0AC9n32) (0x0ACBn32 0x0ACDn32) (0x0B01n32 0x0B03n32) (0x0B3Cn32 0x0B3Cn32) (0x0B3En32 0x0B43n32) (0x0B47n32 0x0B48n32) (0x0B4Bn32 0x0B4Dn32) (0x0B56n32 0x0B57n32) (0x0B82n32 0x0B83n32) (0x0BBEn32 0x0BC2n32) (0x0BC6n32 0x0BC8n32) (0x0BCAn32 0x0BCDn32) (0x0BD7n32 0x0BD7n32) (0x0C01n32 0x0C03n32) (0x0C3En32 0x0C44n32) (0x0C46n32 0x0C48n32) (0x0C4An32 0x0C4Dn32) (0x0C55n32 0x0C56n32) (0x0C82n32 0x0C83n32) (0x0CBEn32 0x0CC4n32) (0x0CC6n32 0x0CC8n32) (0x0CCAn32 0x0CCDn32) (0x0CD5n32 0x0CD6n32) (0x0D02n32 0x0D03n32) (0x0D3En32 0x0D43n32) (0x0D46n32 0x0D48n32) (0x0D4An32 0x0D4Dn32) (0x0D57n32 0x0D57n32) (0x0E31n32 0x0E31n32) (0x0E34n32 0x0E3An32) (0x0E47n32 0x0E4En32) (0x0EB1n32 0x0EB1n32) (0x0EB4n32 0x0EB9n32) (0x0EBBn32 0x0EBCn32) (0x0EC8n32 0x0ECDn32) (0x0F18n32 0x0F19n32) (0x0F35n32 0x0F35n32) (0x0F37n32 0x0F37n32) (0x0F39n32 0x0F39n32) (0x0F3En32 0x0F3En32) (0x0F3Fn32 0x0F3Fn32) (0x0F71n32 0x0F84n32) (0x0F86n32 0x0F8Bn32) (0x0F90n32 0x0F95n32) (0x0F97n32 0x0F97n32) (0x0F99n32 0x0FADn32) (0x0FB1n32 0x0FB7n32) (0x0FB9n32 0x0FB9n32) (0x20D0n32 0x20DCn32) (0x20E1n32 0x20E1n32) (0x302An32 0x302Fn32) (0x3099n32 0x3099n32) (0x309An32 0x309An32));
  DigitRanges: ((0x0030n32 0x0039n32) (0x0660n32 0x0669n32) (0x06F0n32 0x06F9n32) (0x0966n32 0x096Fn32) (0x09E6n32 0x09EFn32) (0x0A66n32 0x0A6Fn32) (0x0AE6n32 0x0AEFn32) (0x0B66n32 0x0B6Fn32) (0x0BE7n32 0x0BEFn32) (0x0C66n32 0x0C6Fn32) (0x0CE6n32 0x0CEFn32) (0x0D66n32 0x0D6Fn32) (0x0E50n32 0x0E59n32) (0x0ED0n32 0x0ED9n32) (0x0F20n32 0x0F29n32));
  ExtenderRanges: ((0x00B7n32 0x00B7n32) (0x02D0n32 0x02D0n32) (0x02D1n32 0x02D1n32) (0x0387n32 0x0387n32) (0x0640n32 0x0640n32) (0x0E46n32 0x0E46n32) (0x0EC6n32 0x0EC6n32) (0x3005n32 0x3005n32) (0x3031n32 0x3035n32) (0x309Dn32 0x309En32) (0x30FCn32 0x30FEn32));
};

{
  position: XMLParserPosition Ref;
  chars: StringView Array Cref;
  mainResult: XMLParserResult Ref;
  xml: XMLDocument Ref;
} () {convention: cdecl;} [
  position:;
  chars:;
  mainResult:;
  xml:;

  chars @position xmlInternal.fillPositionChars
  xmlInternal.parseDocument @xml set
  position.offset chars.getSize < [
    FALSE @mainResult.@finished set
    position @mainResult.@errorInfo.@position set
  ] when
] "parseStringToXMLImpl" exportFunction
