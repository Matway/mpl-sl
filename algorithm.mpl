# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

# Collection access interfaces

# Index
#   at ( key -- item ) get the contained item either by value or by reference
#   size ( -- size ) return the number of items in the Index
#
# An Index gives random access to items of a collection of known size using the 'at' method.
# Different Index types can return items by read-only reference, read-write reference, or by value.
# Trying to get an item outside the bounds of the Index is undefined behavior.

# Iter
#   next ( -- item cond ) get next item by value or by reference
#   size ( -- size ) [optional] return the number of items available through Iter
#
# An Iter provides access to the collection with the ability to work with items one at a time.
# Iter is unidirectional - you can go to the next item but you cannot go back to the past.
# Different Iter types can provide items by read-only reference, read-write reference, or by value.
# When moving to the next item, the Iter changes its internal state.

# Iterable
#   iter ( -- iter ) create an Iter that allows you to list all contained items, from first to last
#
# The Iterable interface allows you to create a new Iter to access the collection sequentially.

# ReverseIterable
#   reverseIter ( -- iter ) create an Iter that allows you to list all contained items, from last to first
#
# The ReverseIterable interface allows you to create a new Iter to access the collection sequentially.

# View
#   at ( key -- item ) [optional] get the contained item either by value or by reference
#   index ( -- index ) [optional] create an Index that allows you to access all contained items
#   iter ( -- iter ) create an Iter that allows you to list all contained items, from first to last
#   size ( -- size ) return the size of the View, which does not necessarily match the number of items
#   slice ( offset size -- view ) create a View with an offset from the current and another size
#
# A View provides access to a collection of a known size.
# The size of a View is measured in logical units and is not necessarily equal to the number of items.
# A mandatory function of View is to create a new View, potentially smaller, using the 'view' method.
# Trying to create a new View that goes beyond the current one is undefined behavior.
# A View itself does not provide access to items, but other interfaces such as Index or Iterable can provide it.

"control" use

isDirtyOrDynamic: [
  object:;
  @object isDirty [@object isDynamic] ||
];

# Predicates
isIndex: [
  object:;
  @object "at" has [@object "size" has] &&
];

isIter: [
  object:;
  @object "next" has
];

isView: [
  object:;
  @object "iter" has [@object "size" has [@object "slice" has] &&] &&
];

schemaNameBeginsWith: [
  object: text:;;
  @object "SCHEMA_NAME" has [@object.@SCHEMA_NAME textSplit text textSplit beginsWith] &&
];

# Built-in array, text, and tuple support
makeArrayIndex: [
  data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    SCHEMA_NAME: virtual "ArrayIndex";
    data: @data;
    indexSize: size dup isDynamic [] [virtual] uif new;

    at: [
      key:;
      [key 0 indexSize within] "key is out of bounds" assert
      @data storageAddress @data storageSize key Natx cast * + @data addressToReference
    ];

    size: [indexSize dup isDynamic [new] when];
  }
];

makeArrayIter: [
  data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    SCHEMA_NAME: virtual "ArrayIter";
    data: @data;
    iterSize: size new;

    next: [
      @data
      iterSize 0 = ~ dup [
        @data storageAddress @data storageSize + @data addressToReference !data
        iterSize 1 - !iterSize
      ] when
    ];

    size: [iterSize new];
  }
];

makeArrayView: [
  data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    SCHEMA_NAME: virtual "ArrayView";
    data: @data;
    viewSize: size dup isDirtyOrDynamic [] [virtual] uif new;

    at: [
      key:;
      [key 0 viewSize within] "key is out of bounds" assert
      @data storageAddress @data storageSize key Natx cast * + @data addressToReference
    ];

    index: [@data viewSize makeArrayIndex];

    iter: [@data viewSize makeArrayIter];

    size: [viewSize dup isDynamic [new] when];

    slice: [
      offset: size:;;
      [offset 0 viewSize between] "offset is out of bounds" assert
      [size 0 viewSize offset - between] "size is out of bounds" assert
      @data storageAddress @data storageSize offset Natx cast * + @data addressToReference size makeArrayView
    ];
  }
];

