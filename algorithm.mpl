# Collection access interfaces

# Index
#   at ( key -- item ) get the contained item either by value or by reference
#   size ( -- size ) return the number of items in the Index
#
# An Index gives random access to items of a collection of known size using the 'at' method.
# Different Index types can return items by read-only reference, read-write reference, or by value.
# Trying to get an item outside the bounds of the Index is undefined behavior.

# Iter
#   get ( -- item ) get the item referenced by Iter by value or by reference
#   next ( -- ) skip to the next item
#   valid ( -- cond ) report whether access to the item is allowed or Iter has reached the end of the collection
#
# An Iter provides access to the collection with the ability to work with items one at a time.
# Iter is unidirectional - you can go to the next item but you cannot go back to the past.
# Method 'valid' lets you know if an item is available or if the Iter has reached the end of the collection.
# If the item is available ('valid' returned TRUE), it is allowed to get the item using the 'get' method.
# If 'valid' returned FALSE, calling the 'get' method is undefined behavior.
# Different Iter types can return items by read-only reference, read-write reference, or by value.
# The 'get' method can be called many times on the same item, but keep in mind that for some Iter types this entails a potentially time-consuming computation of the item each time the 'get' method is called.
# Use the 'next' method to move to the next item.
# When moving to the next item, the Iter changes its internal state.
# Attempting to call the 'next' method if the Iter has already reached the end of the collection ('valid' returns FALSE) is undefined behavior.

# Iterable
#   iter ( -- iter ) create an Iter that allows you to list all contained items, from first to last
#
# The Iterable interface allows you to create a new Iter to access the collection sequentially.

# ReverseIterable
#   reverseIter ( -- iter ) create an Iter that allows you to list all contained items, from last to first
#
# The ReverseIterable interface allows you to create a new Iter to access the collection sequentially.

# View
#   size ( -- size ) return the size of the View, which does not necessarily match the number of items
#   slice ( offset size -- view ) create a View with an offset from the current and another size
#
# A View provides access to a collection of a known size.
# The size of a View is measured in logical units and is not necessarily equal to the number of items.
# A mandatory function of View is to create a new View, potentially smaller, using the 'view' method.
# Trying to create a new View that goes beyond the current one is undefined behavior.
# A View itself does not provide access to items, but other interfaces such as Index or Iterable can provide it.

"control.&&"             use
"control.="              use
"control.Int32"          use
"control.Nat8"           use
"control.Natx"           use
"control.Text"           use
"control.assert"         use
"control.between"        use
"control.drop"           use
"control.dup"            use
"control.isBuiltinTuple" use
"control.new"            use
"control.pfunc"          use
"control.swap"           use
"control.unwrap"         use
"control.when"           use
"control.while"          use
"control.||"             use

# Predicates
isIndex: [
  object:;
  @object "at" has [@object "size" has] &&
];

isIter: [
  object:;
  @object "get" has [@object "next" has [@object "valid" has] &&] &&
];

isView: [
  object:;
  @object "size" has [@object "slice" has] &&
];

# Built-in array, text, and tuple support
makeArrayIndex: [
  data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    data: @data;
    indexSize: size dup isDynamic [] [virtual] uif new;

    at: [
      key:;
      [key 0 indexSize between] "key is out of bounds" assert
      @data storageAddress @data storageSize key Natx cast * + @data addressToReference
    ];

    iter: [@data indexSize makeArrayIter];

    size: [indexSize new];

    slice: [@data indexSize makeArrayView .slice];
  }
];

makeArrayIter: [
  data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    SCHEMA_NAME: virtual "ArrayIter";
    data: @data;
    iterSize: size new;

    get: [
      [valid] "Iter is not valid" assert
      @data
    ];

    index: [@data iterSize makeArrayIndex];

    next: [
      [valid] "Iter is not valid" assert
      @data storageAddress @data storageSize + @data addressToReference !data
      iterSize 1 - !iterSize
    ];

    size: [iterSize new];

    slice: [@data iterSize makeArrayView .slice];

    valid: [iterSize 0 = ~];
  }
];

makeArrayView: [
  data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    data: @data;
    viewSize: size dup new isDynamic [] [virtual] uif new;

    index: [@data viewSize makeArrayIndex];

    iter: [@data viewSize makeArrayIter];

    size: [viewSize new];

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

    get: [
      [valid] "Iter is not valid" assert
      @data
    ];

    next: [
      [valid] "Iter is not valid" assert
      @data storageAddress @data storageSize + @data addressToReference !data
      iterSize 1 - !iterSize
    ];

    size: [iterSize new];

    valid: [iterSize 0 = ~];
  }
];

