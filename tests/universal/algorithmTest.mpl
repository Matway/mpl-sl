# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"             use
"control.Cref"           use
"control.Int32"          use
"control.Nat8"           use
"control.Natx"           use
"control.Real64"         use
"control.Ref"            use
"control.drop"           use
"control.dup"            use
"control.ensure"         use
"control.int?"           use
"control.isBuiltinTuple" use
"control.pfunc"          use
"control.sign"           use
"control.times"          use
"control.when"           use
"control.||"             use

"algorithm" use

algorithmTest: [];

check: [
  value0: ref0?: value1: ref1?: dynamic?:;;;;;
  [@value0 isDirty [@value0 isDynamic] || dynamic? =] "different dynamic status" ensure
  [ref0? ref1? =] "different reference status" ensure
  ref1? [
    [@value0 isConst @value1 isConst =] "different writable status" ensure
    [@value0 @value1 is] "different references" ensure
  ] [
    [@value0 @value1 =] "different values" ensure
  ] if
];

testIndex: [
  index: dynamicValues?: dynamicSize?: tuple: offset: size:;;;;;;
  index.size isRef size FALSE dynamicSize? check
  size [
    i  index.at isRef offset i +  tuple @ TRUE dynamicValues? check
    i @index.at isRef offset i + @tuple @ TRUE dynamicValues? check
  ] times
];

testIter: [
  iter: refValues?: dynamicValues?: sized?: dynamicSize?: infinite?: tuple: offset: size:;;;;;;;;;
  iter "size" has isRef sized? FALSE FALSE check
  size [
    sized? [iter.size isRef size i - FALSE dynamicSize? check] when
    @iter.next
    isRef TRUE FALSE dynamicSize? check
    isRef offset i + @tuple @ refValues? dynamicValues? check
  ] times

  sized? [iter.size isRef 0 FALSE dynamicSize? check] when
  @iter.next isRef infinite? FALSE dynamicSize? check drop
];

testView: [
  view: dynamicValues?: dynamicSize?: indexable?: tuple: offset: size:;;;;;;;
  testView: [
    view: offset: size:;;;
    view "index" has isRef indexable? FALSE FALSE check
    indexable? [@view.index dynamicValues? dynamicSize? @tuple offset size testIndex] when
    @view.iter TRUE dynamicValues? TRUE dynamicSize? FALSE @tuple offset size testIter
    view.size isRef size FALSE dynamicSize? check
  ];

  @view offset size testView
  size 1 + [
    newSize: i;
    size newSize - 1 + [
      i newSize view.size isDynamic [new dynamic] when @view.slice offset i + newSize testView
    ] times
  ] times
];

# isIndex
[
  {                 } isIndex isRef FALSE isRef FALSE check
  {at: [];          } isIndex isRef FALSE isRef FALSE check
  {        size: [];} isIndex isRef FALSE isRef FALSE check
  {at: []; size: [];} isIndex isRef TRUE  isRef FALSE check
] call

# isIter
[
  {         } isIter isRef FALSE isRef FALSE check
  {next: [];} isIter isRef TRUE  isRef FALSE check
] call

# isView
[
  {                              } isView isRef FALSE isRef FALSE check
  {iter: [];                     } isView isRef FALSE isRef FALSE check
  {          size: [];           } isView isRef FALSE isRef FALSE check
  {iter: []; size: [];           } isView isRef FALSE isRef FALSE check
  {                    slice: [];} isView isRef FALSE isRef FALSE check
  {iter: [];           slice: [];} isView isRef FALSE isRef FALSE check
  {          size: []; slice: [];} isView isRef FALSE isRef FALSE check
  {iter: []; size: []; slice: [];} isView isRef TRUE  isRef FALSE check
] call

# makeArrayIndex
[
  tuple: (2 3 5 7 11 13 17 19);
  tuple fieldCount 1 + [
    0 @tuple @ i             makeArrayIndex TRUE FALSE @tuple 0 i testIndex
    0 @tuple @ i new dynamic makeArrayIndex TRUE TRUE  @tuple 0 i testIndex
  ] times
] call

# makeArrayIter
[
  tuple: (2 3 5 7 11 13 17 19);
  tuple fieldCount 1 + [
    0 @tuple @ i             makeArrayIter TRUE TRUE TRUE FALSE FALSE @tuple 0 i testIter
    0 @tuple @ i new dynamic makeArrayIter TRUE TRUE TRUE TRUE  FALSE @tuple 0 i testIter
  ] times
] call

# makeArrayView
[
  tuple: (2 3 5 7 11 13 17 19);
  tuple fieldCount 1 + [
    0 @tuple @ i             makeArrayView TRUE FALSE TRUE @tuple 0 i testView
    0 @tuple @ i new dynamic makeArrayView TRUE TRUE  TRUE @tuple 0 i testView
  ] times
] call

# toTextIter
[
  tuple: (2n8 3n8 5n8 7n8 11n8 13n8 17n8 19n8);
  tuple fieldCount 1 + [
    (0 @tuple @ i            ) toTextIter TRUE TRUE TRUE FALSE FALSE @tuple 0 i testIter
    (0 @tuple @ i new dynamic) toTextIter TRUE TRUE TRUE TRUE  FALSE @tuple 0 i testIter
  ] times
] call

# toTextView
[
  tuple: (2n8 3n8 5n8 7n8 11n8 13n8 17n8 19n8);
  tuple fieldCount 1 + [
    (0 @tuple @ i            ) toTextView TRUE FALSE FALSE @tuple 0 i testView
    (0 @tuple @ i new dynamic) toTextView TRUE TRUE  FALSE @tuple 0 i testView
  ] times
] call

# makeTupleIndex
[
  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    size: i;
    tuple0 fieldCount size - 1 + [
      @tuple0 i             size             makeTupleIndex FALSE FALSE @tuple0 i size testIndex
      @tuple1 i new dynamic size             makeTupleIndex TRUE  FALSE @tuple1 i size testIndex
      @tuple0 i             size new dynamic makeTupleIndex FALSE TRUE  @tuple0 i size testIndex
      @tuple1 i new dynamic size new dynamic makeTupleIndex TRUE  TRUE  @tuple1 i size testIndex
      @tuple2 i             size             makeTupleIndex FALSE FALSE @tuple2 i size testIndex
      @tuple2 i             size new dynamic makeTupleIndex FALSE TRUE  @tuple2 i size testIndex
    ] times
  ] times
] call

# makeTupleIter
[
  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    size: i;
    tuple0 fieldCount size - 1 + [
      @tuple0 i             size             makeTupleIter TRUE FALSE TRUE FALSE FALSE @tuple0 i size testIter
      @tuple1 i new dynamic size             makeTupleIter TRUE TRUE  TRUE FALSE FALSE @tuple1 i size testIter
      @tuple0 i             size new dynamic makeTupleIter TRUE FALSE TRUE TRUE  FALSE @tuple0 i size testIter
      @tuple1 i new dynamic size new dynamic makeTupleIter TRUE TRUE  TRUE TRUE  FALSE @tuple1 i size testIter
      @tuple2 i             size             makeTupleIter TRUE FALSE TRUE FALSE FALSE @tuple2 i size testIter
      @tuple2 i             size new dynamic makeTupleIter TRUE FALSE TRUE TRUE  FALSE @tuple2 i size testIter
    ] times
  ] times
] call