toTextIter: [
  unwrap data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    SCHEMA_NAME: virtual "TextIter";
    data: @data;
    iterSize: size new;

    next: [
      @data
      iterSize 0 = ~ dup [
        @data storageAddress @data storageSize + @data addressToReference !data
        iterSize 1 - !iterSize
      ] when
    ];

    size: [iterSize new];
  }
];

toTextView: [
  unwrap data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    SCHEMA_NAME: virtual "TextView";
    data: @data;
    viewSize: size dup isDynamic [] [virtual] uif new;

    iter: [(@data viewSize) toTextIter];

    size: [viewSize dup isDynamic [new] when];

    slice: [
      offset: size:;;
      [offset 0 viewSize between] "offset is out of bounds" assert
      [size 0 viewSize offset - between] "size is out of bounds" assert
      (@data storageAddress @data storageSize offset Natx cast * + @data addressToReference size) toTextView
    ];
  }
];

makeTupleIndex: [
  tuple: offset: size:;;;
  [offset 0 @tuple fieldCount between] "offset is out of bounds" assert
  [size 0 @tuple fieldCount offset - between] "size is out of bounds" assert
  offset isDynamic [@tuple storageAddress 0 dynamic @tuple @ storageSize offset Natx cast * + 0 @tuple @ addressToReference size makeArrayIndex] [
    {
      SCHEMA_NAME: virtual "TupleIndex";
      tuple: @tuple;
      offset: virtual offset new;
      indexSize: size dup isDynamic [] [virtual] uif new;

      at: [
        key:;
        [key 0 indexSize within] "key is out of bounds" assert
        offset key + @tuple @
      ];

      size: [indexSize dup isDynamic [new] when];
    }
  ] if
];

makeTupleIter: [
  tuple: offset: size:;;;
  [offset 0 @tuple fieldCount between] "offset is out of bounds" assert
  [size 0 @tuple fieldCount offset - between] "size is out of bounds" assert
  offset isDynamic [@tuple storageAddress 0 dynamic @tuple @ storageSize offset Natx cast * + 0 @tuple @ addressToReference size makeArrayIter] [
    {
      SCHEMA_NAME: virtual "TupleIter";
      tuple: @tuple;
      offset0: offset new;
      offset1: offset0 size + dup isDynamic [] [virtual] uif new;

      next: [
        offset0 isDynamic [
          @tuple storageAddress
          @tuple 0 fieldIsRef [
            REF_SIZE Natx cast offset0 Natx cast * + 0 @tuple @ AsRef addressToReference .@data
          ] [
            0 dynamic @tuple @ storageSize offset0 Natx cast * + 0 @tuple @ addressToReference
          ] if
        ] [
          offset0 @tuple fieldCount < [offset0 @tuple @] [()] if
        ] if

        offset0 offset1 <
        offset0 1 + !offset0
      ];

      size: [offset1 offset0 -];
    }
  ] if
];

makeTupleView: [
  tuple: offset: size:;;;
  [offset 0 @tuple fieldCount between] "offset is out of bounds" assert
  [size 0 @tuple fieldCount offset - between] "size is out of bounds" assert
  offset isDynamic [@tuple storageAddress 0 dynamic @tuple @ storageSize offset Natx cast * + 0 @tuple @ addressToReference size makeArrayView] [
    {
      SCHEMA_NAME: virtual "TupleView";
      tuple: @tuple;
      viewOffset: virtual offset new;
      viewSize: size dup isDynamic [] [virtual] uif new;

      at: [
        key:;
        [key 0 viewSize within] "key is out of bounds" assert
        viewOffset key + @tuple @
      ];

      index: [@tuple viewOffset viewSize makeTupleIndex];

      iter: [@tuple viewOffset viewSize makeTupleIter];

      size: [viewSize dup isDynamic [new] when];

      slice: [
        offset: size:;;
        [offset 0 viewSize between] "offset is out of bounds" assert
        [size 0 viewSize offset - between] "size is out of bounds" assert
        @tuple viewOffset offset + size makeTupleView
      ];
    }
  ] if
];

toIndex: [
  source:;
  @source isBuiltinTuple [@source 0 @source fieldCount makeTupleIndex] [
    @source isIndex [@source dup "DIE" has ~ [new] when] [
      @source "index" has [@source.index] [
        "Built-in tuple, Index, or Indexable expected" raiseStaticError
      ] if
    ] if
  ] if
];

