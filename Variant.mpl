# Copyright (C) 2022 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.="    use
"control.="      use
"control.Int32"  use
"control.Ref"    use
"control.assert" use
"control.pfunc"  use
"control.swap"   use
"control.when"   use

Variant: [{
  virtual VARIANT: ();

  virtual typeList: Ref;

  virtual maxSize: [
    result: 1 static;
    i: 0 static;
    [
      i typeList fieldCount < [
        curSize: i @typeList @ storageSize Int32 cast;
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
      i @typeList fieldCount < [
        curSize: i @typeList @ alignment Int32 cast;
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

  typeTag: 0;

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

  getTag: [typeTag new];

  setTag: [
    index: new;
    index typeTag = ~ [
      rawDestroy
      index @typeTag set
      rawInit
    ] when
  ];

  getUnchecked: [memory storageAddress swap @typeList @ addressToReference];

  get: [
    index: new;
    [index typeTag =] "Wrong tag in Tagged Union!" assert
    index getUnchecked
  ];

  assign: [
    index:;
    index setTag
    index get set
  ];

  visitInternal: [
    visitBranches: visitIndex:;;
    visitIndex visitBranches fieldCount = [] [
      visitIndex visitBranches fieldCount 1 - = [visitIndex visitBranches @ call] [
        visitIndex visitBranches @ typeTag = [visitIndex visitBranches @ get visitIndex 1 + visitBranches @ call] [
          visitBranches visitIndex 2 + visitInternal
        ] if
      ] uif
    ] uif
  ];

  visit: [0 visitInternal];

  # Loop is kept to allow equality check of dynamic Variants
  equal: [
    other:;
    typeList other.typeList same ~ ["Variants' supported types differ" raiseStaticError] when
    result: FALSE;
    typeTag other.typeTag = [
      i: 0 static;
      [
        i typeTag = [i getUnchecked i other.getUnchecked = !result] when
        i 1 + !i
        i typeList fieldCount <
      ] loop
    ] when
    result
  ];

  INIT: [
    0 @typeTag set
    rawInit
  ];

  ASSIGN: [
    other:;
    other.typeTag setTag

    i: 0 static;
    [
      i @typeList fieldCount < [
        i typeTag = [
          i other.getUnchecked
          i getUnchecked set
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
    i arg.@typeList fieldCount < [
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