# makeTupleView
[
  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    size: i;
    tuple0 fieldCount size - 1 + [
      @tuple0 i             size             makeTupleView FALSE FALSE TRUE @tuple0 i size testView
      @tuple1 i new dynamic size             makeTupleView TRUE  FALSE TRUE @tuple1 i size testView
      @tuple0 i             size new dynamic makeTupleView FALSE TRUE  TRUE @tuple0 i size testView
      @tuple1 i new dynamic size new dynamic makeTupleView TRUE  TRUE  TRUE @tuple1 i size testView
      @tuple2 i             size             makeTupleView FALSE FALSE TRUE @tuple2 i size testView
      @tuple2 i             size new dynamic makeTupleView FALSE TRUE  TRUE @tuple2 i size testView
    ] times
  ] times
] call

# toIndex
[
  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  @tuple toIndex FALSE FALSE @tuple 0 tuple fieldCount testIndex

  makeIndex: [
    hasDie:;
    {
      tuple: @tuple;
      count: 0;
      hasDie [DIE: [];] [] uif
      at: [@self isConst ~ [count 1 + !count] when @tuple @];
      size: [tuple fieldCount];
    }
  ];

  index0: FALSE makeIndex;
  @index0 toIndex FALSE FALSE @tuple 0 tuple fieldCount testIndex
  index0.count new isRef 0 FALSE FALSE check

  index1: TRUE makeIndex;
  @index1 toIndex FALSE FALSE @tuple 0 tuple fieldCount testIndex
  index1.count new isRef tuple fieldCount FALSE FALSE check

  {index: [@index0];} toIndex FALSE FALSE @tuple 0 tuple fieldCount testIndex
  index0.count new isRef tuple fieldCount FALSE FALSE check
] call