toIter: [
  source:;
  @source Text same [(source storageAddress Nat8 Cref addressToReference source textSize Int32 cast) toTextIter] [
    @source isBuiltinTuple [@source 0 @source fieldCount makeTupleIter] [
      @source isIter [@source @source @source isConst [copyable?] [movable?] if [new] when] [
        @source "iter" has [@source.iter] [
          "Built-in text, tuple, Iter, or Iterable expected" raiseStaticError
        ] if
      ] if
    ] if
  ] if
];

toView: [
  source:;
  @source Text same [(source storageAddress Nat8 Cref addressToReference source textSize Int32 cast) toTextView] [
    @source isBuiltinTuple [@source 0 @source fieldCount makeTupleView] [
      @source isView [@source dup "DIE" has ~ [new] when] [
        "Built-in tuple or View expected" raiseStaticError
      ] if
    ] if
  ] if
];

# Object iters
makeObjectIter: [{
  SCHEMA_NAME: virtual "ObjectIter";
  method: virtual;
  object:;
  offset: 0;

  next: [
    offset @object fieldCount = [
      {} FALSE
    ] [
      @object offset method
      offset 1 + !offset
      TRUE
    ] if
  ];

  size: [@object fieldCount offset -];
}];

objectFields: [[object: offset:;; {key: @object offset fieldName; value: @object offset fieldRead;}] makeObjectIter];
objectKeys:   [[object: offset:;; @object offset fieldName                                         ] makeObjectIter];
objectValues: [[object: offset:;; @object offset fieldRead                                         ] makeObjectIter];

# Comparison algorithms
<: [
  object0: object1:;;
  @object0 isCombined [
    @object0 "less" has [FALSE] [@object0 "greater" has ~] if
  ] [
    @object0 Text same
  ] if

  [
    @object1 isCombined [
      @object1 "less" has [FALSE] [@object1 "greater" has ~] if
    ] [
      @object1 Text same
    ] if
  ] [FALSE] if
] [
  iter0: iter1: toIter; toIter;
  result: FALSE;
  @iter0 "size" has [
    size0: @iter0.size;
    @iter1 "size" has [
      size1: @iter1.size;
      [
        size1 0 = [FALSE] [
          size0 0 = [TRUE !result FALSE] [
            item0: @iter0.next drop;
            item1: @iter1.next drop;
            @item0 @item1 < [TRUE !result FALSE] [
              @item0 @item1 = ~ [FALSE] [
                size0 1 - !size0
                size1 1 - !size1
                TRUE
              ] if
            ] if
          ] if
        ] if
      ] loop
    ] [
      [
        item1: @iter1.next swap; ~ [FALSE] [
          size0 0 = [TRUE !result FALSE] [
            item0: @iter0.next drop;
            @item0 @item1 < [TRUE !result FALSE] [
              @item0 @item1 = ~ [FALSE] [
                size0 1 - !size0
                TRUE
              ] if
            ] if
          ] if
        ] if
      ] loop
    ] if
  ] [
    @iter1 "size" has [
      size1: @iter1.size;
      [
        size1 0 = [FALSE] [
          item0: @iter0.next swap; ~ [TRUE !result FALSE] [
            item1: @iter1.next drop;
            @item0 @item1 < [TRUE !result FALSE] [
              @item0 @item1 = ~ [FALSE] [
                size1 1 - !size1
                TRUE
              ] if
            ] if
          ] if
        ] if
      ] loop
    ] [
      [
        item1: @iter1.next swap; ~ [FALSE] [
          item0: @iter0.next swap; ~ [TRUE !result FALSE] [
            @item0 @item1 < [TRUE !result FALSE] [
              @item0 @item1 =
            ] if
          ] if
        ] if
      ] loop
    ] if
  ] if

  result
] pfunc;

