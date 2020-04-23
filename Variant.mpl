"control.assert" use
"control.pfunc" use
"control.when" use

Variant: [{
  virtual VARIANT: ();

  schema typeList:;

  virtual maxSize: [
    result: 1 static;
    i: 0 static;
    [
      i typeList fieldCount < [
        curSize: i typeList @ storageSize 0ix cast 0 cast;
        curSize result > [
          curSize @result set
        ] when

        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
    result
  ] call;

  virtual maxAlignment: [
    result: 1 static;
    i: 0 static;
    [
      i typeList fieldCount < [
        curSize: i typeList @ alignment 0ix cast 0 cast;
        curSize result > [
          curSize @result set
        ] when

        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
    result
  ] call;

  typeTag: 0 dynamic;

  memory: [
    maxAlignment 1 static = [0n8 dynamic] [
      maxAlignment 2 static = [0n16 dynamic] [
        maxAlignment 4 static = [0n32 dynamic] [
          maxAlignment 8 static = [0n64 dynamic] [
            ().ALIGNMENT_HAS_INCORRECT_VALUE
          ] if
        ] if
      ] if
    ] if
  ] call;

  filler: 0n8 maxSize maxAlignment - array dynamic;

  rawInit: [
    i: 0 static;
    fc: typeList fieldCount;
    [
      i fc < [
        i typeTag = [
          i get manuallyInitVariable
        ] when
        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
  ];

  rawDestroy: [
    i: 0 static;
    [
      i typeList fieldCount < [
        i typeTag = [
          i get manuallyDestroyVariable
        ] when
        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
  ];

  getTag: [typeTag copy];

  setTag: [
    index: copy dynamic;
    index typeTag = ~ [
      rawDestroy
      index @typeTag set
      rawInit
    ] when
  ];

  get: [
    index: copy;
    [index typeTag =] "Wrong tag in Tagged Union!" assert
    @memory storageAddress index @typeList @ addressToReference
  ];

  visitInternal: [
    visitBranches: visitIndex:;;
    visitIndex visitBranches fieldCount = [] [
      visitIndex visitBranches fieldCount 1 - = [visitIndex visitBranches @ ucall] [
        visitIndex visitBranches @ typeTag = [visitIndex visitBranches @ get visitIndex 1 + visitBranches @ ucall] [
          visitBranches visitIndex 2 + visitInternal
        ] if
      ] uif
    ] uif
  ];

  visit: [0 visitInternal];

  INIT: [
    0 @typeTag set
    rawInit
  ];

  ASSIGN: [
    other:;
    other.typeTag setTag

    i: 0 static;
    [
      i typeList fieldCount < [
        i typeTag = [
          i other.get
          i get set
        ] when
        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
  ];

  DIE: [
    rawDestroy
  ];
}
result:;
@result manuallyInitVariable
@result
];

getHeapUsedSize: ["VARIANT" has] [
  arg:;
  i: 0 static;
  result: 0nx;
  [
    i arg.typeList fieldCount < [
      i arg.typeTag = [
        result i arg.get getHeapUsedSize + @result set
      ] when
      i 1 + @i set
      TRUE static
    ] [
      FALSE static
    ] if
  ] loop
  result
] pfunc;
