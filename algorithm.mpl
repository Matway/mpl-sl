# Copyright (C) 2021 Matway Burkow
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
          @tuple storageAddress 0 dynamic @tuple @ storageSize offset0 Natx cast * + 0 @tuple @ addressToReference
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
      @source isIter [@source dup "DIE" has ~ [new] when] [
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

# Comparison algorithms
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
  sizeCheckable: @iter0 "size" has [@iter1 "size" has] &&;
  sizeCheckable ~ [@iter0.size @iter1.size =] || [
    result: FALSE;
    [
      @iter1.next [
        item:;
        @iter0.next sizeCheckable [drop TRUE] when [@item =] [drop FALSE] if
      ] [
        drop
        sizeCheckable [@iter0.next swap drop ~] || [TRUE !result] when
        FALSE
      ] if
    ] loop

    result
  ] &&
] pfunc;

beginsWith: [
  iter0: iter1: toIter; toIter;
  sizeCheckable: @iter0 "size" has [@iter1 "size" has] &&;
  sizeCheckable ~ [@iter0.size @iter1.size < ~] || [
    result: FALSE;
    [
      @iter1.next [
        item:;
        @iter0.next sizeCheckable [drop TRUE] when [@item =] [drop FALSE] if
      ] [
        drop
        TRUE !result
        FALSE
      ] if
    ] loop

    result
  ] &&
];

contains: [
  view0: view1: toView; toView;
  result: FALSE;
  i: 0; [
    @view0.size i - @view1.size < ~ [
      iter0: @view0 i unhead toIter;
      iter1: @view1 toIter;
      j: 0; [
        j view1.size = [TRUE !result FALSE] [
          @iter0.next drop @iter1.next drop = dup [j 1 + !j] when
        ] if
      ] loop

      result ~ dup [i 1 + !i] when
    ] &&
  ] loop

  @result
];

endsWith: [
  view0: view1: toView; toView;
  @view0.size @view1.size < ~ [
    result: FALSE;
    iter0: @view0 @view1.size tail toIter;
    iter1: @view1 toIter;
    i: 0; [
      i view1.size = [TRUE !result FALSE] [
        @iter0.next drop @iter1.next drop = dup [i 1 + !i] when
      ] if
    ] loop

    result
  ] &&
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
      value key @descriptors @ call [
        key 1 + @descriptors @ call
      ] [
        value @descriptors key 2 + condInternal
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

eachStatic: [
  eachStaticInternal: [
    over .next [
      over ucall @eachStaticInternal ucall
    ] [
      drop drop drop
    ] uif
  ];

  swap toIter swap @eachStaticInternal ucall
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