=: [
  object0: object1:;;
  @object0 isCombined [TRUE] [@object1 isCombined] if [
    @object0 "equal" has [FALSE] [
      @object1 "equal" has [FALSE] [
        TRUE
      ] if
    ] if
  ] [FALSE] if
] [
  iter0: iter1: toIter; toIter;
  result: FALSE;
  @iter0 "size" has [
    size0: @iter0.size;
    @iter1 "size" has [
      size1: @iter1.size;
      size0 size1 = ~ [] [
        [
          size1 0 = [TRUE !result FALSE] [
            @iter0.next drop @iter1.next drop = dup [size1 1 - !size1] when
          ] if
        ] loop
      ] if
    ] [
      [
        @iter1.next ~ [
          drop
          size0 0 = [TRUE !result] when
          FALSE
        ] [
          size0 0 = [drop FALSE] [
            @iter0.next drop swap = dup [size0 1 - !size0] when
          ] if
        ] if
      ] loop
    ] if
  ] [
    @iter1 "size" has [
      size1: @iter1.size;
      [
        size1 0 = [
          @iter0.next ~ [TRUE !result] when
          drop
          FALSE
        ] [
          @iter0.next ~ [drop FALSE] [
            @iter1.next drop = dup [size1 1 - !size1] when
          ] if
        ] if
      ] loop
    ] [
      [
        @iter1.next ~ [
          drop
          @iter0.next ~ [TRUE !result] when
          drop
          FALSE
        ] [
          @iter0.next ~ [drop drop FALSE] [swap =] if
        ] if
      ] loop
    ] if
  ] if

  result
] pfunc;

>: [
  object0: object1:;;
  @object0 isCombined [
    @object0 "less" has [FALSE] [@object0 "greater" has ~] if
  ] [
    @object0 Text same
  ] if

  [
    @object1 isCombined [
      @object1 "less" has [FALSE] [@object1 "greater" has ~] if
    ] [
      @object1 Text same
    ] if
  ] [FALSE] if
] [
  iter0: iter1: toIter; toIter;
  result: FALSE;
  @iter0 "size" has [
    size0: @iter0.size;
    @iter1 "size" has [
      size1: @iter1.size;
      [
        size0 0 = [FALSE] [
          size1 0 = [TRUE !result FALSE] [
            item0: @iter0.next drop;
            item1: @iter1.next drop;
            @item0 @item1 > [TRUE !result FALSE] [
              @item0 @item1 = ~ [FALSE] [
                size0 1 - !size0
                size1 1 - !size1
                TRUE
              ] if
            ] if
          ] if
        ] if
      ] loop
    ] [
      [
        size0 0 = [FALSE] [
          item1: @iter1.next swap; ~ [TRUE !result FALSE] [
            item0: @iter0.next drop;
            @item0 @item1 > [TRUE !result FALSE] [
              @item0 @item1 = ~ [FALSE] [
                size0 1 - !size0
                TRUE
              ] if
            ] if
          ] if
        ] if
      ] loop
    ] if
  ] [
    @iter1 "size" has [
      size1: @iter1.size;
      [
        item0: @iter0.next swap; ~ [FALSE] [
          size1 0 = [TRUE !result FALSE] [
            item1: @iter1.next drop;
            @item0 @item1 > [TRUE !result FALSE] [
              @item0 @item1 = ~ [FALSE] [
                size1 1 - !size1
                TRUE
              ] if
            ] if
          ] if
        ] if
      ] loop
    ] [
      [
        item0: @iter0.next swap; ~ [FALSE] [
          item1: @iter1.next swap; ~ [TRUE !result FALSE] [
            @item0 @item1 > [TRUE !result FALSE] [
              @item0 @item1 =
            ] if
          ] if
        ] if
      ] loop
    ] if
  ] if

  result
] pfunc;

beginsWith: [
  iter0: iter1: toIter; toIter;
  result: FALSE;
  @iter0 "size" has [
    size0: @iter0.size;
    @iter1 "size" has [
      size1: @iter1.size;
      size0 size1 < [] [
        [
          size1 0 = [TRUE !result FALSE] [
            @iter0.next drop @iter1.next drop = dup [size1 1 - !size1] when
          ] if
        ] loop
      ] if
    ] [
      [
        @iter1.next ~ [drop TRUE !result FALSE] [
          size0 0 = [drop FALSE] [
            @iter0.next drop swap = dup [size0 1 - !size0] when
          ] if
        ] if
      ] loop
    ] if
  ] [
    @iter1 "size" has [
      size1: @iter1.size;
      [
        size1 0 = [TRUE !result FALSE] [
          @iter0.next ~ [drop FALSE] [
            @iter1.next drop = dup [size1 1 - !size1] when
          ] if
        ] if
      ] loop
    ] [
      [
        @iter1.next ~ [drop TRUE !result FALSE] [
          @iter0.next ~ [drop drop FALSE] [swap =] if
        ] if
      ] loop
    ] if
  ] if

  result
];

