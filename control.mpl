# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"conventions.cdecl" use

Cond:   [FALSE  v:; @v];
Int8:   [0i8    v:; @v];
Int16:  [0i16   v:; @v];
Int32:  [0      v:; @v];
Int64:  [0i64   v:; @v];
Intx:   [0ix    v:; @v];
Nat8:   [0n8    v:; @v];
Nat16:  [0n16   v:; @v];
Nat32:  [0n32   v:; @v];
Nat64:  [0n64   v:; @v];
Natx:   [0nx    v:; @v];
Real32: [0.0r32 v:; @v];
Real64: [0.0    v:; @v];
Text:   [""];

{format: Text;} Int32 {variadic: TRUE; convention: cdecl;} "printf" importFunction # need for assert
{result: 0;} () {convention: cdecl;} "exit" importFunction

REF_SIZE: [Natx storageSize Int32 cast];

# Object traits

assignable?: [
  v:;
  assignable?: [v:; FALSE];
  assignable?: {PRE: [v:; 1nx @v const addressToReference 1nx @v addressToReference set TRUE]; CALL: [v:; TRUE];};
  assignable?: {PRE: [v:; @v const @v set TRUE]; CALL: [v:; TRUE];};
  @v assignable?
];

automatic?: [
  v:;
  @v isCombined ~ [FALSE] [
    @v "DIE" has [TRUE] [
      i: 0; [
        i @v fieldCount = [FALSE FALSE] [
          @v i fieldIsRef ~ [@v i fieldRead automatic?] && [TRUE FALSE] [
            i 1 + !i
            TRUE
          ] if
        ] if
      ] loop
    ] if
  ] if
];

callable?: [
  v:;
  @v isCombined [
    @v "CALL" has
  ] [
    @v code? [TRUE] [
      @v codeRef?
    ] if
  ] if
];

compilable?: [
  v:;
  compilable?: [v:; FALSE];
  compilable?: {PRE: [call TRUE]; CALL: [v:; TRUE];};
  @v compilable?
];

copyable?: [
  v:;
  copyable?: [v:; FALSE];
  copyable?: {PRE: [v:; 1nx @v const addressToReference new TRUE]; CALL: [v:; TRUE];};
  copyable?: {PRE: [const new TRUE]; CALL: [v:; TRUE];};
  @v copyable?
];

creatable?: [
  v:;
  creatable?: [v:; FALSE];
  creatable?: {PRE: [newVarOfTheSameType TRUE]; CALL: [v:; TRUE];};
  @v creatable?
];

initializable?: [
  v:;
  initializable?: [v:; FALSE];
  initializable?: {PRE: [manuallyInitVariable TRUE]; CALL: [v:; TRUE];};
  @v initializable?
];

int?: [
  v:;
  @v 0i8 same [TRUE] [
    @v 0i16 same [TRUE] [
      @v 0i32 same [TRUE] [
        @v 0i64 same [TRUE] [
          @v 0ix same
        ] if
      ] if
    ] if
  ] if
];

movable?: [
  v:;
  @v isConst [FALSE] [
    movable?: [v:; FALSE];
    movable?: {PRE: [v:; 1nx @v addressToReference new TRUE]; CALL: [v:; TRUE];};
    movable?: {PRE: [new TRUE]; CALL: [v:; TRUE];};
    @v movable?
  ] if
];

nat?: [
  v:;
  @v 0n8 same [TRUE] [
    @v 0n16 same [TRUE] [
      @v 0n32 same [TRUE] [
        @v 0n64 same [TRUE] [
          @v 0nx same
        ] if
      ] if
    ] if
  ] if
];

nil?: [dup Ref is];

number?: [
  v:;
  @v int? [TRUE] [
    @v nat? [TRUE] [
      @v real?
    ] if
  ] if
];

real?: [
  v:;
  @v 0.0r32 same [TRUE] [
    @v 0.0r64 same
  ] if
];

ref?: [ # Should be ucall'ed to work
  isRef [v0:; v1:; v0 [TRUE] [FALSE] if] call
];

sized?: [
  v:;
  @v isCombined [TRUE] [
    @v TRUE same [TRUE] [
      @v number? [TRUE] [
        @v code?
      ] if
    ] if
  ] if
];

tuple?: [
  v:;
  @v isCombined ~ [FALSE] [
    i: 0; [
      i @v fieldCount = [TRUE FALSE] [
        @v i fieldName "" = ~ [FALSE FALSE] [
          i 1 + !i
          TRUE
        ] if
      ] if
    ] loop
  ] if
];

