# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"     use
"control.Int32"  use
"control.Int64"  use
"control.Real32" use
"control.Ref"    use
"control.drop"   use
"control.ensure" use
"control.swap"   use
"control.when"   use

"Function.Function"     use
"Function.makeFunction" use

Counter: [{
  assignCount: Int32;
  callCount:   Int32;
  dieCount:    Int32;
  initCount:   Int32;
}];

Object: [
  HAS_ASSIGN: HAS_CALL: HAS_DIE: HAS_INIT:;;;;
  {
    getCounter: virtual;
    Result:     Ref virtual;
    VIRTUAL:    new virtual;
    value:      new VIRTUAL [virtual] [] uif;

    HAS_ASSIGN [
      ASSIGN: [
        other:;
        @other.value new !value
        getCounter.assignCount 1 + getCounter.!assignCount
      ];
    ] [] uif

    HAS_CALL [
      CALL: [
        value0: value1:;;
        value Int32 cast value1 Int32 cast + Result cast
        VIRTUAL ~ [@closure isConst ~] && [
          value Int32 cast value0 Int32 cast + value cast !value
        ] when

        getCounter.callCount 1 + getCounter.!callCount
      ];
    ] [] uif

    HAS_DIE [
      DIE: [
        getCounter.dieCount 1 + getCounter.!dieCount
      ];
    ] [] uif

    HAS_INIT [
      INIT: [
        getCounter.initCount 1 + getCounter.!initCount
      ];
    ] [] uif
  }
];

Object0: [[@counter0] TRUE TRUE TRUE TRUE Object];
Object1: [[@counter1] TRUE TRUE TRUE TRUE Object];

counter0: Counter;
counter1: Counter;

clear: [
  counter:;
  0 @counter.!assignCount
  0 @counter.!callCount
  0 @counter.!dieCount
  0 @counter.!initCount
];

validate: [
  assignCount: callCount: dieCount: initCount: counter:;;;;;
  [counter.assignCount assignCount =] "Invalid assignment count"     ensure
  [counter.callCount   callCount   =] "Invalid call count"           ensure
  [counter.dieCount    dieCount    =] "Invalid death count"          ensure
  [counter.initCount   initCount   =] "Invalid initialization count" ensure
];

# Test Function constructor
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  [@function.hasContext ~] "Invalid Function state" ensure
] call

# Test Function.ASSIGN for codeRefs
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  code: {value1: Int64; value0: Int32;} Real32 {} codeRef; [swap drop Int32 cast 11 + Real32 cast] !code @code @function0.assign
  code: {value1: Int64; value0: Int32;} Real32 {} codeRef; [swap drop Int32 cast 13 + Real32 cast] !code @code @function1.assign

  @function0 const @function1 set
  17 19i64 function0 result:; [result 30.0r32 =] "Invalid Function data" ensure
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext] "Invalid Function state" ensure
  [@function1.hasContext] "Invalid Function state" ensure
] call

# Test Function.ASSIGN for distinct solid objects
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 FALSE Real32 Object0 @function0.assign
  13n64 FALSE Real32 Object1 @function1.assign
  @counter0 clear
  @counter1 clear

  @function0 const @function1 set
  17 19i64 function0 result:; [result 30.0r32 =] "Invalid Function data" ensure
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext] "Invalid Function state" ensure
  [@function1.hasContext] "Invalid Function state" ensure
  1 2 0 1 counter0 validate
  0 0 1 0 counter1 validate
] call

# Test Function.ASSIGN for distinct virtual objects
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 TRUE Real32 Object0 @function0.assign
  13n64 TRUE Real32 Object1 @function1.assign
  @counter0 clear
  @counter1 clear

  @function0 const @function1 set
  17 19i64 function0 result:; [result 30.0r32 =] "Invalid Function data" ensure
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext] "Invalid Function state" ensure
  [@function1.hasContext] "Invalid Function state" ensure
  0 2 0 1 counter0 validate
  0 0 1 0 counter1 validate
] call

# Test Function.ASSIGN for identical solid objects
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 FALSE Real32 Object0 @function0.assign
  13n32 FALSE Real32 Object0 @function1.assign
  @counter0 clear

  @function0 const @function1 set
  17 19i64 function0 result:; [result 30.0r32 =] "Invalid Function data" ensure
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext] "Invalid Function state" ensure
  [@function1.hasContext] "Invalid Function state" ensure
  1 2 0 0 counter0 validate
] call

# Test Function.ASSIGN for identical virtual objects
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 TRUE Real32 Object0 @function0.assign
  11n32 TRUE Real32 Object0 @function1.assign
  @counter0 clear

  @function0 const @function1 set
  17 19i64 function0 result:; [result 30.0r32 =] "Invalid Function data" ensure
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext] "Invalid Function state" ensure
  [@function1.hasContext] "Invalid Function state" ensure
  0 2 0 0 counter0 validate
] call

# Test Function.ASSIGN for non-initializable object
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 TRUE Real32 [@counter0] TRUE TRUE TRUE FALSE Object @function0.assign
  13n64 TRUE Real32 [@counter1] TRUE TRUE TRUE FALSE Object @function1.assign
  @counter0 clear
  @counter1 clear

  @function0 const @function1 set
  17 19i64 function0 result:; [result 30.0r32 =] "Invalid Function data" ensure
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext] "Invalid Function state" ensure
  [@function1.hasContext] "Invalid Function state" ensure
  0 2 0 0 counter0 validate
  0 0 1 0 counter1 validate
] call