compareBy: [
  iter0: iter1: comparator:; toIter; toIter;
  size0:  @iter0 "size" has [@iter0.size] [()] if;
  size1:  @iter1 "size" has [@iter1.size] [()] if;
  offset: size0 () same [size1 () same] || [0] [()] if;
  result: Int32;
  [
    offset Int32 same [
      size0 () same [size1 () same] && [
        [offset 0 < ~] "Offset is out of bounds" assert
      ] when

      offset 1 + !offset
    ] when

    item0: @iter0.next swap; [
      item1: @iter1.next swap; [
        diff: @item0 @item1 comparator;
        [diff int?] "Not an Int" assert
        0 diff cast diff = [
          diff diff storageSize Int32 storageSize > [sign] [Int32 cast] if !result FALSE
        ] ||
      ] [
        1 !result FALSE
      ] if
    ] [
      offset () same [size0 size1 -] [
        size1 () same [
          @iter1.next swap drop [-1] [0] if
        ] [
          offset 1 - size1 -
        ] if
      ] if !result

      FALSE
    ] if
  ] loop

  result
];

contains: [
  iter0: iter1:; toIter;
  size0: @iter0        "size" has [@iter0       .size] [@iter0 new    count] if;
  size1: @iter1 toIter "size" has [@iter1 toIter.size] [@iter1 toIter count] if;
  result: FALSE;
  size1 0 = [TRUE !result] [
    [
      size0 size1 < [FALSE] [
        @iter0.next drop
        iter1: @iter1 toIter;
        @iter1.next drop = ~ [TRUE] [
          iter0: @iter0 new;
          size1: size1 1 -;
          [
            size1 0 = [TRUE !result FALSE] [
              @iter0.next drop @iter1.next drop = dup [size1 1 - !size1] when
            ] if
          ] loop

          result ~
        ] if
      ] if

      dup [size0 1 - !size0] when
    ] loop
  ] if

  result
];

endsWith: [
  iter0: iter1: toIter; toIter;
  size0: @iter0 "size" has [@iter0.size] [@iter0 new count] if;
  size1: @iter1 "size" has [@iter1.size] [@iter1 new count] if;
  result: FALSE;
  size0 size1 < [] [
    size0 size1 - [@iter0.next drop drop] times
    [
      size1 0 = [TRUE !result FALSE] [
        @iter0.next drop @iter1.next drop = dup [size1 1 - !size1] when
      ] if
    ] loop
  ] if

  result
];

# Control combinators
case: [
  caseInternal: [
    value: descriptors: key:;;;
    key descriptors fieldCount 1 - = [
      key @descriptors @ call
    ] [
      value key descriptors @ = [
        key 1 + @descriptors @ call
      ] [
        value @descriptors key 2 + caseInternal
      ] if
    ] if
  ];

  0 caseInternal
];

cond: [
  condInternal: [
    value: descriptors: key:;;;
    key descriptors fieldCount 1 - = [
      key @descriptors @ call
    ] [
      @value key @descriptors @ call [
        key 1 + @descriptors @ call
      ] [
        @value @descriptors key 2 + condInternal
      ] if
    ] if
  ];

  0 condInternal
];

cond0: [
  cond0Internal: [
    descriptors: key:;;
    key descriptors fieldCount = ~ [
      key descriptors fieldCount 1 - = [
        key @descriptors @ call
      ] [
        key @descriptors @ call [
          key 1 + @descriptors @ call
        ] [
          @descriptors key 2 + cond0Internal
        ] if
      ] if
    ] when
  ];

  0 cond0Internal
];

# Iter producers
fibonacci: [
  {
    prev: swap new;
    current: new;

    next: [
      @prev @current + @current @prev set !current
      @prev new TRUE
    ];
  }
];

iota: [
  {
    current: new;

    next: [
      @current new
      @current 1 @current cast + !current
      TRUE
    ];
  }
];

