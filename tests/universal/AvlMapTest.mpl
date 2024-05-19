# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.="         use
"control.Int32"     use
"control.Natx"      use
"control.between"   use
"control.callable?" use
"control.drop"      use
"control.dup"       use
"control.ensure"    use
"control.nil?"      use
"control.pfunc"     use
"control.times"     use

"InvocationCounter" use
"reportTestName"    use
"testSchemaName"    use

"AvlMap" use

[
  testConstructor: [
    Key: Value:;;

    [
      avlMap: ref: @Key @Value AvlMap isRef;;
      [ref ~                                ] "Produced reference"           ensure
      [@avlMap callable? ~                  ] "Produced callable"            ensure
      [avlMap storageSize Natx storageSize =] "Produced invalid object size" ensure
      [avlMap.@root 0nx =                   ] "Produced invalid data"        ensure
      avlMap "AvlMap<" @Key schemaName & ", " & @Value schemaName & ">" & testSchemaName

      [assignCount 0n64 =] "[assignCount] is wrong" ensure
      resetInvocationCounter
    ] call

    [@Key   isStatic] "[Key] is not known"   ensure
    [@Value isStatic] "[Value] is not known" ensure

    [assignCount 0n64 =] "[assignCount] is wrong" ensure
    [dieCount    0n64 =] "[dieCount] is wrong"    ensure
    [initCount   0n64 =] "[initCount] is wrong"   ensure
  ];

  InvocationCounter Int32             testConstructor
  Int32             InvocationCounter testConstructor
] call

[
  avlMap: InvocationCounter dup AvlMap;

  value0: ref0: InvocationCounter avlMap const.find isRef;;
  value1: ref1: InvocationCounter @avlMap     .find isRef;;
  [ref0                          ] "[find] produced not a reference"        ensure
  [ref1                          ] "[find] produced not a reference"        ensure
  [@value0 isConst               ] "[find] did not preserve mutability"     ensure
  [@value1 isConst ~             ] "[find] lost mutability"                 ensure
  [@value0 InvocationCounter same] "[find] produced item with wrong schema" ensure
  [@value1 InvocationCounter same] "[find] produced item with wrong schema" ensure

  [
    node:;
    [@node.@key   isConst] "[each] produced node with mutable key" ensure
    [@node.@value isConst] "[each] did not preserve mutability"    ensure
    "control" use # failProc
    "[each] produced too much items" failProc
  ] avlMap const.each

  [
    node:;
    [@node.@key   isConst  ] "[each] produced node with mutable key" ensure
    [@node.@value isConst ~] "[each] lost mutability"                ensure
    "control" use # failProc
    "[each] produced too much items" failProc
  ] @avlMap.each
] call

eachCount: Int32; # When the transition will be finished, move it inside
[
  COUNT:  [64];
  avlMap: InvocationCounter InvocationCounter AvlMap;

  COUNT [
    key: i InvocationCounter.to;
    [@key avlMap.find nil?] "[find] produced wrong result" ensure

    value: i 2 * InvocationCounter.to;
    @key @value @avlMap.insert
    found: @key avlMap.find;
    [@found nil? ~  ] "[find] did not find item"   ensure
    [@found @value =] "[find] produced wrong item" ensure

    0 !eachCount
    LO: HI: i new virtual; 0 virtual; # The transition. Remove it
    [
      node:;
      [node.@key.item LO HI between         ] "[each] produced node with wrong key"   ensure
      [node.@key.item 2 * node.@value.item =] "[each] produced node with wrong value" ensure
      [eachCount HI > ~                     ] "[each] produced too much items"        ensure
      eachCount 1 + dynamic !eachCount
    ] avlMap.each
    [eachCount i 1 + =] "[each] produced not enough items" ensure
  ] times

  COUNT [
    key: i InvocationCounter.to;
    @key @avlMap.erase
    [@key avlMap.find nil?] "[find] produced wrong result" ensure

    0 !eachCount
    LO: HI: COUNT 1 - virtual; i 1 + virtual; # The transition. Remove it
    [
      node:;
      [node.@key.item LO HI between         ] "[each] produced node with wrong key"   ensure
      [node.@key.item 2 * node.@value.item =] "[each] produced node with wrong value" ensure
      [eachCount HI LO - > ~                ] "[each] produced too much items"        ensure
      eachCount 1 + !eachCount
    ] avlMap.each
    [eachCount HI i - =] "[each] produced not enough items" ensure
  ] times
  [avlMap.root 0nx =] "[erase] did not remove root node" ensure
] call

