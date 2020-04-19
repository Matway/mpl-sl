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

isIterator: [
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

asIterator: [
  object:;
  @object isIterator [@object] [
    @object "iterator" has [@object.iterator] [
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
          "Object cannot be used as iterator" raiseStaticError
        ] uif
      ] uif
    ] uif
  ] uif
];

asView: [
  object:;
  @object isView [@object] [
    @object isBuiltinTuple [
      view: [
        newIndex: newSize:;;
        {
          array: @array;
          index: index newIndex +;
          size: newSize copy;

          at: [index + @array @];

          view: @view;
        }
      ];

      array: @object; index: 0;
      0 @object fieldCount view
    ] [
      "Object cannot be used as view" raiseStaticError
    ] uif
  ] uif
];

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

# Simple iterator combinator
each: [
  eachIterator: eachBody:; asIterator;
  [
    @eachIterator.valid ~ [FALSE] [
      @eachIterator.get @eachBody ucall
      @eachIterator.next
      TRUE
    ] if
  ] loop
];

# Cond iterator combinators
all: [
  allIterator: allBody:;;
  @allIterator @allBody findNot .valid ~
];

any: [
  anyIterator: anyBody:;;
  @anyIterator @anyBody findIf .valid
];

# Iterator-returning iterator combinators
findIf: [
  findIfIterator: findIfBody:; asIterator;
  [
    @findIfIterator.valid ~ [FALSE] [
      @findIfIterator.get @findIfBody ucall [FALSE] [
        @findIfIterator.next
        TRUE
      ] if
    ] if
  ] loop

  @findIfIterator
];

findNot: [
  findNotIterator: findNotBody:;;
  @findNotIterator [@findNotBody ucall ~] findIf
];

findEqual: [
  findEqualIterator: findEqualValue:;;
  @findEqualIterator [@findEqualValue =] findIf
];

# Index iterator combinators
findIndexIf: [
  findIndexIfIterator: findIndexIfBody:; asIterator;
  findIndexIfIndex: 0;
  [
    @findIndexIfIterator.valid ~ [-1 !findIndexIfIndex FALSE] [
      @findIndexIfIterator.get @findIndexIfBody ucall [FALSE] [
        @findIndexIfIterator.next
        findIndexIfIndex 1 + !findIndexIfIndex
        TRUE
      ] if
    ] if
  ] loop

  findIndexIfIndex
];

findIndexNot: [
  findIndexNotIterator: findIndexNotBody:;;
  @findIndexNotIterator [@findIndexNotBody ucall ~] findIndexIf
];

findIndexEqual: [
  findIndexEqualIterator: findIndexEqualValue:;;
  @findIndexEqualIterator [@findIndexEqualValue =] findIndexIf
];

# Count iterator combinators
countIf: [
  countIfIterator: countIfBody:; asIterator;
  countIfCount: 0;
  [
    @countIfIterator.valid ~ [FALSE] [
      @countIfIterator.get @countIfBody ucall [
        countIfCount 1 + !countIfCount
      ] when

      @countIfIterator.next
      TRUE
    ] if
  ] loop

  countIfCount
];

countNot: [
  countNotIterator: countNotBody:; asIterator;
  @countNotIterator [@countNotBody ucall ~] countIf
];

countEqual: [
  countNotIterator: countNotValue:; asIterator;
  @countNotIterator [@countNotValue =] countIf
];