# toIter
[
  text: "BCEGKMQS";
  text toIter TRUE TRUE TRUE FALSE FALSE (text textSize Int32 cast [text storageAddress i Natx cast + Nat8 Cref addressToReference] times) 0 text textSize Int32 cast testIter

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  @tuple toIter TRUE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter

  makeIter: [
    hasDie:;
    {
      tuple: @tuple;
      offset: 0;

      hasDie [DIE: [];] [] uif

      next: [
        offset tuple fieldCount = [() FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];
    }
  ];

  iter0: FALSE makeIter;
  @iter0 toIter TRUE FALSE FALSE FALSE FALSE @tuple 0 tuple fieldCount testIter
  iter0.offset new isRef 0 FALSE FALSE check

  iter1: TRUE makeIter;
  @iter1 toIter TRUE FALSE FALSE FALSE FALSE @tuple 0 tuple fieldCount testIter
  iter1.offset new isRef tuple fieldCount FALSE FALSE check

  {iter: [@iter0];} toIter TRUE FALSE FALSE FALSE FALSE @tuple 0 tuple fieldCount testIter
  iter0.offset new isRef tuple fieldCount FALSE FALSE check
] call

# toView
[
  text: "BCEGKMQS";
  text toView TRUE FALSE FALSE (text textSize Int32 cast [text storageAddress i Natx cast + Nat8 Cref addressToReference] times) 0 text textSize Int32 cast testView

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  @tuple toView FALSE FALSE TRUE @tuple 0 tuple fieldCount testView

  makeView: [
    offset: size: hasDie:;;;
    {
      tuple: @tuple;
      viewOffset: virtual offset new;
      viewSize: virtual size new;
      count: 0;

      hasDie [DIE: [];] [] uif

      iter: [
        count 1 + !count

        {
          tuple: @tuple;
          offset0: viewOffset;
          offset1: virtual offset0 viewSize +;

          next: [
            offset0 offset1 = [() FALSE] [
              offset0 @tuple @
              offset0 1 + !offset0
              TRUE
            ] if
          ];

          size: [offset1 offset0 -];
        }
      ];

      size: [viewSize];

      slice: [
        offset: size:;;
        @self isConst ~ [count 1 + !count] when
        viewOffset offset + size self "DIE" has makeView
      ];
    }
  ];

  view0: 0 tuple fieldCount FALSE makeView;
  @view0 toView FALSE FALSE FALSE @tuple 0 tuple fieldCount testView
  view0.count new isRef 0 FALSE FALSE check

  view1: 0 tuple fieldCount TRUE makeView;
  @view1 toView FALSE FALSE FALSE @tuple 0 tuple fieldCount testView
  view1.count new isRef tuple fieldCount 1 + dup 1 + * 2 / 1 + FALSE FALSE check
] call

# objectFields
[
  =: [pair0: pair1:;; pair0 "key" has [pair1 "key" has] &&] [
    pair0: pair1:;;
    pair0.key pair1.key = [@pair0.@value isConst @pair1.@value isConst = [pair0.value pair1.value is] &&] &&
  ] pfunc;

  fields: {} objectFields;
  tuple: ();
  @fields FALSE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter

  object: {a: 5; b: "name";};
  fields: @object objectFields;
  tuple: ({key: "a"; value: @object.@a;} {key: "b"; value: @object.@b;});
  @fields FALSE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter
] call

# objectKeys
[
  keys: {} objectKeys;
  tuple: ();
  @keys TRUE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter

  object: {a: 5; b: "name";};
  keys: @object objectKeys;
  tuple: ("a" "b");
  @keys TRUE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter
] call

# objectValues
[
  values: {} objectValues;
  tuple: ();
  @values TRUE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter

  object: {a: 5; b: "name";};
  values: @object objectValues;
  tuple: (@object.@a @object.@b);
  @values TRUE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter
] call

# <
[
  ""    ""   < isRef FALSE FALSE FALSE check
  "0"   ""   < isRef FALSE FALSE FALSE check

  ""    "0"  < isRef TRUE  FALSE FALSE check
  "0"   "0"  < isRef FALSE FALSE TRUE  check
  "1"   "0"  < isRef FALSE FALSE TRUE  check
  "00"  "0"  < isRef FALSE FALSE TRUE  check
  "10"  "0"  < isRef FALSE FALSE TRUE  check
  "01"  "0"  < isRef FALSE FALSE TRUE  check
  "11"  "0"  < isRef FALSE FALSE TRUE  check

  "0"   "00" < isRef TRUE  FALSE TRUE  check
  "1"   "00" < isRef FALSE FALSE TRUE  check
  "00"  "00" < isRef FALSE FALSE TRUE  check
  "10"  "00" < isRef FALSE FALSE TRUE  check
  "01"  "00" < isRef FALSE FALSE TRUE  check
  "11"  "00" < isRef FALSE FALSE TRUE  check
  "000" "00" < isRef FALSE FALSE TRUE  check
  "100" "00" < isRef FALSE FALSE TRUE  check
  "010" "00" < isRef FALSE FALSE TRUE  check
  "110" "00" < isRef FALSE FALSE TRUE  check
  "001" "00" < isRef FALSE FALSE TRUE  check
  "101" "00" < isRef FALSE FALSE TRUE  check
  "011" "00" < isRef FALSE FALSE TRUE  check
  "111" "00" < isRef FALSE FALSE TRUE  check

  "0"   "10" < isRef TRUE  FALSE TRUE  check
  "1"   "10" < isRef TRUE  FALSE TRUE  check
  "00"  "10" < isRef TRUE  FALSE TRUE  check
  "10"  "10" < isRef FALSE FALSE TRUE  check
  "01"  "10" < isRef TRUE  FALSE TRUE  check
  "11"  "10" < isRef FALSE FALSE TRUE  check
  "000" "10" < isRef TRUE  FALSE TRUE  check
  "100" "10" < isRef FALSE FALSE TRUE  check
  "010" "10" < isRef TRUE  FALSE TRUE  check
  "110" "10" < isRef FALSE FALSE TRUE  check
  "001" "10" < isRef TRUE  FALSE TRUE  check
  "101" "10" < isRef FALSE FALSE TRUE  check
  "011" "10" < isRef TRUE  FALSE TRUE  check
  "111" "10" < isRef FALSE FALSE TRUE  check
] call

# =
[
  (     ) (   ) = isRef TRUE  FALSE FALSE check
  (0    ) (   ) = isRef FALSE FALSE FALSE check

  (     ) (0  ) = isRef FALSE FALSE FALSE check
  (0    ) (0  ) = isRef TRUE  FALSE FALSE check
  (1    ) (0  ) = isRef FALSE FALSE FALSE check
  (0 0  ) (0  ) = isRef FALSE FALSE FALSE check
  (1 0  ) (0  ) = isRef FALSE FALSE FALSE check
  (0 1  ) (0  ) = isRef FALSE FALSE FALSE check
  (1 1  ) (0  ) = isRef FALSE FALSE FALSE check

  (0    ) (0 0) = isRef FALSE FALSE FALSE check
  (1    ) (0 0) = isRef FALSE FALSE FALSE check
  (0 0  ) (0 0) = isRef TRUE  FALSE FALSE check
  (1 0  ) (0 0) = isRef FALSE FALSE FALSE check
  (0 1  ) (0 0) = isRef FALSE FALSE FALSE check
  (1 1  ) (0 0) = isRef FALSE FALSE FALSE check
  (0 0 0) (0 0) = isRef FALSE FALSE FALSE check
  (1 0 0) (0 0) = isRef FALSE FALSE FALSE check
  (0 1 0) (0 0) = isRef FALSE FALSE FALSE check
  (1 1 0) (0 0) = isRef FALSE FALSE FALSE check
  (0 0 1) (0 0) = isRef FALSE FALSE FALSE check
  (1 0 1) (0 0) = isRef FALSE FALSE FALSE check
  (0 1 1) (0 0) = isRef FALSE FALSE FALSE check
  (1 1 1) (0 0) = isRef FALSE FALSE FALSE check

  (0    ) (1 0) = isRef FALSE FALSE FALSE check
  (1    ) (1 0) = isRef FALSE FALSE FALSE check
  (0 0  ) (1 0) = isRef FALSE FALSE FALSE check
  (1 0  ) (1 0) = isRef TRUE  FALSE FALSE check
  (0 1  ) (1 0) = isRef FALSE FALSE FALSE check
  (1 1  ) (1 0) = isRef FALSE FALSE FALSE check
  (0 0 0) (1 0) = isRef FALSE FALSE FALSE check
  (1 0 0) (1 0) = isRef FALSE FALSE FALSE check
  (0 1 0) (1 0) = isRef FALSE FALSE FALSE check
  (1 1 0) (1 0) = isRef FALSE FALSE FALSE check
  (0 0 1) (1 0) = isRef FALSE FALSE FALSE check
  (1 0 1) (1 0) = isRef FALSE FALSE FALSE check
  (0 1 1) (1 0) = isRef FALSE FALSE FALSE check
  (1 1 1) (1 0) = isRef FALSE FALSE FALSE check
] call

# >
[
  ""    ""   > isRef FALSE FALSE FALSE check
  "0"   ""   > isRef TRUE  FALSE FALSE check

  ""    "0"  > isRef FALSE FALSE FALSE check
  "0"   "0"  > isRef FALSE FALSE TRUE  check
  "1"   "0"  > isRef TRUE  FALSE TRUE  check
  "00"  "0"  > isRef TRUE  FALSE TRUE  check
  "10"  "0"  > isRef TRUE  FALSE TRUE  check
  "01"  "0"  > isRef TRUE  FALSE TRUE  check
  "11"  "0"  > isRef TRUE  FALSE TRUE  check

  "0"   "00" > isRef FALSE FALSE TRUE  check
  "1"   "00" > isRef TRUE  FALSE TRUE  check
  "00"  "00" > isRef FALSE FALSE TRUE  check
  "10"  "00" > isRef TRUE  FALSE TRUE  check
  "01"  "00" > isRef TRUE  FALSE TRUE  check
  "11"  "00" > isRef TRUE  FALSE TRUE  check
  "000" "00" > isRef TRUE  FALSE TRUE  check
  "100" "00" > isRef TRUE  FALSE TRUE  check
  "010" "00" > isRef TRUE  FALSE TRUE  check
  "110" "00" > isRef TRUE  FALSE TRUE  check
  "001" "00" > isRef TRUE  FALSE TRUE  check
  "101" "00" > isRef TRUE  FALSE TRUE  check
  "011" "00" > isRef TRUE  FALSE TRUE  check
  "111" "00" > isRef TRUE  FALSE TRUE  check

  "0"   "10" > isRef FALSE FALSE TRUE  check
  "1"   "10" > isRef FALSE FALSE TRUE  check
  "00"  "10" > isRef FALSE FALSE TRUE  check
  "10"  "10" > isRef FALSE FALSE TRUE  check
  "01"  "10" > isRef FALSE FALSE TRUE  check
  "11"  "10" > isRef TRUE  FALSE TRUE  check
  "000" "10" > isRef FALSE FALSE TRUE  check
  "100" "10" > isRef TRUE  FALSE TRUE  check
  "010" "10" > isRef FALSE FALSE TRUE  check
  "110" "10" > isRef TRUE  FALSE TRUE  check
  "001" "10" > isRef FALSE FALSE TRUE  check
  "101" "10" > isRef TRUE  FALSE TRUE  check
  "011" "10" > isRef FALSE FALSE TRUE  check
  "111" "10" > isRef TRUE  FALSE TRUE  check
] call

# beginsWith
[
  ""    ""   beginsWith isRef TRUE  FALSE FALSE check
  "0"   ""   beginsWith isRef TRUE  FALSE FALSE check

  ""    "0"  beginsWith isRef FALSE FALSE FALSE check
  "0"   "0"  beginsWith isRef TRUE  FALSE TRUE  check
  "1"   "0"  beginsWith isRef FALSE FALSE TRUE  check
  "00"  "0"  beginsWith isRef TRUE  FALSE TRUE  check
  "10"  "0"  beginsWith isRef FALSE FALSE TRUE  check
  "01"  "0"  beginsWith isRef TRUE  FALSE TRUE  check
  "11"  "0"  beginsWith isRef FALSE FALSE TRUE  check

  "0"   "00" beginsWith isRef FALSE FALSE FALSE check
  "1"   "00" beginsWith isRef FALSE FALSE FALSE check
  "00"  "00" beginsWith isRef TRUE  FALSE TRUE  check
  "10"  "00" beginsWith isRef FALSE FALSE TRUE  check
  "01"  "00" beginsWith isRef FALSE FALSE TRUE  check
  "11"  "00" beginsWith isRef FALSE FALSE TRUE  check
  "000" "00" beginsWith isRef TRUE  FALSE TRUE  check
  "100" "00" beginsWith isRef FALSE FALSE TRUE  check
  "010" "00" beginsWith isRef FALSE FALSE TRUE  check
  "110" "00" beginsWith isRef FALSE FALSE TRUE  check
  "001" "00" beginsWith isRef TRUE  FALSE TRUE  check
  "101" "00" beginsWith isRef FALSE FALSE TRUE  check
  "011" "00" beginsWith isRef FALSE FALSE TRUE  check
  "111" "00" beginsWith isRef FALSE FALSE TRUE  check

  "0"   "10" beginsWith isRef FALSE FALSE FALSE check
  "1"   "10" beginsWith isRef FALSE FALSE FALSE check
  "00"  "10" beginsWith isRef FALSE FALSE TRUE  check
  "10"  "10" beginsWith isRef TRUE  FALSE TRUE  check
  "01"  "10" beginsWith isRef FALSE FALSE TRUE  check
  "11"  "10" beginsWith isRef FALSE FALSE TRUE  check
  "000" "10" beginsWith isRef FALSE FALSE TRUE  check
  "100" "10" beginsWith isRef TRUE  FALSE TRUE  check
  "010" "10" beginsWith isRef FALSE FALSE TRUE  check
  "110" "10" beginsWith isRef FALSE FALSE TRUE  check
  "001" "10" beginsWith isRef FALSE FALSE TRUE  check
  "101" "10" beginsWith isRef TRUE  FALSE TRUE  check
  "011" "10" beginsWith isRef FALSE FALSE TRUE  check
  "111" "10" beginsWith isRef FALSE FALSE TRUE  check
] call

# compareBy
[
  Comparator: [{
    comparator: upperBound: new virtual; virtual;
    invocationCount: 0;

    CALL: [
      value0: value1:;;
      [invocationCount 0 < ~] "arithmetic overflow" ensure
      invocationCount 1 + !invocationCount
      [invocationCount upperBound > ~] "extra attempt to invoke comparator" ensure

      @value0 @value1 comparator
    ];
  }];

  OnlyOnce: [{
    body: virtual;
    valid: TRUE;

    CALL: [
      [valid] "attempted to apply function twice" ensure
      FALSE !valid

      body
    ];
  }];

  compareNormalized: [
    iter0: iter1: comparator: Diff:;;;;
    diff: ref?: @iter0 @iter1 @comparator @Diff compareBy isRef;;
    [diff int?] "not an Int" ensure

    diff sign diff cast ref?
  ];

  test: [
    transform0: transform1:;;

    transform2: [
      iter0: iter1:;;
      @iter0 transform0 @iter1 transform1
    ];

    # 0)
    # THE TRANSITION: Remove ['] from function's name. See the next item
    testCompareBy': [
      iter0: iter1: comparator: upperBound: Diff: normalizedResult:;;;;;;
      @iter0 @iter1 @comparator upperBound Comparator @Diff OnlyOnce compareNormalized normalizedResult FALSE FALSE check
    ];

    # 1)
    # THE TRANSITION: Remove this version of the function. Without this version test cases are unable to pass assertions
    testCompareBy: [
      iter0: iter1: comparator: upperBound: Diff: normalizedResult:;;;;;;
      @iter0 dynamic @iter1 dynamic @comparator upperBound Comparator @Diff OnlyOnce compareNormalized normalizedResult FALSE TRUE check
    ];

    # 2)
    # THE TRANSITION: Turn on this block
    #(     ) (     ) transform2 [] 0 @Int32  0 testCompareBy
    #(     ) (0    ) transform2 [] 0 @Int32 -1 testCompareBy
    #(     ) (0 0  ) transform2 [] 0 @Int32 -1 testCompareBy
    #(     ) (0 0 0) transform2 [] 0 @Int32 -1 testCompareBy
    #(0    ) (     ) transform2 [] 0 @Int32  1 testCompareBy
    #(0 0  ) (     ) transform2 [] 0 @Int32  1 testCompareBy
    #(0 0 0) (     ) transform2 [] 0 @Int32  1 testCompareBy

    # 3)
    # THE TRANSITION: Remove this block
    (     ) (     ) transform2 [] 0 @Int32  0 testCompareBy'
    (     ) (0    ) transform2 [] 0 @Int32 -1 testCompareBy'
    (     ) (0 0  ) transform2 [] 0 @Int32 -1 testCompareBy'
    (     ) (0 0 0) transform2 [] 0 @Int32 -1 testCompareBy'
    (0    ) (     ) transform2 [] 0 @Int32  1 testCompareBy'
    (0 0  ) (     ) transform2 [] 0 @Int32  1 testCompareBy'
    (0 0 0) (     ) transform2 [] 0 @Int32  1 testCompareBy'

    (0      ) (0      ) transform2 [-] 1 @Int32  0 testCompareBy
    (0 0    ) (0 0    ) transform2 [-] 2 @Int32  0 testCompareBy
    (0 0 0  ) (0 0 0  ) transform2 [-] 3 @Int32  0 testCompareBy
    (0      ) (0 0    ) transform2 [-] 1 @Int32 -1 testCompareBy
    (0 0    ) (0 0 0  ) transform2 [-] 2 @Int32 -1 testCompareBy
    (0 0 0  ) (0 0 0 0) transform2 [-] 3 @Int32 -1 testCompareBy
    (0 0    ) (0      ) transform2 [-] 1 @Int32  1 testCompareBy
    (0 0 0  ) (0 0    ) transform2 [-] 2 @Int32  1 testCompareBy
    (0 0 0 0) (0 0 0  ) transform2 [-] 3 @Int32  1 testCompareBy

    (0      ) (1 0    ) transform2 [-] 1 @Int32 -1 testCompareBy
    (0 0    ) (0 1 0  ) transform2 [-] 2 @Int32 -1 testCompareBy
    (0 0 0  ) (0 0 1 0) transform2 [-] 3 @Int32 -1 testCompareBy
    (1      ) (0 0    ) transform2 [-] 1 @Int32  1 testCompareBy
    (0 1    ) (0 0 0  ) transform2 [-] 2 @Int32  1 testCompareBy
    (0 0 1  ) (0 0 0 0) transform2 [-] 3 @Int32  1 testCompareBy
    (0 0    ) (1      ) transform2 [-] 1 @Int32 -1 testCompareBy
    (0 0 0  ) (0 1    ) transform2 [-] 2 @Int32 -1 testCompareBy
    (0 0 0 0) (0 0 1  ) transform2 [-] 3 @Int32 -1 testCompareBy
    (1 0    ) (0      ) transform2 [-] 1 @Int32  1 testCompareBy
    (0 1 0  ) (0 0    ) transform2 [-] 2 @Int32  1 testCompareBy
    (0 0 1 0) (0 0 0  ) transform2 [-] 3 @Int32  1 testCompareBy

    (0    ) (1    ) transform2 [-] 1 @Int32 -1 testCompareBy
    (1    ) (0    ) transform2 [-] 1 @Int32  1 testCompareBy
    (0 0  ) (1 0  ) transform2 [-] 1 @Int32 -1 testCompareBy
    (0 0  ) (0 1  ) transform2 [-] 2 @Int32 -1 testCompareBy
    (1 0  ) (0 0  ) transform2 [-] 1 @Int32  1 testCompareBy
    (0 1  ) (0 0  ) transform2 [-] 2 @Int32  1 testCompareBy
    (0 0 0) (1 0 0) transform2 [-] 1 @Int32 -1 testCompareBy
    (0 0 0) (0 1 0) transform2 [-] 2 @Int32 -1 testCompareBy
    (0 0 0) (0 0 1) transform2 [-] 3 @Int32 -1 testCompareBy
    (1 0 0) (0 0 0) transform2 [-] 1 @Int32  1 testCompareBy
    (0 1 0) (0 0 0) transform2 [-] 2 @Int32  1 testCompareBy
    (0 0 1) (0 0 0) transform2 [-] 3 @Int32  1 testCompareBy
  ];

  noSizeIter: [
    source:;
    {iter: @source toIter; next: [@iter.next];}
  ];

  @noSizeIter @noSizeIter test
  [         ] [         ] test
  @noSizeIter [         ] test
  [         ] @noSizeIter test

  # White-box check that a furthest possible iteration is not affected by arithmetic overflow
  [
    INT32_MAX: [0x7FFFFFFF];

    ints: 0 iota INT32_MAX @Int32 headIter dynamic;
    [ints "size" has ~] "size given" ensure

    testCompareUnknown: [
      iter0: iter1: comparator: upperBound: Diff: normalizedResult:;;;;;;
      @iter0 @iter1 @comparator upperBound Comparator @Diff OnlyOnce compareNormalized normalizedResult FALSE TRUE check
    ];

    ints dup                                                       [-] INT32_MAX @Int32  0 testCompareUnknown
    ints dup [v:; v INT32_MAX 1 - < [v new] [v 1 +] if] @Int32 map [-] INT32_MAX @Int32 -1 testCompareUnknown
    ints dup [v:; v INT32_MAX 1 - < [v new] [v 1 -] if] @Int32 map [-] INT32_MAX @Int32  1 testCompareUnknown
  ] call
] call