# Iter transformers
countIter: [{
  source: swap toIter;
  count:;

  next: [
    @source.next dup [@count 1 @count cast + @count set] when
  ];

  @source "size" has [
    size: [@source.size];
  ] [] uif
}];

enumerate: [{
  source: swap toIter;
  key: new;

  next: [
    result: FALSE;
    {key: @key new; value: @source.next !result;}
    result dup [@key 1 @key cast + !key] when
  ];

  @source "size" has [
    size: [@source.size];
  ] [] uif
}];

filter: [{
  source: swap toIter;
  pred:;

  next: [
    value: ref?: result: @source.next; isRef;;
    result ~ [@value ref? ~ [new] when FALSE] [
      @value pred [@value ref? ~ [new] when TRUE] [
        @value ref? [AsRef] [new] if
        [
          drop
          value: @source.next !result;
          @value ref? [AsRef] when
          result [@value pred ~] [FALSE] if
        ] loop

        ref? [.@data] when
        result new
      ] if
    ] if
  ];
}];

headIter: [
  source: size: end:;;;
  [size 0 < ~] "invalid size" assert
  {
    source: @source toIter;

    @source "size" has [
      stopSize: size @source.size < [@source.size size -] [0] if dup isDynamic [] [virtual] uif new;
    ] [
      iterSize: size new;
    ] uif

    end: @end;

    next: [
      @source "size" has [
        @source.size stopSize = [end FALSE] [@source.next drop TRUE] if
      ] [
        iterSize 0 = [end FALSE] [
          @source.next dup [iterSize 1 - !iterSize] when
        ] if
      ] if
    ];

    @source "size" has [
      size: [@source.size stopSize -];
    ] [] uif
  }
];

joinIter: [
  sources: transform: end:;;;
  @sources wrapIter {
    transform: @transform;
    CALL: [unwrap transform];
  } @end map
];

map: [
  source: transform: end:;;;
  {
    source: @source toIter;
    transform: @transform;
    end: @end;

    next: [
      value: result: @source.next;; result [@value transform TRUE] [end FALSE] if
    ];

    @source "at" has [
      at: [@source.at transform];
    ] [] uif

    @source "size" has [
      size: [@source.size];
    ] [] uif
  }
];

wrapIter: [{
  sources: ([toIter] each);

  next: [
    @sources fieldCount 0 = [() FALSE] [
      result: TRUE;
      (
        @sources [
          .next ~ [FALSE !result] when
        ] each
      )

      result
    ] if
  ];

  @sources ["size" has] all [
    size: [
      @sources fieldCount 0 = [0] [
        0 @sources @ .size @sources fieldCount 1 - [i 1 + @sources @ .size min] times
      ] if
    ];
  ] [] uif
}];

# Iter processors
unhead: [drop isIter] [
  source: size: new;;
  [size 0 < ~] "invalid size" assert
  [
    size 0 = [FALSE] [
      @source.next swap drop dup [size 1 - !size] when
    ] if
  ] loop

  @source
] pfunc;

# Iter consumers
all: [swap toIter swap allStatic];
all: [drop toIter dynamic .next TRUE] [
  source: pred:; toIter;
  FALSE [
    drop @source.next [pred TRUE = FALSE swap] [drop TRUE FALSE] if
  ] loop
] pfunc;

allStatic: [
  source: pred:;;
  @source.next [
    pred [@source @pred allStatic] [FALSE] if
  ] [drop TRUE] if
];

any: [swap toIter swap anyStatic];
any: [drop toIter dynamic .next TRUE] [
  source: pred:; toIter;
  FALSE [
    drop @source.next [pred ~ TRUE swap] [drop FALSE FALSE] if
  ] loop
] pfunc;

anyStatic: [
  source: pred:;;
  @source.next [
    pred [TRUE] [@source @pred anyStatic] if
  ] [drop FALSE] if
];

count: [
  source: toIter;
  @source "size" has [@source.size] [
    itemCount: 0;
    [
      @source.next swap drop dup [itemCount 1 + !itemCount] when
    ] loop

    itemCount
  ] if
];

each: [
  source: consume:; toIter;
  [
    @source.next [consume TRUE] [drop FALSE] if
  ] loop
];