[
  assign: [.@item set];
  assign: [Int32 same] [set] pfunc;

  testCounters: [
    key: value: new; new;
    avlMap0: avlMap1: @key @value AvlMap dup new;;

    resetInvocationCounter
    avlMap0 new !avlMap1
    [assignCount  0n64 =] "[assignCount] is incorrect"             ensure
    [dieCount     0n64 =] "[dieCount] is incorrect"                ensure
    [initCount    0n64 =] "[initCount] is incorrect"               ensure
    [avlMap0.root 0nx = ] "[ASSIGN] made [root] address incorrect" ensure
    [avlMap1.root 0nx = ] "[ASSIGN] made [root] address incorrect" ensure

    resetInvocationCounter
    @avlMap0.clear
    [assignCount  0n64 =] "[assignCount] is incorrect"            ensure
    [dieCount     0n64 =] "[dieCount] is incorrect"               ensure
    [initCount    0n64 =] "[initCount] is incorrect"              ensure
    [avlMap0.root 0nx = ] "[clear] made [root] address incorrect" ensure

    resetInvocationCounter
    avlMap0 manuallyDestroyVariable
    [assignCount  0n64 =] "[assignCount] is incorrect"          ensure
    [dieCount     0n64 =] "[dieCount] is incorrect"             ensure
    [initCount    0n64 =] "[initCount] is incorrect"            ensure
    [avlMap0.root 0nx = ] "[DIE] made [root] address incorrect" ensure

    resetInvocationCounter
    @key @value @avlMap0.insert
    [assignCount 0n64 =] "[assignCount] is incorrect" ensure
    [dieCount    1n64 =] "[dieCount] is incorrect"    ensure
    [initCount   2n64 =] "[initCount] is incorrect"   ensure

    resetInvocationCounter
    1 @key assign
    @key const @value const @avlMap0.insert
    [assignCount 1n64 =] "[assignCount] is incorrect" ensure
    [dieCount    1n64 =] "[dieCount] is incorrect"    ensure
    [initCount   2n64 =] "[initCount] is incorrect"   ensure

    resetInvocationCounter
    [drop] avlMap0.each
    [assignCount 0n64 =] "[assignCount] is incorrect" ensure
    [dieCount    0n64 =] "[dieCount] is incorrect"    ensure
    [initCount   0n64 =] "[initCount] is incorrect"   ensure

    resetInvocationCounter
    @key @avlMap0.erase
    [assignCount 0n64 =] "[assignCount] is incorrect" ensure
    [dieCount    1n64 =] "[dieCount] is incorrect"    ensure
    [initCount   0n64 =] "[initCount] is incorrect"   ensure

    resetInvocationCounter
    avlMap0 const new !avlMap1
    [assignCount 1n64 =] "[assignCount] is incorrect" ensure
    [dieCount    1n64 =] "[dieCount] is incorrect"    ensure
    [initCount   2n64 =] "[initCount] is incorrect"   ensure

    resetInvocationCounter
    @avlMap0.clear
    [assignCount  0n64 =] "[assignCount] is incorrect"       ensure
    [dieCount     1n64 =] "[dieCount] is incorrect"          ensure
    [initCount    0n64 =] "[initCount] is incorrect"         ensure
    [avlMap0.root 0nx = ] "[clear] did not remove root node" ensure

    resetInvocationCounter
    avlMap1 manuallyDestroyVariable
    [assignCount  0n64 =] "[assignCount] is incorrect"     ensure
    [dieCount     1n64 =] "[dieCount] is incorrect"        ensure
    [initCount    0n64 =] "[initCount] is incorrect"       ensure
    [avlMap1.root 0nx = ] "[DIE] did not remove root node" ensure
  ];

  InvocationCounter 0                 testCounters
  0                 InvocationCounter testCounters
] call

"AvlMapTest" reportTestName