# contains
[
  ""    ""   contains isRef TRUE  FALSE FALSE check
  "0"   ""   contains isRef TRUE  FALSE FALSE check

  ""    "0"  contains isRef FALSE FALSE FALSE check
  "0"   "0"  contains isRef TRUE  FALSE TRUE  check
  "1"   "0"  contains isRef FALSE FALSE TRUE  check
  "00"  "0"  contains isRef TRUE  FALSE TRUE  check
  "10"  "0"  contains isRef TRUE  FALSE TRUE  check
  "01"  "0"  contains isRef TRUE  FALSE TRUE  check
  "11"  "0"  contains isRef FALSE FALSE TRUE  check

  "0"   "00" contains isRef FALSE FALSE FALSE check
  "1"   "00" contains isRef FALSE FALSE FALSE check
  "00"  "00" contains isRef TRUE  FALSE TRUE  check
  "10"  "00" contains isRef FALSE FALSE TRUE  check
  "01"  "00" contains isRef FALSE FALSE TRUE  check
  "11"  "00" contains isRef FALSE FALSE TRUE  check
  "000" "00" contains isRef TRUE  FALSE TRUE  check
  "100" "00" contains isRef TRUE  FALSE TRUE  check
  "010" "00" contains isRef FALSE FALSE TRUE  check
  "110" "00" contains isRef FALSE FALSE TRUE  check
  "001" "00" contains isRef TRUE  FALSE TRUE  check
  "101" "00" contains isRef FALSE FALSE TRUE  check
  "011" "00" contains isRef FALSE FALSE TRUE  check
  "111" "00" contains isRef FALSE FALSE TRUE  check

  "0"   "10" contains isRef FALSE FALSE FALSE check
  "1"   "10" contains isRef FALSE FALSE FALSE check
  "00"  "10" contains isRef FALSE FALSE TRUE  check
  "10"  "10" contains isRef TRUE  FALSE TRUE  check
  "01"  "10" contains isRef FALSE FALSE TRUE  check
  "11"  "10" contains isRef FALSE FALSE TRUE  check
  "000" "10" contains isRef FALSE FALSE TRUE  check
  "100" "10" contains isRef TRUE  FALSE TRUE  check
  "010" "10" contains isRef TRUE  FALSE TRUE  check
  "110" "10" contains isRef TRUE  FALSE TRUE  check
  "001" "10" contains isRef FALSE FALSE TRUE  check
  "101" "10" contains isRef TRUE  FALSE TRUE  check
  "011" "10" contains isRef FALSE FALSE TRUE  check
  "111" "10" contains isRef FALSE FALSE TRUE  check
] call

