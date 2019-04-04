"control" module
"conventions" includeModule

func: {
  virtual CALL: [{
    virtual CALL:;
  }];
};

failProc: [
  storageAddress printAddr
  2 exit
] func;

Cond:   [v: FALSE  dynamic; @v] func;
Int8:   [v: 0i8    dynamic; @v] func;
Int16:  [v: 0i16   dynamic; @v] func;
Int32:  [v: 0i32   dynamic; @v] func;
Int64:  [v: 0i64   dynamic; @v] func;
Intx:   [v: 0ix    dynamic; @v] func;
Nat8:   [v: 0n8    dynamic; @v] func;
Nat16:  [v: 0n16   dynamic; @v] func;
Nat32:  [v: 0n32   dynamic; @v] func;
Nat64:  [v: 0n64   dynamic; @v] func;
Natx:   [v: 0nx    dynamic; @v] func;
Real32: [v: 0.0r32 dynamic; @v] func;
Real64: [v: 0.0r64 dynamic; @v] func;
Text:   [v: ""     dynamic; @v] func;

Ref: [v:; 0nx @v addressToReference] func; # for signatures
Cref: [v:; 0nx v addressToReference] func; # for signatures
AsRef: [{data:;}] func; # for Ref Array

{format: Text;} () {variadic: TRUE; convention: cdecl;} "printf" importFunction # need for assert
{result: 0;} () {convention: cdecl;} "exit" importFunction

pfunc: [{
  CALL:;
  PRE:;
}] func;

drop: [v:;] func;

when: [[] if] func;

printAddr: [
  copy addr:;
  addr 0nx = not [(addr copy) "%s" printf] when
] func;

while: [
  whileBody:;
  whileCondition:;

  [
    @whileCondition call [
      @whileBody call
      TRUE
    ] &&
  ] loop
] func;

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
] func;

assert: [
  DEBUG [
    copy message:;
    call not [
      message failProc
    ] when
  ] [
    copy message:; condition:;
  ] if
] func;

unconst: [copy a:; @a] func;

&&: [[FALSE] if] func;
||: [lazyOrIfFalse:; [TRUE] lazyOrIfFalse if] func;

iterate: [
  x:;
  x 1 + @x set
  x >
] func;

riterate: [
  x:;
  x <
  x 1 - @x set
] func;

max: [
  a:b:;;
  a b > [a][b] if
] func;

min: [
  a:b:;;
  a b < [a][b] if
] func;

# usage:
#
# (
#   [1 =] ["one"]
#   [2 =] ["two"]
#   ["unknown"]
# ) cond

isNil: [storageAddress 0nx =] func;

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
] func;

cond: [0 static condImpl] func;

# usage:
#
# 2 dynamic
# (
#   0 ["zero"]
#   1 ["one"]
#   2 ["two"]
#   ["unknown"]
# ) case

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
] func;

case: [0 static caseImpl] func;

bind: [{
  bindValue: bindBody:;;
  CALL: [@bindValue @bindBody call];
}] func;

compose: [{
  composeBody0: composeBody1:;;
  CALL: [@composeBody0 call @composeBody1 call];
}] func;

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
] func;

sequenceImpl: [
  copy sequenceIndex:;
  sequenceList:;
  sequenceIndex sequenceList fieldCount < [0 static sequenceList @ call] && [
    sequenceIndex sequenceList @ ucall
    sequenceList sequenceIndex 1 + sequenceImpl
  ] when
] func;

sequence: [
  1 static sequenceImpl
] func;

unwrap: [list:; list fieldCount [i @list @] times] func;
