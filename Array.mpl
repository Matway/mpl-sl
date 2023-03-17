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
  Item: MEMORY_DEBUG_OBJECT:;;
  {
    SCHEMA_NAME: "Array<" @Item schemaName & ">" & virtual;

    Item: @Item Ref virtual;

    append: [
      append: ["Invalid source schema" raiseStaticError];

      append: [toIter TRUE] [
        iter: toIter;
        @iter "size" has [
          oldSize: arraySize new;
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
        oldSize: arraySize new;
        oldSize span.size + enlarge
        @Item automatic? [
          span.size [
            i @span.at oldSize i + at set
          ] times
        ] [
          [span.data @Item same] "Inconsistent schemas" assert
          span.size 0 = ~ [
            @Item storageSize span.size Natx cast * span.data storageAddress oldSize at storageAddress memcpy drop
          ] when
        ] if
      ] pfunc;

      append: [@Item same] [
        item:;
        addReserve
        arraySize 1 + !arraySize
        newItem: arraySize 1 - at;
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
        @Item automatic? [
          span.size [
            i @span.at i at set
          ] times
        ] [
          [span.data @Item same] "Inconsistent schemas" assert
          span.size 0 = ~ [
            @Item storageSize span.size Natx cast * span.data storageAddress @arrayData storageAddress memcpy drop
          ] when
        ] if
      ] pfunc;

      assign: [self same] [@self set] pfunc;

      assign
    ];

    at: [
      index:;
      index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
      [index 0 < ~ [index arraySize <] &&] "Index is out of range!" assert
      @arrayData storageAddress @Item storageSize index Natx cast * + @Item addressToReference
    ];

    clear: [
      0 shrink
    ];

    data: [
      @arrayData
    ];

    enlarge: [
      newSize: dynamic;
      [newSize arraySize < ~] "Enlarged size is less than old size!" assert

      arrayReserve newSize < [
        newReserve: getNextReserve;
        newReserve newSize < [newSize new !newReserve] when
        newReserve setReserve
      ] when

      i: arraySize new;
      newSize new !arraySize
      @Item automatic? [
        [i arraySize <] [
          i at manuallyInitVariable
          i 1 + !i
        ] while
      ] when
    ];

    erase: [
      index:;
      index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
      [index 0 < ~ [index arraySize <] &&] "Index is out of range!" assert

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

    iter: [@arrayData arraySize makeArrayIter];

    last: [
      arraySize 1 - at
    ];

    popBack: [
      [arraySize 0 >] "Pop from empty array!" assert
      arraySize 1 - shrink
    ];

    release: [
      clear
      addr: @arrayData storageAddress;
      size: @Item storageSize arrayReserve Natx cast *;
      MEMORY_DEBUG_OBJECT [TRUE !memoryDebugEnabled] when
      addr 0nx = ~ [size addr mplFree] when
      MEMORY_DEBUG_OBJECT [FALSE !memoryDebugEnabled] when
      @Item !arrayData
      0 !arraySize
      0 !arrayReserve
    ];

    resize: [
      newSize:;
      newSize arraySize = [
      ] [
        newSize arraySize < [
          newSize shrink
        ] [
          newSize enlarge
        ] if
      ] if
    ];

    reverseIter: [
      {
        index: @arrayData arraySize makeArrayIndex;
        key:   arraySize new;
        get:   [key 1 - @index.at];
        next:  [key 1 - !key];
        valid: [key 0 = ~];
      }
    ];

    setReserve: [
      newReserve:;
      [newReserve arrayReserve < ~] "New reserve is less than old reserve!" assert
      MEMORY_DEBUG_OBJECT [TRUE !memoryDebugEnabled] when
      @Item storageSize newReserve Natx cast * @Item storageSize arrayReserve Natx cast * @arrayData storageAddress mplRealloc
      MEMORY_DEBUG_OBJECT [FALSE !memoryDebugEnabled] when
      @Item addressToReference !arrayData
      newReserve new !arrayReserve
    ];

    shrink: [
      newSize:;
      [newSize arraySize > ~] "Shrinked size is bigger than the old size!" assert

      @Item automatic? [
        i: arraySize new dynamic;
        [i newSize >] [
          i 1 - !i
          i at manuallyDestroyVariable
        ] while
      ] when

      newSize new !arraySize
    ];

    size: [
      arraySize new
    ];

    slice: [span.slice];

    span: [
      @arrayData arraySize toSpan2
    ];

    private MEMORY_DEBUG_OBJECT: MEMORY_DEBUG_OBJECT new virtual;

    private arrayData:    @Item Ref;
    private arraySize:    0;
    private arrayReserve: 0;

    private ASSIGN: [
      other:;
      other.size resize

      i: 0 dynamic;
      [i arraySize <] [
        i other.at i at set
        i 1 + !i
      ] while
    ];

    private DIE: [
      clear
      addr: @arrayData storageAddress;
      size: @Item storageSize arrayReserve Natx cast *;
      MEMORY_DEBUG_OBJECT [TRUE !memoryDebugEnabled] when
      addr 0nx = ~ [size addr mplFree] when
      MEMORY_DEBUG_OBJECT [FALSE !memoryDebugEnabled] when
    ];

    private INIT: [
      @Item !arrayData
      0     !arraySize
      0     !arrayReserve
    ];

    private addReserve: [
      arraySize arrayReserve = [
        getNextReserve setReserve
      ] when
    ];

    private getNextReserve: [
      arrayReserve arrayReserve 4 / + 4 +
    ];
  }
];

Array:            [FALSE makeArrayObject];
MemoryDebugArray: [TRUE  makeArrayObject];

getHeapUsedSize: ["Array<" schemaNameBeginsWith] [
  arg:;
  result: arg.data storageSize arg.arrayReserve Natx cast *;
  i: 0 dynamic;
  [
    i arg.size < [
      result i arg.at getHeapUsedSize + !result
      i 1 + !i
      TRUE
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