virtualizable?: [
  v:;
  virtualizable?: [v:; FALSE];
  virtualizable?: {PRE: [v:; 0nx @v addressToReference virtual v:; TRUE]; CALL: [v:; TRUE];};
  virtualizable?: {PRE: [virtual v:; TRUE]; CALL: [v:; TRUE];};
  @v virtualizable?
];

#

overload failProc: [
  print

  trace: getCallTrace;
  [
    trace storageAddress 0nx = [
      FALSE
    ] [
      (trace.name trace.line new trace.column new) " in %s at %i:%i\n\00" printf drop
      trace.prev trace addressToReference !trace
      TRUE
    ] if
  ] loop

  2 exit
];

pfunc: [{
  virtual CALL:;
  virtual PRE:;
}];

<: [drop "greater" has] [swap .greater] pfunc;
<: [     "less"    has] [     .less   ] pfunc;
=: [drop "equal"   has] [swap .equal  ] pfunc;
=: [     "equal"   has] [     .equal  ] pfunc;
>: [drop "less"    has] [swap .less   ] pfunc;
>: [     "greater" has] [     .greater] pfunc;

print: ["" same] [
  text:;
  text isStatic [
    (text "\00" &) "%s\00" printf drop
  ] [
    i: 0nx; [
      i text textSize = [FALSE] [
        (text storageAddress i + Nat8 addressToReference new) "%c\00" printf drop
        i 1nx + !i
        TRUE
      ] if
    ] loop
  ] if
] pfunc;

Ref:  [v:; 0nx @v       addressToReference]; # for signatures
Cref: [v:; 0nx @v const addressToReference]; # for signatures

reinterpret: [
  ref: Value:;;
  @ref storageAddress @Value @ref isConst [const] when addressToReference
];

AsRef: [{
  data:;
  CALL: @data callable? [[data]] [[@data]] if;
}];

forceConst: [v:; @v const];

drop: [v:;];

dup: [v:; @v @v];

swap: [v0: v1:;; @v1 @v0];

over: [v0: v1:;; @v0 @v1 @v0];

when: [[] if];

while: [
  condition: callable:;;

  [
    @condition ucall [
      @callable ucall
      TRUE
    ] [
      FALSE
    ] if
  ] loop
];

times: [
  count: callable:; new;
  overload i: 0;
  i count = [] [
    [
      @callable ucall
      i 1 + !i
      i count = ~
    ] loop
  ] if
];

ensure: [
  message:;
  call ~ dup isStatic [
    [message raiseStaticError] when
  ] [
    [message failProc] when
  ] if
];

assert: [
  DEBUG [
    ensure
  ] [
    predicate: message:;;
    assert: [];
    assert: [@predicate call dup isStatic [~] [drop FALSE] if] [message raiseStaticError] pfunc;
    assert
  ] if
];

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
  @value 0 @value cast < [@value neg] [@value new] if
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
  a: b:;;
  b a < [a] [b] if
];

min: [
  a: b:;;
  a b < [a] [b] if
];

clamp: [
  value: lower: upper:;;;
  value lower < [@lower] [
    upper value < [@upper] [@value] if
  ] if
];

between: [
  value: lower: upper:;;;
  value lower < ~ [upper value < ~] &&
];

within: [
  value: lower: upper:;;;
  value lower < ~ [value upper <] &&
];

bind: [{
  bindBody:  dup dup isConst [copyable?] [movable?] if [new] when;
  bindValue: dup dup isConst [copyable?] [movable?] if [new] when;

  CALL: [@bindValue @bindBody call];
}];

compose: [{
  composeBody1: dup dup isConst [copyable?] [movable?] if [new] when;
  composeBody0: dup dup isConst [copyable?] [movable?] if [new] when;

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

sequence: [
  callables:;
  iterate: [
    i callables fieldCount = [] [
      0 callables @ ucall ~ [] [
        i callables @ ucall
        i 1 + !i
        @iterate ucall
      ] if
    ] uif
  ];

  i: 1;
  @iterate ucall
];

keep: [
  object: body:;;
  @object body
  @object
];

touch: [count:; count 0 = ~ [value:; count 1 - touch @value] when];

unwrap: [list:; @list fieldCount [i @list @] times];

wrap: [(touch)];

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

hasSchemaName: [
  object: name:;;
  @object "SCHEMA_NAME" has [@object.@SCHEMA_NAME name =] &&
];