# endsWith
[
  ""    ""   endsWith isRef TRUE  FALSE FALSE check
  "0"   ""   endsWith isRef TRUE  FALSE FALSE check

  ""    "0"  endsWith isRef FALSE FALSE FALSE check
  "0"   "0"  endsWith isRef TRUE  FALSE TRUE  check
  "1"   "0"  endsWith isRef FALSE FALSE TRUE  check
  "00"  "0"  endsWith isRef TRUE  FALSE TRUE  check
  "10"  "0"  endsWith isRef TRUE  FALSE TRUE  check
  "01"  "0"  endsWith isRef FALSE FALSE TRUE  check
  "11"  "0"  endsWith isRef FALSE FALSE TRUE  check

  "0"   "00" endsWith isRef FALSE FALSE FALSE check
  "1"   "00" endsWith isRef FALSE FALSE FALSE check
  "00"  "00" endsWith isRef TRUE  FALSE TRUE  check
  "10"  "00" endsWith isRef FALSE FALSE TRUE  check
  "01"  "00" endsWith isRef FALSE FALSE TRUE  check
  "11"  "00" endsWith isRef FALSE FALSE TRUE  check
  "000" "00" endsWith isRef TRUE  FALSE TRUE  check
  "100" "00" endsWith isRef TRUE  FALSE TRUE  check
  "010" "00" endsWith isRef FALSE FALSE TRUE  check
  "110" "00" endsWith isRef FALSE FALSE TRUE  check
  "001" "00" endsWith isRef FALSE FALSE TRUE  check
  "101" "00" endsWith isRef FALSE FALSE TRUE  check
  "011" "00" endsWith isRef FALSE FALSE TRUE  check
  "111" "00" endsWith isRef FALSE FALSE TRUE  check

  "0"   "10" endsWith isRef FALSE FALSE FALSE check
  "1"   "10" endsWith isRef FALSE FALSE FALSE check
  "00"  "10" endsWith isRef FALSE FALSE TRUE  check
  "10"  "10" endsWith isRef TRUE  FALSE TRUE  check
  "01"  "10" endsWith isRef FALSE FALSE TRUE  check
  "11"  "10" endsWith isRef FALSE FALSE TRUE  check
  "000" "10" endsWith isRef FALSE FALSE TRUE  check
  "100" "10" endsWith isRef FALSE FALSE TRUE  check
  "010" "10" endsWith isRef TRUE  FALSE TRUE  check
  "110" "10" endsWith isRef TRUE  FALSE TRUE  check
  "001" "10" endsWith isRef FALSE FALSE TRUE  check
  "101" "10" endsWith isRef FALSE FALSE TRUE  check
  "011" "10" endsWith isRef FALSE FALSE TRUE  check
  "111" "10" endsWith isRef FALSE FALSE TRUE  check
] call

# case
[
  tuple: (11 19 13 17);
  4 [
    variant: -1;
    i tuple @ (
      11 [0 !variant]
      19 [1 !variant]
      13 [2 !variant]
      [3 !variant]
    ) case

    variant new isRef i FALSE FALSE check
  ] times
] call

# cond
[
  tuple: (11 19.0 13 17.0);
  4 [
    variant: -1;
    i tuple @ (
      [Int32 cast 13 <] [0 !variant]
      [Int32 cast 17 >] [1 !variant]
      [Int32 cast 17 <] [2 !variant]
      [3 !variant]
    ) cond

    variant new isRef i FALSE FALSE check
  ] times
] call

# fibonacci
[
  tuple: (0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765);
  1 0 fibonacci FALSE FALSE FALSE FALSE TRUE tuple 0 tuple fieldCount testIter

  tuple: (-6765.0 4181.0 -2584.0 1597.0 -987.0 610.0 -377.0 233.0 -144.0 89.0 -55.0 34.0 -21.0 13.0 -8.0 5.0 -3.0 2.0 -1.0 1.0 0.0);
  10946.0 -6765.0 fibonacci FALSE FALSE FALSE FALSE TRUE tuple 0 tuple fieldCount testIter
] call

# iota
[
  tuple: (0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20);
  0 iota FALSE FALSE FALSE FALSE TRUE tuple 0 tuple fieldCount testIter

  tuple: (-20.0 -19.0 -18.0 -17.0 -16.0 -15.0 -14.0 -13.0 -12.0 -11.0 -10.0 -9.0 -8.0 -7.0 -6.0 -5.0 -4.0 -3.0 -2.0 -1.0 0.0);
  -20.0 iota FALSE FALSE FALSE FALSE TRUE tuple 0 tuple fieldCount testIter
] call

