# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Span.toSpan2"             use
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
"control.Natx"             use
"control.Ref"              use
"control.assert"           use
"control.automatic?"       use
"control.compose"          use
"control.drop"             use
"control.pfunc"            use
"control.times"            use
"control.when"             use
"control.while"            use
"memory.mplFree"           use
"memory.mplRealloc"        use

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

  data: [
    @dataBegin
  ];

  size: [
    dataSize new
  ];

  slice: [span.slice];

  erase: [
    index:;
    index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
    [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert

    index size 1 - < [
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

    @elementType automatic? [
      i: dataSize new dynamic;
      [i newSize >] [
        i 1 - @i set
        i at manuallyDestroyVariable
      ] while
    ] when

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
    @elementType automatic? [
      [i dataSize <] [
        i at manuallyInitVariable
        i 1 + @i set
      ] while
    ] when
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

  span: [
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
  result: 0 @indexable.at newVarOfTheSameType Array;
  i: 0 dynamic;
  [
    i indexable.size < [
      i @indexable.at @result.append
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
    i arg.size < [
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