# Test Function.DIE
[
  object: 11n32 FALSE Real32 Object0;

  [
    function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
    @object @function.assign
    @counter0 clear
  ] call

  0 0 1 0 counter0 validate
] call

# Test Function.INIT
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 FALSE Real32 Object0 @function.assign
  @function manuallyDestroyVariable
  @counter0 clear

  @function manuallyInitVariable
  [@function.hasContext ~] "Invalid Function state" ensure
  0 0 0 0 counter0 validate
] call

# Test Function.assign for codeRefs
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;

  code: {value1: Int64; value0: Int32;} Real32 {} codeRef; [swap drop Int32 cast 11 + Real32 cast] !code @code @function.assign
  code: {value1: Int64; value0: Int32;} Real32 {} codeRef; [swap drop Int32 cast 13 + Real32 cast] !code @code @function.assign
  17 19i64 function result:; [result 32.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
] call

# Test Function.assign for distinct solid object copy
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear
  @counter1 clear

  object: 11n32 FALSE Real32 Object0; @object const @function.assign
  object: 13n64 FALSE Real32 Object1; @object const @function.assign
  17 19i64 function result:; [result 32.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  1 0 1 1 counter0 validate
  1 1 0 1 counter1 validate
] call

# Test Function.assign for distinct solid object move
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear
  @counter1 clear

  11n32 FALSE Real32 Object0 @function.assign
  13n64 FALSE Real32 Object1 @function.assign
  17 19i64 function result:; [result 32.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 0 2 2 counter0 validate
  0 1 1 2 counter1 validate
] call

# Test Function.assign for distinct virtual object copy
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear
  @counter1 clear

  object: 11n32 TRUE Real32 Object0; @object const @function.assign
  object: 13n64 TRUE Real32 Object1; @object const @function.assign
  17 19i64 function result:; [result 32.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 0 1 1 counter0 validate
  0 1 0 1 counter1 validate
] call

# Test Function.assign for distinct virtual object move
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear
  @counter1 clear

  11n32 TRUE Real32 Object0 @function.assign
  13n64 TRUE Real32 Object1 @function.assign
  17 19i64 function result:; [result 32.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 0 1 1 counter0 validate
  0 1 0 1 counter1 validate
] call

# Test Function.assign for identical solid object copy
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear

  object: 11n32 FALSE Real32 Object0; @object const @function.assign
  object: 13n32 FALSE Real32 Object0; @object const @function.assign
  17 19i64 function result:; [result 32.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  2 1 0 1 counter0 validate
] call

# Test Function.assign for identical solid object move
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear

  11n32 FALSE Real32 Object0 @function.assign
  13n32 FALSE Real32 Object0 @function.assign
  17 19i64 function result:; [result 32.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 1 2 3 counter0 validate
] call

# Test Function.assign for identical virtual object copy
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear

  object: 11n32 TRUE Real32 Object0; @object const @function.assign
  object: 11n32 TRUE Real32 Object0; @object const @function.assign
  17 19i64 function result:; [result 30.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 1 0 1 counter0 validate
] call

# Test Function.assign for identical virtual object move
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear

  11n32 TRUE Real32 Object0 @function.assign
  11n32 TRUE Real32 Object0 @function.assign
  17 19i64 function result:; [result 30.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 1 0 1 counter0 validate
] call

# Test Function.assign for another Function copy
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 FALSE Real32 Object0 @function0.assign
  13n64 FALSE Real32 Object1 @function1.assign
  @counter0 clear
  @counter1 clear

  @function0 const @function1.assign
  17 19i64 function0 result:; [result 30.0r32 =] "Invalid Function data" ensure
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext] "Invalid Function state" ensure
  [@function1.hasContext] "Invalid Function state" ensure
  1 2 0 1 counter0 validate
  0 0 1 0 counter1 validate
] call

# Test Function.assign for another Function move
[
  function0: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  function1: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 FALSE Real32 Object0 @function0.assign
  13n64 FALSE Real32 Object1 @function1.assign
  @counter0 clear
  @counter1 clear

  @function0 @function1.assign
  23 29i64 function1 result:; [result 40.0r32 =] "Invalid Function data" ensure
  [@function0.hasContext ~] "Invalid Function state" ensure
  [@function1.hasContext  ] "Invalid Function state" ensure
  0 1 0 0 counter0 validate
  0 0 1 0 counter1 validate
] call

# Test Function.assign for non-assignable object
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  @counter0 clear

  11n32 FALSE Real32 [@counter0] FALSE TRUE TRUE TRUE Object @function.assign
  17 19i64 function result:; [result 30.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 1 1 2 counter0 validate
] call

# Test Function.release
[
  function: ({value1: Int64; value0: Int32;} Real32 {}) Function;
  11n32 FALSE Real32 Object0 @function.assign
  @counter0 clear

  @function.release
  [@function.hasContext ~] "Invalid Function state" ensure
  0 0 1 0 counter0 validate
] call

# Test makeFunction
[
  object: 11n32 FALSE Real32 Object0;
  @counter0 clear

  function: @object ({value1: Int64; value0: Int32;} Real32 {}) makeFunction;
  17 19i64 function result:; [result 30.0r32 =] "Invalid Function data" ensure
  [@function.hasContext] "Invalid Function state" ensure
  0 1 1 2 counter0 validate
] call