# countIter
[
  makeIter: [
    sized:;
    {
      tuple: @tuple;
      offset: 0;

      next: [
        offset tuple fieldCount = [() FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];

      sized [size: [tuple fieldCount offset -];] [] uif
    }
  ];

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);

  count0: 0;
  FALSE makeIter @count0 countIter TRUE FALSE FALSE FALSE FALSE @tuple 0 tuple fieldCount testIter
  count0 new isRef tuple fieldCount FALSE FALSE check

  count1: 0.0;
  TRUE makeIter @count1 countIter TRUE FALSE TRUE FALSE FALSE @tuple 0 tuple fieldCount testIter
  count1 new isRef tuple fieldCount Real64 cast FALSE FALSE check
] call

# enumerate
[
  =: [pair0: pair1:;; pair0 "key" has [pair1 "key" has] &&] [
    pair0: pair1:;;
    pair0.key pair1.key = [@pair0.@value isConst @pair1.@value isConst = [pair0.value pair1.value is] &&] &&
  ] pfunc;

  makeIter: [
    sized:;
    {
      tuple: @tuple;
      offset: 0;

      next: [
        offset tuple fieldCount = [() FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];

      sized [size: [tuple fieldCount offset -];] [] uif
    }
  ];

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  FALSE makeIter 20   enumerate FALSE FALSE FALSE FALSE FALSE (tuple fieldCount [{key: 20   i             +; value: i @tuple @;}] times) 0 tuple fieldCount testIter
  TRUE  makeIter 30.0 enumerate FALSE FALSE TRUE  FALSE FALSE (tuple fieldCount [{key: 30.0 i Real64 cast +; value: i @tuple @;}] times) 0 tuple fieldCount testIter
] call

# filter
[
  tuple: (9 7 3 1 5 2.0 4.0 6.0 8.0);
  @tuple [Int32 cast 5 <] filter [Int32 cast 2 >] filter TRUE FALSE FALSE FALSE FALSE (2 @tuple @ 6 @tuple @) 0 2 testIter

  tuple: (9 7 3 1 5 2 4 6 8);
  @tuple [Int32 cast 5 dynamic <] filter [Int32 cast 2 >] filter TRUE TRUE FALSE TRUE FALSE (2 @tuple @ 6 @tuple @) 0 2 testIter
] call

# headIter
[
  makeIter: [
    sized:;
    {
      tuple: @tuple;
      offset: 0;

      next: [
        offset tuple fieldCount = [Int32 Ref FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];

      sized [size: [tuple fieldCount offset -];] [] uif
    }
  ];

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  FALSE makeIter 0         [()       ] headIter TRUE FALSE FALSE FALSE FALSE @tuple 0 0 testIter
  TRUE  makeIter 0         [()       ] headIter TRUE FALSE TRUE  FALSE FALSE @tuple 0 0 testIter
  FALSE makeIter 7         [()       ] headIter TRUE FALSE FALSE FALSE FALSE @tuple 0 7 testIter
  TRUE  makeIter 7         [()       ] headIter TRUE FALSE TRUE  FALSE FALSE @tuple 0 7 testIter
  FALSE makeIter 8         [()       ] headIter TRUE FALSE FALSE FALSE FALSE @tuple 0 8 testIter
  TRUE  makeIter 8         [()       ] headIter TRUE FALSE TRUE  FALSE FALSE @tuple 0 8 testIter
  FALSE makeIter 9         [()       ] headIter TRUE FALSE FALSE FALSE FALSE @tuple 0 8 testIter
  TRUE  makeIter 9         [()       ] headIter TRUE FALSE TRUE  FALSE FALSE @tuple 0 8 testIter
  FALSE makeIter 0 dynamic [Int32 Ref] headIter TRUE FALSE FALSE TRUE  FALSE @tuple 0 0 testIter
  TRUE  makeIter 0 dynamic [Int32 Ref] headIter TRUE FALSE TRUE  TRUE  FALSE @tuple 0 0 testIter

  tuple: (2 3 5 7 11 13 17 19);
  FALSE makeIter 7 dynamic [Int32 Ref] headIter TRUE TRUE FALSE TRUE FALSE @tuple 0 7 testIter
  TRUE  makeIter 7 dynamic [Int32 Ref] headIter TRUE TRUE TRUE  TRUE FALSE @tuple 0 7 testIter
  FALSE makeIter 8 dynamic [Int32 Ref] headIter TRUE TRUE FALSE TRUE FALSE @tuple 0 8 testIter
  TRUE  makeIter 8 dynamic [Int32 Ref] headIter TRUE TRUE TRUE  TRUE FALSE @tuple 0 8 testIter
  FALSE makeIter 9 dynamic [Int32 Ref] headIter TRUE TRUE FALSE TRUE FALSE @tuple 0 8 testIter
  TRUE  makeIter 9 dynamic [Int32 Ref] headIter TRUE TRUE TRUE  TRUE FALSE @tuple 0 8 testIter
] call

# joinIter
[
  makeIter: [
    tuple: sized:;;
    {
      tuple: @tuple;
      offset: 0;

      next: [
        offset tuple fieldCount = [() FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];

      sized [size: [tuple fieldCount offset -];] [] uif
    }
  ];

  tuple0: (2 3.0 5 7.0);
  tuple1: (11 13.0 17);
  (tuple0 FALSE makeIter tuple1 FALSE makeIter) [+] [()] joinIter FALSE FALSE FALSE FALSE FALSE (13 16.0 22) 0 3 testIter
  (tuple0 TRUE  makeIter tuple1 FALSE makeIter) [+] [()] joinIter FALSE FALSE FALSE FALSE FALSE (13 16.0 22) 0 3 testIter
  (tuple0 FALSE makeIter tuple1 TRUE  makeIter) [+] [()] joinIter FALSE FALSE FALSE FALSE FALSE (13 16.0 22) 0 3 testIter
  (tuple0 TRUE  makeIter tuple1 TRUE  makeIter) [+] [()] joinIter FALSE FALSE TRUE  FALSE FALSE (13 16.0 22) 0 3 testIter
] call

# map
[
  makeIter: [
    sized:;
    {
      tuple: @tuple;
      offset: 0;

      next: [
        offset tuple fieldCount = [() FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];

      sized [size: [tuple fieldCount offset -];] [] uif
    }
  ];

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  FALSE makeIter [v:; v 1         v cast +] [()] map FALSE FALSE FALSE FALSE FALSE (tuple fieldCount [i tuple @ 1 i tuple @ cast +] times) 0 tuple fieldCount testIter
  TRUE  makeIter [v:; v 1         v cast +] [()] map FALSE FALSE TRUE  FALSE FALSE (tuple fieldCount [i tuple @ 1 i tuple @ cast +] times) 0 tuple fieldCount testIter
  FALSE makeIter [v:; v 1 dynamic v cast +] [()] map FALSE TRUE  FALSE FALSE FALSE (tuple fieldCount [i tuple @ 1 i tuple @ cast +] times) 0 tuple fieldCount testIter
  TRUE  makeIter [v:; v 1 dynamic v cast +] [()] map FALSE TRUE  TRUE  FALSE FALSE (tuple fieldCount [i tuple @ 1 i tuple @ cast +] times) 0 tuple fieldCount testIter
] call

# wrapIter
[
  =: [tuple0: tuple1:;; tuple0 isBuiltinTuple [tuple1 isBuiltinTuple] &&] [
    tuple0: tuple1:;;
    tuple0 fieldCount tuple1 fieldCount = [
      result: FALSE;
      i: 0; [
        i tuple0 fieldCount = [TRUE !result FALSE] [
          i @tuple0 @ isConst i @tuple1 @ isConst = [i tuple0 @ i tuple1 @ is] && dup [i 1 + !i] when
        ] if
      ] loop

      result
    ] &&
  ] pfunc;

  makeIter: [
    tuple: sized:;;
    {
      tuple: @tuple;
      offset: 0;

      next: [
        offset tuple fieldCount = [() FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];

      sized [size: [tuple fieldCount offset -];] [] uif
    }
  ];

  tuple0: ();
  tuple1: (2);
  tuple2: (3.0 5);
  tuple3: (7.0 11 13.0);
  () wrapIter FALSE FALSE TRUE FALSE FALSE () 0 0 testIter
  (@tuple0 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE () 0 0 testIter
  (@tuple0 TRUE  makeIter) wrapIter FALSE FALSE TRUE  FALSE FALSE () 0 0 testIter
  (@tuple3 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (3 [(i @tuple3 @)] times) 0 3 testIter
  (@tuple3 TRUE  makeIter) wrapIter FALSE FALSE TRUE  FALSE FALSE (3 [(i @tuple3 @)] times) 0 3 testIter
  (@tuple2 FALSE makeIter @tuple3 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (2 [(i @tuple2 @ i @tuple3 @)] times) 0 2 testIter
  (@tuple2 TRUE  makeIter @tuple3 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (2 [(i @tuple2 @ i @tuple3 @)] times) 0 2 testIter
  (@tuple2 FALSE makeIter @tuple3 TRUE  makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (2 [(i @tuple2 @ i @tuple3 @)] times) 0 2 testIter
  (@tuple2 TRUE  makeIter @tuple3 TRUE  makeIter) wrapIter FALSE FALSE TRUE  FALSE FALSE (2 [(i @tuple2 @ i @tuple3 @)] times) 0 2 testIter
  (@tuple3 FALSE makeIter @tuple1 FALSE makeIter @tuple2 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
  (@tuple3 TRUE  makeIter @tuple1 FALSE makeIter @tuple2 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
  (@tuple3 FALSE makeIter @tuple1 TRUE  makeIter @tuple2 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
  (@tuple3 TRUE  makeIter @tuple1 TRUE  makeIter @tuple2 FALSE makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
  (@tuple3 FALSE makeIter @tuple1 FALSE makeIter @tuple2 TRUE  makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
  (@tuple3 TRUE  makeIter @tuple1 FALSE makeIter @tuple2 TRUE  makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
  (@tuple3 FALSE makeIter @tuple1 TRUE  makeIter @tuple2 TRUE  makeIter) wrapIter FALSE FALSE FALSE FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
  (@tuple3 TRUE  makeIter @tuple1 TRUE  makeIter @tuple2 TRUE  makeIter) wrapIter FALSE FALSE TRUE  FALSE FALSE (1 [(i @tuple3 @ i @tuple1 @ i @tuple2 @)] times) 0 1 testIter
] call

# unhead
[
  makeIter: [
    tuple: sized:;;
    {
      tuple: @tuple;
      offset: 0;

      next: [
        offset tuple fieldCount = [Int32 Ref FALSE] [
          offset @tuple @
          offset 1 + !offset
          TRUE
        ] if
      ];

      sized [size: [tuple fieldCount offset -];] [] uif
    }
  ];

  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    @tuple0 FALSE makeIter i             unhead TRUE FALSE FALSE FALSE FALSE @tuple0 i tuple0 fieldCount i - testIter
    @tuple0 TRUE  makeIter i             unhead TRUE FALSE TRUE  FALSE FALSE @tuple0 i tuple0 fieldCount i - testIter
    @tuple1 FALSE makeIter i new dynamic unhead TRUE TRUE  FALSE TRUE  FALSE @tuple1 i tuple1 fieldCount i - testIter
    @tuple1 TRUE  makeIter i new dynamic unhead TRUE TRUE  TRUE  TRUE  FALSE @tuple1 i tuple1 fieldCount i - testIter
    @tuple2 FALSE makeIter i             unhead TRUE FALSE FALSE FALSE FALSE @tuple2 i tuple2 fieldCount i - testIter
    @tuple2 TRUE  makeIter i             unhead TRUE FALSE TRUE  FALSE FALSE @tuple2 i tuple2 fieldCount i - testIter
  ] times

  @tuple0 FALSE makeIter tuple0 fieldCount 1 +         unhead TRUE FALSE FALSE FALSE FALSE @tuple0 tuple0 fieldCount 0 testIter
  @tuple0 TRUE  makeIter tuple0 fieldCount 1 +         unhead TRUE FALSE TRUE  FALSE FALSE @tuple0 tuple0 fieldCount 0 testIter
  @tuple1 FALSE makeIter tuple1 fieldCount 1 + dynamic unhead TRUE TRUE  FALSE TRUE  FALSE @tuple1 tuple1 fieldCount 0 testIter
  @tuple1 TRUE  makeIter tuple1 fieldCount 1 + dynamic unhead TRUE TRUE  TRUE  TRUE  FALSE @tuple1 tuple1 fieldCount 0 testIter
  @tuple2 FALSE makeIter tuple2 fieldCount 1 +         unhead TRUE FALSE FALSE FALSE FALSE @tuple2 tuple2 fieldCount 0 testIter
  @tuple2 TRUE  makeIter tuple2 fieldCount 1 +         unhead TRUE FALSE TRUE  FALSE FALSE @tuple2 tuple2 fieldCount 0 testIter
] call

# all
[
  () [10 <] all isRef TRUE FALSE FALSE check

  tuple: (2 3 5 7 11 13 17 19);
  tuple [10         <] all isRef FALSE FALSE FALSE check
  tuple [20         <] all isRef TRUE  FALSE FALSE check
  tuple [10 dynamic <] all isRef FALSE FALSE TRUE  check
  tuple [20 dynamic <] all isRef TRUE  FALSE TRUE  check

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple [Int32 cast 10         <] all isRef FALSE FALSE FALSE check
  tuple [Int32 cast 20         <] all isRef TRUE  FALSE FALSE check
  tuple [Int32 cast 10 dynamic <] all isRef FALSE FALSE TRUE  check
  tuple [Int32 cast 20 dynamic <] all isRef TRUE  FALSE TRUE  check
] call

# any
[
  () [10 >] any isRef FALSE FALSE FALSE check

  tuple: (2 3 5 7 11 13 17 19);
  tuple [10         >] any isRef TRUE  FALSE FALSE check
  tuple [20         >] any isRef FALSE FALSE FALSE check
  tuple [10 dynamic >] any isRef TRUE  FALSE TRUE  check
  tuple [20 dynamic >] any isRef FALSE FALSE TRUE  check

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple [Int32 cast 10         >] any isRef TRUE  FALSE FALSE check
  tuple [Int32 cast 20         >] any isRef FALSE FALSE FALSE check
  tuple [Int32 cast 10 dynamic >] any isRef TRUE  FALSE TRUE  check
  tuple [Int32 cast 20 dynamic >] any isRef FALSE FALSE TRUE  check
] call

# count
[
  "BCEGKMQS" count isRef 8 FALSE FALSE check
  (2 3.0 5 7.0 11 13.0 17 19.0) count isRef 8 FALSE FALSE check

  {
    iterSize: 8;
    next: [() iterSize 0 = ~ dup [iterSize 1 - !iterSize] when];
  } count isRef 8 FALSE FALSE check

  {next: ["unexpected code" raiseStaticError]; size: [8];} count isRef 8 FALSE FALSE check
] call

# each
[
  tuple0: (2 3.0 5 7.0 11 13.0 17 19.0);

  sum: 0;
  tuple0 [Int32 cast sum + !sum] each
  sum new isRef 77 FALSE FALSE check

  tuple1: (@tuple0 [] each);
  tuple0 fieldCount [
    i @tuple1 @ isRef i @tuple0 @ TRUE FALSE check
  ] times
] call

# find
[
  ""    ""   find isRef 0 FALSE FALSE check
  "0"   ""   find isRef 0 FALSE FALSE check

  ""    "0"  find isRef 0 FALSE FALSE check
  "0"   "0"  find isRef 0 FALSE TRUE  check
  "1"   "0"  find isRef 1 FALSE TRUE  check
  "00"  "0"  find isRef 0 FALSE TRUE  check
  "10"  "0"  find isRef 1 FALSE TRUE  check
  "01"  "0"  find isRef 0 FALSE TRUE  check
  "11"  "0"  find isRef 2 FALSE TRUE  check

  "0"   "00" find isRef 1 FALSE FALSE check
  "1"   "00" find isRef 1 FALSE FALSE check
  "00"  "00" find isRef 0 FALSE TRUE  check
  "10"  "00" find isRef 2 FALSE TRUE  check
  "01"  "00" find isRef 2 FALSE TRUE  check
  "11"  "00" find isRef 2 FALSE TRUE  check
  "000" "00" find isRef 0 FALSE TRUE  check
  "100" "00" find isRef 1 FALSE TRUE  check
  "010" "00" find isRef 3 FALSE TRUE  check
  "110" "00" find isRef 3 FALSE TRUE  check
  "001" "00" find isRef 0 FALSE TRUE  check
  "101" "00" find isRef 3 FALSE TRUE  check
  "011" "00" find isRef 3 FALSE TRUE  check
  "111" "00" find isRef 3 FALSE TRUE  check

  "0"   "10" find isRef 1 FALSE FALSE check
  "1"   "10" find isRef 1 FALSE FALSE check
  "00"  "10" find isRef 2 FALSE TRUE  check
  "10"  "10" find isRef 0 FALSE TRUE  check
  "01"  "10" find isRef 2 FALSE TRUE  check
  "11"  "10" find isRef 2 FALSE TRUE  check
  "000" "10" find isRef 3 FALSE TRUE  check
  "100" "10" find isRef 0 FALSE TRUE  check
  "010" "10" find isRef 1 FALSE TRUE  check
  "110" "10" find isRef 1 FALSE TRUE  check
  "001" "10" find isRef 3 FALSE TRUE  check
  "101" "10" find isRef 0 FALSE TRUE  check
  "011" "10" find isRef 3 FALSE TRUE  check
  "111" "10" find isRef 3 FALSE TRUE  check
] call

# findOrdinal
[
  () [11 =] findOrdinal isRef -1 FALSE FALSE check

  tuple: (2 3 5 7 11 13 17 19);
  tuple [11         =] findOrdinal isRef  4 FALSE FALSE check
  tuple [20         =] findOrdinal isRef -1 FALSE FALSE check
  tuple [11 dynamic =] findOrdinal isRef  4 FALSE TRUE  check
  tuple [20 dynamic =] findOrdinal isRef -1 FALSE TRUE  check

  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple [Int32 cast 11         =] findOrdinal isRef  4 FALSE FALSE check
  tuple [Int32 cast 20         =] findOrdinal isRef -1 FALSE FALSE check
  tuple [Int32 cast 11 dynamic =] findOrdinal isRef  4 FALSE TRUE  check
  tuple [Int32 cast 20 dynamic =] findOrdinal isRef -1 FALSE TRUE  check
] call

# meetsAll
[
  10 () meetsAll isRef TRUE FALSE FALSE check

  tuple: ([2 >] [3 >] [5 >] [7 >]);
  4         tuple meetsAll isRef FALSE FALSE FALSE check
  8         tuple meetsAll isRef TRUE  FALSE FALSE check
  4 dynamic tuple meetsAll isRef FALSE FALSE TRUE  check
  8 dynamic tuple meetsAll isRef TRUE  FALSE TRUE  check
] call

# meetsAny
[
  10 () meetsAny isRef FALSE FALSE FALSE check

  tuple: ([2 <] [3 <] [5 <] [7 <]);
  4         tuple meetsAny isRef TRUE  FALSE FALSE check
  8         tuple meetsAny isRef FALSE FALSE FALSE check
  4 dynamic tuple meetsAny isRef TRUE  FALSE TRUE  check
  8 dynamic tuple meetsAny isRef FALSE FALSE TRUE  check
] call

# mutate
[
  tuple0: (3 4.0 6 8.0 12 14.0 18 20.0);
  tuple1: (2 3.0 5 7.0 11 13.0 17 19.0);
  @tuple1 [v:; v 1 v cast +] mutate
  tuple0 fieldCount [
    i @tuple1 @ new isRef i @tuple0 @ FALSE FALSE check
  ] times
] call

# slice
[
  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    size: i;
    tuple0 fieldCount size - 1 + [
      @tuple0 i             size             slice FALSE FALSE TRUE @tuple0 i size testView
      @tuple1 i new dynamic size             slice TRUE  FALSE TRUE @tuple1 i size testView
      @tuple0 i             size new dynamic slice FALSE TRUE  TRUE @tuple0 i size testView
      @tuple1 i new dynamic size new dynamic slice TRUE  TRUE  TRUE @tuple1 i size testView
      @tuple2 i             size             slice FALSE FALSE TRUE @tuple2 i size testView
      @tuple2 i             size new dynamic slice FALSE TRUE  TRUE @tuple2 i size testView
    ] times
  ] times
] call

# range
[
  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    size: i;
    tuple0 fieldCount size - 1 + [
      @tuple0 i             i size +         range FALSE FALSE TRUE @tuple0 i size testView
      @tuple1 i new dynamic i size +         range TRUE  TRUE  TRUE @tuple1 i size testView
      @tuple0 i             i size + dynamic range FALSE TRUE  TRUE @tuple0 i size testView
      @tuple1 i new dynamic i size + dynamic range TRUE  TRUE  TRUE @tuple1 i size testView
      @tuple2 i             i size +         range FALSE FALSE TRUE @tuple2 i size testView
      @tuple2 i             i size + dynamic range FALSE TRUE  TRUE @tuple2 i size testView
    ] times
  ] times
] call

# head
[
  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple fieldCount 1 + [
    @tuple i             head FALSE FALSE TRUE @tuple 0 i testView
    @tuple i new dynamic head FALSE TRUE  TRUE @tuple 0 i testView
  ] times
] call

# tail
[
  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    @tuple0 i             tail FALSE FALSE TRUE @tuple0 tuple0 fieldCount i - i testView
    @tuple1 i new dynamic tail TRUE  TRUE  TRUE @tuple1 tuple1 fieldCount i - i testView
    @tuple2 i             tail FALSE FALSE TRUE @tuple2 tuple2 fieldCount i - i testView
  ] times
] call

# unhead
[
  tuple0: (2 3   5 7   11 13   17 19  );
  tuple1: (2 3   5 7   11 13   17 19  );
  tuple2: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple0 fieldCount 1 + [
    @tuple0 i             unhead FALSE FALSE TRUE @tuple0 i tuple0 fieldCount i - testView
    @tuple1 i new dynamic unhead TRUE  TRUE  TRUE @tuple1 i tuple1 fieldCount i - testView
    @tuple2 i             unhead FALSE FALSE TRUE @tuple2 i tuple2 fieldCount i - testView
  ] times
] call

# untail
[
  tuple: (2 3.0 5 7.0 11 13.0 17 19.0);
  tuple fieldCount 1 + [
    @tuple i             untail FALSE FALSE TRUE @tuple 0 tuple fieldCount i - testView
    @tuple i new dynamic untail FALSE TRUE  TRUE @tuple 0 tuple fieldCount i - testView
  ] times
] call
