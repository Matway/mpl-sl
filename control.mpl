"conventions" includeModule

Cond:   [v: FALSE  dynamic; @v];
Int8:   [v: 0i8    dynamic; @v];
Int16:  [v: 0i16   dynamic; @v];
Int32:  [v: 0i32   dynamic; @v];
Int64:  [v: 0i64   dynamic; @v];
Intx:   [v: 0ix    dynamic; @v];
Nat8:   [v: 0n8    dynamic; @v];
Nat16:  [v: 0n16   dynamic; @v];
Nat32:  [v: 0n32   dynamic; @v];
Nat64:  [v: 0n64   dynamic; @v];
Natx:   [v: 0nx    dynamic; @v];
Real32: [v: 0.0r32 dynamic; @v];
Real64: [v: 0.0r64 dynamic; @v];
Text:   [v: ""; @v];

{format: Text;} () {variadic: TRUE; convention: cdecl;} "printf" importFunction # need for assert
{result: 0;} () {convention: cdecl;} "exit" importFunction

pfunc: [{
  virtual CALL:;
  virtual PRE:;
}];

isCodeRef: [TRUE static];
isCodeRef: [storageSize TRUE static] [FALSE static] pfunc;

isCopyable: [drop FALSE];
isCopyable: [x:; @x storageSize 0nx > [@x Ref] [@x] uif copy TRUE] [drop TRUE] pfunc;

isDynamic: [drop TRUE];
isDynamic: [virtual v:; TRUE] [drop FALSE] pfunc;

=: ["equal" has] [item0: item1:;; @item0 @item1.equal] pfunc;

=: [item1:; "equal" has] [item0: item1:;; @item1 @item0.equal] pfunc;

print: ["" same] [
  text:;
  text isDynamic [
    i: 0nx dynamic; [
      i text textSize = [FALSE] [
        (text storageAddress i + Nat8 addressToReference copy) "%c\00" printf
        i 1nx + !i
        TRUE
      ] if
    ] loop
  ] [
    (text "\00" &) "%s\00" printf
  ] if
] pfunc;

failProc: [
  print

  trace: getCallTrace;
  [
    trace.first trace.last is [
      FALSE
    ] [
      () "\nin \00" printf
      trace.last.name print
      (trace.last.line copy trace.last.column copy) " at %i:%i\00" printf
      trace.last.prev trace.last addressToReference @trace.!last
      TRUE
    ] if
  ] loop

  2 exit
];

Ref: [v:; 0nx @v addressToReference]; # for signatures
Cref: [v:; 0nx v addressToReference]; # for signatures
AsRef: [{data:;}]; # for Ref Array

forceCopy: [isMoved moved:; v:; @v moved moveIf copy];

drop: [v:;];

dup: [v:; @v @v];

swap: [v0: v1:;; @v1 @v0];

when: [[] if];

while: [
  whileBody:;
  whileCondition:;

  [
    @whileCondition call [
      @whileBody call
      TRUE
    ] &&
  ] loop
];

times: [
  timesBody:; 0 cast timesCount:;
  i: timesCount timesCount -;
  i timesCount <
  [
    [
      @timesBody call
      i 1 + @i set
      i timesCount <
    ] loop
  ] when
];

assert: [
  DEBUG [
    message:;
    call ~ [
      message failProc
    ] when
  ] [
    message:; condition:;
  ] if
];

unconst: [copy a:; @a];

&&: [[FALSE] if];

||: [lazyOrIfFalse:; [TRUE] @lazyOrIfFalse if];

iterate: [
  x:;
  x 1 + @x set
  x >
];

riterate: [
  x:;
  x <
  x 1 - @x set
];

abs: [
  value:;
  @value 0 @value cast < [@value neg] [@value copy] if
];

sign: [
  value:;
  0 @value cast @value < [1] [
    @value 0 @value cast < [-1] [0] if
  ] if
];

sqr: [
  value:;
  value value *
];

max: [
  a:b:;;
  a b > [a][b] if
];

min: [
  a:b:;;
  a b < [a][b] if
];

between?: [
  value: lower: upper:;;;
  value lower < ~ [upper value < ~] &&
];

within?: [
  value: lower: upper:;;;
  value lower < ~ [value upper <] &&
];

isNil: [storageAddress 0nx =];