toTextView: [
  unwrap data: size:;;
  [size 0 < ~] "invalid size" assert
  {
    SCHEMA_NAME: virtual "TextView";
    data: @data;
    viewSize: size dup new isDynamic [] [virtual] uif new;

    iter: [(@data viewSize) toTextIter];

    size: [viewSize new];

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
  offset isDynamic [offset @tuple @ size makeArrayIndex] [
    {
      tuple: @tuple;
      offset: virtual offset new;
      indexSize: size dup isDynamic [] [virtual] uif new;

      at: [
        key:;
        [key 0 indexSize between] "key is out of bounds" assert
        offset key + @tuple @
      ];

      iter: [@tuple offset indexSize makeTupleIter];

      size: [indexSize new];

      slice: [@tuple offset indexSize makeTupleView .slice];
    }
  ] if
];

makeTupleIter: [
  tuple: offset: size:;;;
  [offset 0 @tuple fieldCount between] "offset is out of bounds" assert
  [size 0 @tuple fieldCount offset - between] "size is out of bounds" assert
  offset isDynamic [offset @tuple @ size makeArrayIter] [
    {
      tuple: @tuple;
      offset0: offset new;
      offset1: offset0 size + dup isDynamic [] [virtual] uif new;

      get: [
        [valid] "Iter is not valid" assert
        offset0 @tuple @
      ];

      index: [@tuple offset0 size makeTupleIndex];

      next: [
        [valid] "Iter is not valid" assert
        offset0 1 + !offset0
      ];

      size: [offset1 offset0 -];

      slice: [@tuple offset0 size makeTupleView .slice];

      valid: [offset0 offset1 = ~];
    }
  ] if
];

makeTupleView: [
  tuple: offset: size:;;;
  [offset 0 @tuple fieldCount between] "offset is out of bounds" assert
  [size 0 @tuple fieldCount offset - between] "size is out of bounds" assert
  offset isDynamic [offset @tuple @ size makeArrayView] [
    {
      tuple: @tuple;
      viewOffset: virtual offset new;
      viewSize: size dup isDynamic [] [virtual] uif new;

      index: [@tuple viewOffset viewSize makeTupleIndex];

      iter: [@tuple viewOffset viewSize makeTupleIter];

      size: [viewSize new];

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
  @source Text same [(source storageAddress Nat8 addressToReference source textSize Int32 cast) toTextIter] [
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
  @source Text same [(source storageAddress Nat8 addressToReference source textSize Int32 cast) toTextView] [
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
        @object0 toIter drop
        @object1 toIter drop
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
      @iter1.valid ~ [
        sizeCheckable [@iter0.valid ~] || [TRUE !result] when
        FALSE
      ] [
        sizeCheckable [@iter0.valid] || [
          @iter0.get @iter1.get = dup [@iter0.next @iter1.next] when
        ] &&
      ] if
    ] loop

    result
  ] &&
] pfunc;

beginsWith: [
  iter0: iter1: toIter; toIter;
  sizeCheckable: @iter0 "size" has [@iter1 "size" has] &&;
  sizeCheckable [@iter0.size @iter1.size <] && ~ [
    result: FALSE;
    [
      @iter1.valid ~ [TRUE !result FALSE] [
        sizeCheckable [@iter0.valid] || [
          @iter0.get @iter1.get = dup [@iter0.next @iter1.next] when
        ] &&
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
          @iter0.get @iter1.get = dup [@iter0.next @iter1.next j 1 + !j] when
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
        @iter0.get @iter1.get = dup [@iter0.next @iter1.next i 1 + !i] when
      ] if
    ] loop

    result
  ] &&
];

# Iter producers
fibonacci: [
  {
    prev: current: new; new;
    get: [@current new];
    next: [@prev @current + @current @prev set !current];
    valid: [TRUE];
  }
];

iota: [
  {
    current: new;
    get: [@current new];
    next: [@current 1 @current cast + !current];
    valid: [TRUE];
  }
];

# Control combinators
condImpl: [
  condIndex:;
  condFunctionList:;
  condControlVar:;

  condIndex condFunctionList fieldCount 1 - = [
    condIndex @condFunctionList @ call
  ] [
    @condControlVar condIndex condFunctionList @ call [
      condIndex 1 + @condFunctionList @ call
    ] [
      @condControlVar @condFunctionList condIndex 2 + condImpl
    ] if
  ] if
];

cond: [0 static condImpl];

caseImpl: [
  caseIndex:;
  caseFunctionList:;
  caseControlVar:;

  caseIndex caseFunctionList fieldCount 1 - = [
    caseIndex caseFunctionList @ call
  ] [
    caseControlVar caseIndex caseFunctionList @ = [
      caseIndex 1 + caseFunctionList @ call
    ] [
      caseControlVar caseFunctionList caseIndex 2 + caseImpl
    ] if
  ] if
];

case: [0 static caseImpl];

# Iter processors
find: [swap toIter swap findStatic];
find: [drop toIter dynamic .get TRUE] [
  iter: body:; toIter;
  [@iter.valid [@iter.get body ~] &&] [@iter.next] while
  @iter
] pfunc;

findStatic: [
  iter: body:;;
  @iter.valid [@iter.get body ~] && ~ [@iter] [
    @iter.next
    @iter @body findStatic
  ] if
];

findEqual: [
  iter: value:;;
  @iter [@value =] find
];

findEqualNot: [
  iter: value:;;
  @iter [@value = ~] find
];

# Iter transformers
countIter: [{
  source: swap toIter;
  count:;

  get:   [@source.get];
  next:  [@source.next count 1 + @count set];
  valid: [@source.valid];

  @source "size" has [
    size: [@source.size];
  ] [] uif
}];

enumerate: [{
  source: toIter;
  key: 0;

  valid: [@source.valid];
  get:   [{key: key new; value: @source.get;}];
  next:  [@source.next key 1 + !key];
}];

filter: [
  source: body:;;
  {
    source: @source @body find;
    body: @body;

    get: [@source.get];
    next: [@source.next @source @body find !source];
    valid: [@source.valid];
  }
];

joinIter: [
  sources: body:;;
  @sources wrapIter [unwrap] map @body map
];

map: [{
  source: body:; toIter;

  valid: [@source.valid];
  get:   [@source.get body];
  next:  [@source.next];

  @source "size" has [
    size: [@source.size];
  ] [] uif
}];

wrapIter: [{
  sources: ([toIter] each);

  valid: [@sources [.valid] all   ];
  get:   [@sources [.get  ] (each)];
  next:  [@sources [.next ] each  ];
}];

# Iter consumers
all: [swap toIter swap allStatic];
all: [drop toIter dynamic .get TRUE] [
  iter: body:; toIter;
  result: TRUE;
  [
    @iter.valid ~ [FALSE] [
      @iter.get body [@iter.next TRUE] [FALSE !result FALSE] if
    ] if
  ] loop

  @result
] pfunc;

allStatic: [
  iter: body:;;
  @iter.valid ~ [TRUE] [
    @iter.get body ~ [FALSE] [
      @iter.next
      @iter @body allStatic
    ] if
  ] if
];

any: [swap toIter swap anyStatic];
any: [drop toIter dynamic .get TRUE] [
  iter: body:; toIter;
  result: FALSE;
  [
    @iter.valid ~ [FALSE] [
      @iter.get body ~ dup [@iter.next] [TRUE !result] if
    ] if
  ] loop

  @result
] pfunc;

anyStatic: [
  iter: body:;;
  @iter.valid ~ [FALSE] [
    @iter.get body [TRUE] [
      @iter.next
      @iter @body anyStatic
    ] if
  ] if
];

count: [
  iter: body:; toIter;
  count: 0;
  [@iter.valid] [
    @iter.get body [count 1 + !count] when
    @iter.next
  ] while

  @count
];

countEqual: [
  iter: value:;;
  @iter [@value =] count
];

countEqualNot: [
  iter: value:;;
  @iter [@value = ~] count
];

each: [
  iter: body:; toIter;
  [@iter.valid] [
    @iter.get body
    @iter.next
  ] while
];

findIndex: [swap toIter swap 0 findIndexStatic];
findIndex: [drop toIter dynamic .get TRUE] [
  iter: body:; toIter;
  index: 0;
  [
    @iter.valid ~ [-1 !index FALSE] [
      @iter.get body ~ dup [
        @iter.next
        index 1 + !index
      ] when
    ] if
  ] loop

  @index
] pfunc;

findIndexStatic: [
  iter: body: index:;;;
  @iter.valid ~ [-1] [
    @iter.get body [index new] [
      @iter.next
      @iter @body index 1 + findIndexStatic
    ] if
  ] if
];

findIndexEqual: [
  iter: value:;;
  @iter [@value =] findIndex
];

findIndexEqualNot: [
  iter: value:;;
  @iter [@value = ~] findIndex
];

meetsAll: [toIter meetsAllStatic];
meetsAll: [toIter dynamic .get TRUE] [
  object: iter: toIter;;
  result: TRUE;
  [
    @iter.valid ~ [FALSE] [
      @object @iter.get call [@iter.next TRUE] [FALSE !result FALSE] if
    ] if
  ] loop

  @result
] pfunc;

meetsAllStatic: [
  object: iter:;;
  @iter.valid ~ [TRUE] [
    @object @iter.get call ~ [FALSE] [
      @iter.next
      @object @iter meetsAllStatic
    ] if
  ] if
];

meetsAny: [toIter meetsAnyStatic];
meetsAny: [toIter dynamic .get TRUE] [
  object: iter: toIter;;
  result: FALSE;
  [
    @iter.valid ~ [FALSE] [
      @object @iter.get call ~ dup [@iter.next] [TRUE !result] if
    ] if
  ] loop

  @result
] pfunc;

meetsAnyStatic: [
  object: iter:;;
  @iter.valid ~ [FALSE] [
    @object @iter.get call [TRUE] [
      @iter.next
      @object @iter meetsAnyStatic
    ] if
  ] if
];

mutate: [
  iter: body:; toIter;
  [@iter.valid] [
    @iter.get body @iter.get set
    @iter.next
  ] while
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

unhead: [
  view: size:; toView;
  [size 0 @view.size between] "size is out of bounds" assert
  size @view.size size - @view.slice
];

untail: [
  view: size:; toView;
  [size 0 @view.size between] "size is out of bounds" assert
  0 @view.size size - @view.slice
];
