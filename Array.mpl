# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.each"           use
"algorithm.filter"         use
"algorithm.findOrdinal"    use
"algorithm.makeArrayIndex" use
"algorithm.makeArrayIter"  use
"algorithm.makeArrayView"  use
"algorithm.toIndex"        use
"algorithm.toIter"         use
"algorithm.unhead"         use
"control.&&"               use
"control.@"                use
"control.Natx"             use
"control.Ref"              use
"control.assert"           use
"control.compose"          use
"control.drop"             use
"control.pfunc"            use
"control.times"            use
"control.when"             use
"control.while"            use
"memory.mplFree"           use
"memory.mplRealloc"        use

makeArrayRangeRaw: [{
  virtual RANGE: ();
  virtual ARRAY_RANGE: ();
  dataBegin:;
  dataSize: new;
  virtual elementType: @dataBegin Ref;
  virtual elementSize: @dataBegin storageSize;
  @dataBegin storageAddress @elementType addressToReference !dataBegin #dynamize

  getBufferBegin: [
    @dataBegin storageAddress
  ];

  at: [
    index:;
    index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
    [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert
    getBufferBegin index Natx cast elementSize * + @elementType addressToReference
  ];

  iter: [@dataBegin dataSize makeArrayIter];

  size: [
    dataSize
  ];

  view: [
    newIndex: newSize:;;
    {
      virtual elementType: @elementType Ref;
      getBufferBegin: getBufferBegin elementType storageSize newIndex Natx cast * +;
      size: newSize new;

      at: [Natx cast elementType storageSize * getBufferBegin + @elementType addressToReference];

      view: @view;
    }
  ];

  getSize: [
    dataSize new
  ];

  heapSortWithComparator: [
    comparator:;

    swap: [
      i1:; i2:;
      i1ref: i1 at;
      i2ref: i2 at;
      tmp: @i1ref new;
      @i2ref @i1ref set
      @tmp @i2ref set
    ];

    pushDown: [
      index: new;
      [
        left: index 2 * 1 +;
        right: left 1 +;

        max: index new;
        left  heapSize < [max at left  at @comparator call] && [left  @max set] when
        right heapSize < [max at right at @comparator call] && [right @max set] when
        max index = ~ [
          max index swap
          max @index set TRUE
        ] &&
      ] loop
    ];

    heapSize: dataSize new;
    i: dataSize 1 + 2 /;
    [i 0 >] [
      i 1 - @i set
      i pushDown
    ] while

    i: dataSize new;
    [i 1 >] [
      i 1 - @i set
      i 0 swap
      heapSize 1 - @heapSize set
      0 dynamic pushDown
    ] while
  ];

  heapSort: [
    [<] heapSortWithComparator
  ];
}];

ArrayRange: [
  element:;
  0 @element Ref makeArrayRangeRaw
];

makeArrayRange: [
  list:;
  virtual listSchema: @list Ref;
  virtual elementSchema: 0 dynamic @listSchema @ Ref;
  list fieldCount 0 dynamic list @ storageAddress @elementSchema addressToReference makeArrayRangeRaw
];

makeArrayRange: ["ARRAY_RANGE" has] [
  new
] pfunc;

makeArrayRange: ["ARRAY" has] [
  .getArrayRange
] pfunc;

makeSubRange: [
  makeArrayRange arg:;
  rangeEndIndex:;
  rangeBeginIndex:;
  [0 rangeBeginIndex > ~] "Invalid subrange, 0>begin!" assert
  [rangeBeginIndex rangeEndIndex > ~] "Invalid subrange, begin>end!" assert
  [rangeEndIndex arg.dataSize > ~] "Invalid subrange, end>size!" assert
  rangeEndIndex rangeBeginIndex - arg.getBufferBegin arg.elementSize rangeBeginIndex Natx cast * + @arg.@elementType addressToReference makeArrayRangeRaw
];

makeArrayObject: [{
  virtual memoryDebugObject: new;

  virtual CONTAINER: ();
  virtual ARRAY: ();
  virtual SCHEMA_NAME: "Array";
  virtual elementType: Ref;
  dataBegin: @elementType Ref;
  dataSize: 0;
  dataReserve: 0;
  virtual elementSize: @elementType storageSize;

  getBufferBegin: [
    @dataBegin storageAddress
  ];

  at: [
    index:;
    index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
    [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert
    getBufferBegin index Natx cast elementSize * + @elementType addressToReference
  ];

  iter: [@dataBegin dataSize makeArrayIter];

  reverseIter: [
    {
      index: @dataBegin dataSize makeArrayIndex;
      key:   dataSize new;
      get:   [key 1 - @index.at];
      next:  [key 1 - !key];
      valid: [key 0 = ~];
    }
  ];

  size: [
    dataSize new
  ];

  slice: [@dataBegin dataSize makeArrayView .slice];

  erase: [
    index:;
    index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
    [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert

    index getSize 1 - < [
      last index at set
    ] when

    popBack
  ];

  eraseIf: [
    eraseIfBody:;
    key: self @eraseIfBody findOrdinal;
    key -1 = ~ [
      @self key 1 + unhead @eraseIfBody [~] compose filter [
        key at set
        key 1 + !key
      ] each

      key shrink
    ] when
  ];

  getSize: [dataSize new];

  getArrayRange: [
    dataSize @dataBegin storageAddress @elementType addressToReference makeArrayRangeRaw
  ];

  getNextReserve: [
    dataReserve dataReserve 4 / + 4 +
  ];

  setReserve: [
    newReserve:;
    [newReserve dataReserve < ~] "New reserve is less than old reserve!" assert
    memoryDebugObject [TRUE !memoryDebugEnabled] when
    newReserve Natx cast elementSize * dataReserve Natx cast elementSize * getBufferBegin mplRealloc
    memoryDebugObject [FALSE !memoryDebugEnabled] when
    @elementType addressToReference !dataBegin
    newReserve @dataReserve set
  ];

  addReserve: [
    dataSize dataReserve = [
      getNextReserve setReserve
    ] when
  ];

  append: [
    element:;
    addReserve
    dataSize 1 + @dataSize set
    newElement: dataSize 1 - at;
    @newElement manuallyInitVariable
    @element @newElement set
  ];

  appendAll: [
    source: toIter;
    @source "size" has ~ ["sized Iter expected" raiseStaticError] when
    offset: size;
    iterSize: source.size;
    size iterSize + enlarge
    iterSize [
      @source.next drop offset i + at set
    ] times
  ];

  appendEach: [[append] each];

  shrink: [
    newSize:;
    [newSize dataSize > ~] "Shrinked size is bigger than the old size!" assert

    i: dataSize new dynamic;
    [i newSize >] [
      i 1 - @i set
      i at manuallyDestroyVariable
    ] while
    newSize @dataSize set
  ];

  popBack: [
    [dataSize 0 >] "Pop from empty array!" assert
    dataSize 1 - shrink
  ];

  last: [
    dataSize 1 - at
  ];

  enlarge: [
    newSize: dynamic;
    [newSize dataSize < ~] "Enlarged size is less than old size!" assert

    dataReserve newSize < [
      newReserve: getNextReserve;
      newReserve newSize < [newSize @newReserve set] when
      newReserve setReserve
    ] when

    i: dataSize new;
    newSize @dataSize set
    [i dataSize <] [
      i at manuallyInitVariable
      i 1 + @i set
    ] while
  ];

  resize: [
    newSize:;
    newSize dataSize = [
    ] [
      newSize dataSize < [
        newSize shrink
      ] [
        newSize enlarge
      ] if
    ] if
  ];

  clear: [
    0 shrink
  ];

  release: [
    clear
    addr: getBufferBegin;
    size: dataReserve Natx cast elementSize *;
    memoryDebugObject [TRUE !memoryDebugEnabled] when
    addr 0nx = ~ [size addr mplFree] when
    memoryDebugObject [FALSE !memoryDebugEnabled] when
    @elementType Ref !dataBegin
    0 @dataSize set
    0 @dataReserve set
  ];

  toSpan: [
    "Span.toSpan2" use
    @dataBegin dataSize toSpan2
  ];

  INIT: [
    @elementType Ref !dataBegin
    0 @dataSize set
    0 @dataReserve set
  ];

  ASSIGN: [
    other:;
    other.dataSize resize

    i: 0 dynamic;
    [i dataSize <] [
      i other.at i at set
      i 1 + @i set
    ] while
  ];

  DIE: [
    clear
    addr: getBufferBegin;
    size: dataReserve Natx cast elementSize *;
    memoryDebugObject [TRUE !memoryDebugEnabled] when
    addr 0nx = ~ [size addr mplFree] when
    memoryDebugObject [FALSE !memoryDebugEnabled] when
  ];
}];

Array: [FALSE makeArrayObject];
MemoryDebugArray: [TRUE makeArrayObject];

makeArray: [
  indexable: toIndex;
  [indexable.size 0 >] "List is empty!" assert
  result: 0 @indexable @ newVarOfTheSameType Array;
  i: 0 dynamic;
  [
    i indexable.size < [
      i @indexable @ @result.append
      i 1 + @i set TRUE
    ] &&
  ] loop

  @result
];

getHeapUsedSize: ["ARRAY" has] [
  arg:;
  result: arg.elementType storageSize arg.dataReserve Natx cast *;
  i: 0 dynamic;
  [
    i arg.getSize < [
      result i arg.at getHeapUsedSize + @result set
      i 1 + @i set TRUE
    ] &&
  ] loop

  result
] pfunc;

toArray: [
  source: toIter;
  first: firstValid: @source.next;;
  array: @first newVarOfTheSameType Array;
  firstValid [
    @source "size" has [
      1 @source.size + @array.resize
      @first 0 @array.at set
      @source.size [
        @source.next drop 1 i + @array.at set
      ] times
    ] [
      @first @array.append
      [
        @source.next [@array.append TRUE] [drop FALSE] if
      ] loop
    ] if
  ] when

  @array
];