eachStaticInternal: [
  over .next [
    over ucall @eachStaticInternal ucall
  ] [
    drop drop drop
  ] uif
];

eachStatic: [
  swap toIter swap @eachStaticInternal ucall
];

find: [
  iter0: iter1:; toIter;
  size0: @iter0        "size" has [@iter0       .size] [@iter0 new    count] if;
  size1: @iter1 toIter "size" has [@iter1 toIter.size] [@iter1 toIter count] if;
  key: 0;
  size1 0 = [] [
    [
      size0 key - size1 < [size0 new !key FALSE] [
        @iter0.next drop
        iter1: @iter1 toIter;
        @iter1.next drop = ~ [TRUE] [
          iter0: @iter0 new;
          size1: size1 1 -;
          result: FALSE;
          [
            size1 0 = [TRUE !result FALSE] [
              @iter0.next drop @iter1.next drop = dup [size1 1 - !size1] when
            ] if
          ] loop

          result ~
        ] if
      ] if

      dup [key 1 + !key] when
    ] loop
  ] if

  key
];

findOneOf: [
  iter0: iter1:; toIter;
  size0: @iter0        "size" has [@iter0       .size] [@iter0 new    count] if;
  size1: @iter1 toIter "size" has [@iter1 toIter.size] [@iter1 toIter count] if;
  result: FALSE;
  resultSourceKey: size0 new;
  resultMatchKey: -1;
  size1 0 = [] [
    sourceKey: 0; [
      iter1: @iter1 toIter;
      matchKey: 0; [
        @iter0 new @iter1.next drop beginsWith [
          TRUE !result
          sourceKey new !resultSourceKey
          matchKey  new !resultMatchKey
          FALSE
        ] [
          matchKey 1 + !matchKey
          matchKey size1 = ~
        ] if
      ] loop

      result [FALSE] [
        sourceKey 1 + !sourceKey
        sourceKey size0 = ~ dup [@iter0.next drop drop] when
      ] if
    ] loop
  ] if

  resultSourceKey resultMatchKey
];

findOrdinal: [swap toIter swap 0 findOrdinalStatic];
findOrdinal: [drop toIter dynamic .next TRUE] [
  source: pred:; toIter;
  key: 0;
  [
    @source.next [
      pred ~ dup [key 1 + !key] when
    ] [drop -1 !key FALSE] if
  ] loop

  key
] pfunc;

findOrdinalStatic: [
  source: pred: key:;;;
  @source.next [
    pred [key new] [@source @pred key 1 + findOrdinalStatic] if
  ] [drop -1] if
];

meetsAll: [
  meetsAllInternal: [
    object: source:;;
    @source.next [
      @object swap call [@object @source meetsAllInternal] [FALSE] if
    ] [drop TRUE] if
  ];

  toIter meetsAllInternal
];

meetsAny: [
  meetsAnyInternal: [
    object: source:;;
    @source.next [
      @object swap call [TRUE] [@object @source meetsAnyInternal] if
    ] [drop FALSE] if
  ];

  toIter meetsAnyInternal
];

mutate: [
  source: transform:; toIter;
  [
    @source.next [dup transform swap set TRUE] [drop FALSE] if
  ] loop
];

# View slicers
slice: [
  view: offset: size:;; toView;
  [offset 0 @view.size between] "offset is out of bounds" assert
  [size 0 @view.size offset - between] "size is out of bounds" assert
  offset size @view.slice
];

range: [
  view: offset0: offset1:;; toView;
  [offset0 0 < ~] "offset0 is out of bounds" assert
  [offset1 offset0 @view.size between] "offset1 is out of bounds" assert
  offset0 offset1 offset0 - @view.slice
];

head: [
  view: size:; toView;
  [size 0 @view.size between] "size is out of bounds" assert
  0 size @view.slice
];

tail: [
  view: size:; toView;
  [size 0 @view.size between] "size is out of bounds" assert
  @view.size size - size @view.slice
];

unhead: [drop toView TRUE] [
  view: size:; toView;
  [size 0 @view.size between] "size is out of bounds" assert
  size @view.size size - @view.slice
] pfunc;

untail: [
  view: size:; toView;
  [size 0 @view.size between] "size is out of bounds" assert
  0 @view.size size - @view.slice
];
