# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Span.toSpan"                    use
"Span.toSpan2"                   use
"algorithm.each"                 use
"algorithm.filter"               use
"algorithm.findOrdinal"          use
"algorithm.makeArrayIndex"       use
"algorithm.makeArrayIter"        use
"algorithm.makeArrayView"        use
"algorithm.schemaNameBeginsWith" use
"algorithm.toIndex"              use
"algorithm.toIter"               use
"algorithm.unhead"               use
"control.&&"                     use
"control.Natx"                   use
"control.Ref"                    use
"control.assert"                 use
"control.automatic?"             use
"control.compose"                use
"control.drop"                   use
"control.dup"                    use
"control.pfunc"                  use
"control.swap"                   use
"control.times"                  use
"control.when"                   use
"control.while"                  use
"memory.memcpy"                  use
"memory.mplFree"                 use
"memory.mplRealloc"              use

makeArrayObject: [
  Item: memoryDebugObject:;;
  {
    SCHEMA_NAME: "Array<" @Item schemaName & ">" & virtual;

    virtual memoryDebugObject: memoryDebugObject new;

    virtual elementType: @Item Ref;
    dataBegin:   @elementType private;
    dataSize:    0            private;
    dataReserve: 0;
    virtual elementSize: @elementType storageSize;

    append: [
      append: ["Invalid source schema" raiseStaticError];

      append: [toIter TRUE] [
        iter: toIter;
        @iter "size" has [
          oldSize: dataSize new;
          oldSize @iter.size + enlarge
          @iter.size [
            @iter.next drop oldSize i + at set
          ] times
        ] [
          [
            @iter.next [append TRUE] [drop FALSE] if
          ] loop
        ] if
      ] pfunc;

      append: [toSpan TRUE] [
        span: toSpan;
        oldSize: dataSize new;
        oldSize span.size + enlarge
        @dataBegin automatic? [
          span.size [
            i @span.at oldSize i + at set
          ] times
        ] [
          [span.data @dataBegin same] "Inconsistent schemas" assert
          @dataBegin storageSize span.size Natx cast * span.data storageAddress oldSize at storageAddress memcpy drop
        ] if
      ] pfunc;

      append: [@elementType same] [
        item:;
        addReserve
        dataSize 1 + @dataSize set
        newItem: dataSize 1 - at;
        @newItem manuallyInitVariable
        @item @newItem set
      ] pfunc;

      append
    ];

    assign: [
      assign: ["Invalid source schema" raiseStaticError];

      assign: [toIter TRUE] [
        iter: toIter;
        @iter "size" has [
          @iter.size resize
          @iter.size [
            @iter.next drop i at set
          ] times
        ] [
          clear
          [
            @iter.next [append TRUE] [drop FALSE] if
          ] loop
        ] if
      ] pfunc;

      assign: [toSpan TRUE] [
        span: toSpan;
        span.size resize
        @dataBegin automatic? [
          span.size [
            i @span.at i at set
          ] times
        ] [
          [span.data @dataBegin same] "Inconsistent schemas" assert
          @dataBegin storageSize span.size Natx cast * span.data storageAddress @dataBegin storageAddress memcpy drop
        ] if
      ] pfunc;

      assign: [self same] [@self set] pfunc;

      assign
    ];

    at: [
      index:;
      index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
      [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert
      @dataBegin storageAddress index Natx cast elementSize * + @elementType addressToReference
    ];

    clear: [
      0 shrink
    ];

    data: [
      @dataBegin
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

    iter: [@dataBegin dataSize makeArrayIter];

    last: [
      dataSize 1 - at
    ];

    popBack: [
      [dataSize 0 >] "Pop from empty array!" assert
      dataSize 1 - shrink
    ];

    release: [
      clear
      addr: @dataBegin storageAddress;
      size: dataReserve Natx cast elementSize *;
      memoryDebugObject [TRUE !memoryDebugEnabled] when
      addr 0nx = ~ [size addr mplFree] when
      memoryDebugObject [FALSE !memoryDebugEnabled] when
      @elementType Ref !dataBegin
      0 @dataSize set
      0 @dataReserve set
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

    reverseIter: [
      {
        index: @dataBegin dataSize makeArrayIndex;
        key:   dataSize new;
        get:   [key 1 - @index.at];
        next:  [key 1 - !key];
        valid: [key 0 = ~];
      }
    ];

    setReserve: [
      newReserve:;
      [newReserve dataReserve < ~] "New reserve is less than old reserve!" assert
      memoryDebugObject [TRUE !memoryDebugEnabled] when
      newReserve Natx cast elementSize * dataReserve Natx cast elementSize * @dataBegin storageAddress mplRealloc
      memoryDebugObject [FALSE !memoryDebugEnabled] when
      @elementType addressToReference !dataBegin
      newReserve @dataReserve set
    ];

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

    size: [
      dataSize new
    ];

    slice: [span.slice];

    span: [
      @dataBegin dataSize toSpan2
    ];

    private ASSIGN: [
      other:;
      other.size resize

      i: 0 dynamic;
      [i dataSize <] [
        i other.at i at set
        i 1 + @i set
      ] while
    ];

    private DIE: [
      clear
      addr: @dataBegin storageAddress;
      size: dataReserve Natx cast elementSize *;
      memoryDebugObject [TRUE !memoryDebugEnabled] when
      addr 0nx = ~ [size addr mplFree] when
      memoryDebugObject [FALSE !memoryDebugEnabled] when
    ];

    private INIT: [
      @elementType Ref !dataBegin
      0 @dataSize set
      0 @dataReserve set
    ];

    private addReserve: [
      dataSize dataReserve = [
        getNextReserve setReserve
      ] when
    ];

    private getNextReserve: [
      dataReserve dataReserve 4 / + 4 +
    ];
  }
];

Array: [FALSE makeArrayObject];
MemoryDebugArray: [TRUE makeArrayObject];

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

toArray: [toIter TRUE] [
  iter: toIter;
  first: firstValid: @iter.next;;
  array: @first newVarOfTheSameType Array;
  firstValid [
    @first @array.append
    @iter  @array.append
  ] when

  @array
] pfunc;

toArray: [toSpan TRUE] [
  span: toSpan;
  array: @span.data newVarOfTheSameType Array;
  @span @array.assign
  @array
] pfunc;

toArray: ["Array<" schemaNameBeginsWith] [
  new
] pfunc;