condImpl: [
  condIndex:;
  condFunctionList:;
  condControlVar:;

  condIndex condFunctionList fieldCount 1 - = [
    condIndex condFunctionList @ call
  ] [
    @condControlVar condIndex condFunctionList @ call [
      condIndex 1 + condFunctionList @ call
    ] [
      @condControlVar condFunctionList condIndex 2 + condImpl
    ] if
  ] if
];

cond: [0 static condImpl];

caseImpl: [
  copy caseIndex:;
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

bind: [{
  bindBody: isCodeRef [] [copy] uif;
  bindValue: isCodeRef [] [copy] uif;

  CALL: [@bindValue @bindBody call];
}];

compose: [{
  composeBody1: isCodeRef [] [copy] uif;
  composeBody0: isCodeRef [] [copy] uif;

  CALL: [@composeBody0 call @composeBody1 call];
}];

for: [
  forBody:;
  forIterate:;
  forCond:;
  forInit:;

  @forInit ucall
  [
    @forCond ucall [
      @forBody call
      @forIterate ucall
      TRUE
    ] [
      FALSE
    ] if
  ] loop
];

sequenceImpl: [
  copy sequenceIndex:;
  sequenceList:;
  sequenceIndex sequenceList fieldCount < [0 static sequenceList @ call] && [
    sequenceIndex sequenceList @ ucall
    sequenceList sequenceIndex 1 + sequenceImpl
  ] when
];

sequence: [
  1 static sequenceImpl
];

unwrap: [list:; list fieldCount [i @list @] times];

enum: [
  enum_names:enum_type:;;
  enum_index: 0;
  enum_uloop: [
    enum_index enum_names fieldCount < [
      enum_index enum_type cast enum_index enum_names @ virtual def
      enum_index 1 + !enum_index
      @enum_uloop ucall
    ] [] uif
  ];
  {@enum_uloop ucall}
];

# Collections

!: ["at" has] [.at set] pfunc;

@: ["at" has] [.at] pfunc;

isBuiltinTuple: [
  object:;
  @object isCombined [@object () same [@object 0 fieldName "" =] ||] &&
];

isIndexable: [
  object:;
  @object "at" has [@object "size" has] &&
];

isIter: [
  object:;
  @object "next" has [@object "valid" has] &&
];

isView: [
  object:;
  @object "size" has [@object "view" has] &&
];

asIndexable: [
  object:;
  @object isIndexable [@object] [
    @object isBuiltinTuple [
      {
        tuple: @object;

        at: [@tuple @];

        size: [@tuple fieldCount];
      }
    ] [
      "Object cannot be used as indexable" raiseStaticError
    ] uif
  ] uif
];

toIter: [
  object:;
  @object isIter [@object copy] [
    @object "iter" has [@object.iter] [
      @object isIndexable [
        @object isView [
          {
            indexableView: 0 @object.size @object.view;

            valid: [@indexableView.size 0 = ~];
            get: [0 @indexableView.at];
            next: [1 @indexableView.size 1 - @indexableView.view !indexableView];
          }
        ] [
          {
            indexable: @object;
            index: 0;

            valid: [index @indexable.size = ~];
            get: [index @indexable.at];
            next: [index 1 + !index];
          }
        ] uif
      ] [
        @object isBuiltinTuple [
          {
            tuple: @object;
            index: 0;

            valid: [index @tuple fieldCount = ~];
            get: [index @tuple @];
            next: [index 1 + !index];
          }
        ] [
          "Object cannot be used as iter" raiseStaticError
        ] uif
      ] uif
    ] uif
  ] uif
];

asView: [isBuiltinTuple] [
  tuple:;
  view: [
    newIndex: newSize:;;
    {
      tuple: @tuple;
      index: index newIndex +;
      size: newSize copy;

      at: [index + @tuple @];

      view: @view;
    }
  ];

  index: 0;
  0 @tuple fieldCount view
] pfunc;

asView: [isView] [] pfunc;

=: [item0: item1:;; @item0 "equal" has ~ [@item1 "equal" has ~ [@item0 isIndexable [@item0 isBuiltinTuple] || [@item1 isIndexable [@item1 isBuiltinTuple] ||] &&] &&] &&] [
  item0: item1: asIndexable; asIndexable;
  @item0.size @item1.size = ~ [FALSE] [
    result: TRUE;
    i: 0; [
      i @item0.size = [FALSE] [
        i @item0.at i @item1.at = ~ [FALSE !result FALSE] [
          i 1 + !i TRUE
        ] if
      ] if
    ] loop

    result
  ] if
] pfunc;

view: [
  view: index: size:;; asView;
  index size @view.view
];

range: [
  view: index0: index1:;; asView;
  index0 index1 index0 - @view.view
];

head: [
  view: size:; asView;
  0 size @view.view
];

tail: [
  view: size:; asView;
  @view.size size - size @view.view
];

unhead: [
  view: size:; asView;
  size @view.size size - @view.view
];

untail: [
  view: size:; asView;
  0 @view.size size - @view.view
];

# Simple iter combinators
each: [
  eachIter: eachBody:; toIter;
  [
    @eachIter.valid ~ [FALSE] [
      @eachIter.get eachBody
      @eachIter.next
      TRUE
    ] if
  ] loop
];

mutate: [
  mutateIter: mutateBody:; toIter;
  [
    @mutateIter.valid ~ [FALSE] [
      @mutateIter.get mutateBody @mutateIter.get set
      @mutateIter.next
      TRUE
    ] if
  ] loop
];

# Cond iter combinators
all: [
  allIter: allBody:;;
  @allIter @allBody findNot .valid ~
];

any: [
  anyIter: anyBody:;;
  @anyIter @anyBody findIf .valid
];

# Iter-returning iter combinators
findIf: [
  findIfIter: findIfBody:; toIter;
  [
    @findIfIter.valid ~ [FALSE] [
      @findIfIter.get findIfBody [FALSE] [
        @findIfIter.next
        TRUE
      ] if
    ] if
  ] loop

  @findIfIter
];

findNot: [
  findNotIter: findNotBody:;;
  @findNotIter [findNotBody ~] findIf
];

findEqual: [
  findEqualIter: findEqualValue:;;
  @findEqualIter [@findEqualValue =] findIf
];

# Index iter combinators
findIndexIf: [
  findIndexIfIter: findIndexIfBody:; toIter;
  findIndexIfIndex: 0;
  [
    @findIndexIfIter.valid ~ [-1 !findIndexIfIndex FALSE] [
      @findIndexIfIter.get findIndexIfBody [FALSE] [
        @findIndexIfIter.next
        findIndexIfIndex 1 + !findIndexIfIndex
        TRUE
      ] if
    ] if
  ] loop

  findIndexIfIndex
];

findIndexNot: [
  findIndexNotIter: findIndexNotBody:;;
  @findIndexNotIter [findIndexNotBody ~] findIndexIf
];

findIndexEqual: [
  findIndexEqualIter: findIndexEqualValue:;;
  @findIndexEqualIter [@findIndexEqualValue =] findIndexIf
];

# Count iter combinators
countIf: [
  countIfIter: countIfBody:; toIter;
  countIfCount: 0;
  [
    @countIfIter.valid ~ [FALSE] [
      @countIfIter.get countIfBody [
        countIfCount 1 + !countIfCount
      ] when

      @countIfIter.next
      TRUE
    ] if
  ] loop

  countIfCount
];

countNot: [
  countNotIter: countNotBody:;;
  @countNotIter [countNotBody ~] countIf
];

countEqual: [
  countNotIter: countNotValue:;;
  @countNotIter [@countNotValue =] countIf
];

# Lazy iter combinators
applyIter: [{
  applyIterSource: applyIterBody:; toIter;

  valid: [@applyIterSource.valid];
  get:   [@applyIterSource.get applyIterBody];
  next:  [@applyIterSource.next];
}];

filterIter: [{
  filterIterSource: filterIterBody:; toIter;

  valid: [@filterIterSource @filterIterBody findIf !filterIterSource @filterIterSource.valid];
  get:   [@filterIterSource.get ];
  next:  [@filterIterSource.next];
}];

wrapIter: [{
  wrapIterSources: ([toIter] each);

  valid: [@wrapIterSources [.valid] all   ];
  get:   [@wrapIterSources [.get  ] (each)];
  next:  [@wrapIterSources [.next ] each  ];
}];

joinIter: [
  joinIterSources: joinIterBody:;;
  @joinIterSources wrapIter [unwrap] applyIter @joinIterBody applyIter
];
