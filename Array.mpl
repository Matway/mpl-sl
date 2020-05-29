"control.&&" use
"control.@" use
"control.Natx" use
"control.asView" use
"control.assert" use
"control.pfunc" use
"control.when" use
"control.while" use
"memory.mplFree" use
"memory.mplRealloc" use

makeArrayRangeRaw: [{
  virtual RANGE: ();
  virtual ARRAY_RANGE: ();
  dataBegin:;
  dataSize: copy dynamic;
  schema elementType: @dataBegin;
  virtual elementSize: @dataBegin storageSize;
  @dataBegin storageAddress @elementType addressToReference !dataBegin #dynamize

  getBufferBegin: [
    @dataBegin storageAddress
  ];

  at: [
    copy index:;
    index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
    [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert
    getBufferBegin index Natx cast elementSize * + @elementType addressToReference
  ];

  size: [
    dataSize
  ];

  view: [
    newIndex: newSize:;;
    {
      schema elementType: 0nx @elementType addressToReference;
      getBufferBegin: getBufferBegin elementType storageSize newIndex Natx cast * +;
      size: newSize copy;

      at: [Natx cast elementType storageSize * getBufferBegin + @elementType addressToReference];

      view: @view;
    }
  ];

  getSize: [
    dataSize copy
  ];

  heapSortWithComparator: [
    comparator:;

    swap: [
      copy i1:; copy i2:;
      i1ref: i1 at;
      i2ref: i2 at;
      tmp: @i1ref move copy;
      @i2ref move @i1ref set
      @tmp move @i2ref set
    ];

    pushDown: [
      copy index:;
      [
        left: index 2 * 1 +;
        right: left 1 +;

        max: index copy;
        left  heapSize < [max at left  at @comparator call] && [left  @max set] when
        right heapSize < [max at right at @comparator call] && [right @max set] when
        max index = ~ [
          max index swap
          max @index set TRUE
        ] &&
      ] loop
    ];

    heapSize: dataSize copy;
    i: dataSize 1 + 2 /;
    [i 0 >] [
      i 1 - @i set
      i pushDown
    ] while

    i: dataSize copy;
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
  0 0nx @element addressToReference makeArrayRangeRaw
];

makeArrayRange: [
  list:;
  schema listSchema: 0 dynamic @list @;
  list fieldCount 0 dynamic list @ storageAddress @listSchema addressToReference makeArrayRangeRaw
];

makeArrayRange: ["ARRAY_RANGE" has] [
  copy
] pfunc;

makeArrayRange: ["ARRAY" has] [
  .getArrayRange
] pfunc;

makeSubRange: [
  makeArrayRange arg:;
  copy rangeEndIndex:;
  copy rangeBeginIndex:;
  [0 rangeBeginIndex > ~] "Invalid subrange, 0>begin!" assert
  [rangeBeginIndex rangeEndIndex > ~] "Invalid subrange, begin>end!" assert
  [rangeEndIndex arg.dataSize > ~] "Invalid subrange, end>size!" assert
  rangeEndIndex rangeBeginIndex - arg.getBufferBegin arg.elementSize rangeBeginIndex Natx cast * + @arg.@elementType addressToReference makeArrayRangeRaw
];

makeArrayObject: [{
  virtual memoryDebugObject:;

  virtual CONTAINER: ();
  virtual ARRAY: ();
  virtual SCHEMA_NAME: "ARRAY";
  schema elementType:;
  dataBegin: 0nx @elementType addressToReference;
  dataSize: 0 dynamic;
  dataReserve: 0 dynamic;
  virtual elementSize: elementType storageSize;

  getBufferBegin: [
    @dataBegin storageAddress
  ];

  at: [
    copy index:;
    index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
    [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert
    getBufferBegin index Natx cast elementSize * + @elementType addressToReference
  ];

  size: [
    dataSize copy
  ];

  view: [
    newIndex: newSize:;;
    {
      schema elementType: 0nx @elementType addressToReference;
      getBufferBegin: getBufferBegin elementType storageSize newIndex Natx cast * +;
      size: newSize copy;

      at: [Natx cast elementType storageSize * getBufferBegin + @elementType addressToReference];

      view: @view;
    }
  ];

  erase: [
    copy index:;
    index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
    [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert

    index getSize 1 - < [
      last move index at set
    ] when

    popBack
  ];

  eraseIf: [
    eraseIfBody:;
    index: 0;
    self toIter @eraseIfBody filterIter [
      index at set
      index 1 + !index
    ] each

    index shrink
  ];

  getSize: [dataSize copy];

  getArrayRange: [
    dataSize @dataBegin storageAddress @elementType addressToReference makeArrayRangeRaw
  ];

  getNextReserve: [
    dataReserve dataReserve 4 / + 4 +
  ];

  setReserve: [
    copy newReserve:;
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

  pushBack: [
    elementIsMoved: isMoved;
    element:;
    addReserve
    dataSize 1 + @dataSize set
    newElement: dataSize 1 - at;
    @newElement manuallyInitVariable
    @element elementIsMoved moveIf @newElement set
  ];

  appendAll: [
    view: asView;
    index: size;
    size view.size + enlarge
    i: 0; [i view.size <] [i view.at index i + at set i 1 + !i] while
  ];

  appendEach: [[pushBack] each];

  shrink: [
    copy newSize: dynamic;
    [newSize dataSize > ~] "Shrinked size is bigger than the old size!" assert

    i: dataSize copy;
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
    copy newSize: dynamic;
    [newSize dataSize < ~] "Enlarged size is less than old size!" assert

    dataReserve newSize < [
      newReserve: getNextReserve;
      newReserve newSize < [newSize @newReserve set] when
      newReserve setReserve
    ] when

    i: dataSize copy;
    newSize @dataSize set
    [i dataSize <] [
      i at manuallyInitVariable
      i 1 + @i set
    ] while
  ];

  resize: [
    copy newSize: dynamic;
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
    0 dynamic shrink
  ];

  release: [
    clear
    addr: getBufferBegin;
    size: dataReserve Natx cast elementSize *;
    memoryDebugObject [TRUE !memoryDebugEnabled] when
    addr 0nx = ~ [size addr mplFree] when
    memoryDebugObject [FALSE !memoryDebugEnabled] when
    0nx @elementType addressToReference !dataBegin
    0 dynamic @dataSize set
    0 dynamic @dataReserve set
  ];

  INIT: [
    0nx @elementType addressToReference !dataBegin
    0 dynamic @dataSize set
    0 dynamic @dataReserve set
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
  listIsMoved: isMoved;

  list:;
  view: list asView;
  list "ARRAY_VIEW" has [FALSE @listIsMoved set] when
  [view.size 0 >] "List is empty!" assert
  result: 0 @view @ newVarOfTheSameType Array;
  i: 0 dynamic;
  [
    i view.size < [
      i @view @ listIsMoved moveIf @result.pushBack
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
