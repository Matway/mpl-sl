# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Ref"      use
"control.assert"   use
"control.over"     use
"control.pfunc"    use
"control.swap"     use
"control.when"     use
"memory.mplFree"   use
"memory.mplMalloc" use

objectSize: [storageSize];
objectSize: ["SIZE" has] [.SIZE] pfunc;

OwnerWithDestructor: [{
  virtual OWNER: ();
  virtual SCHEMA_NAME: over "Owner<" swap schemaName & ">" &;
  destructor:;
  virtual elementType: Ref;
  memory: @elementType Ref;

  INIT: [
    @elementType Ref !memory
  ];

  DIE: [
    valid? [
      @memory @destructor call @memory storageAddress mplFree
    ] when
  ];

  valid?: [
    addr: @memory storageAddress;
    addr 0nx = ~
  ];

  acquire: [
    element:;

    valid? [
      @memory @destructor call @memory storageAddress mplFree
    ] when

    @element !memory
  ];

  clear: [
    valid? [
      @memory @destructor call @memory storageAddress mplFree
      @elementType Ref !memory
    ] when
  ];

  get: [
    [valid?] "invalid Owner" assert
    @memory
  ];

  lower: [
    [valid?] "invalid Owner" assert
    base: @memory.base;
    @elementType Ref !memory
    result: @base Owner;
    @base @result.!memory
    @result
  ];

  init: [
    [valid? ~] "Owner is already set" assert
    object:;
    data: @object storageSize mplMalloc @object addressToReference;
    @data manuallyInitVariable
    @object @data set
    @data !memory
  ];

  initDerived: [
    [valid? ~] "Owner is already set" assert
    object:;
    data: @object storageSize mplMalloc @object addressToReference;
    @data manuallyInitVariable
    @object @data set
    @data storageAddress @elementType addressToReference !memory
  ];

  release: [
    [valid?] "invalid Owner" assert
    result: @memory;
    @elementType Ref !memory
    @result
  ];
}];

Owner: [
  [
    x:;
    @x manuallyDestroyVariable
    @x objectSize
  ] OwnerWithDestructor
];

owner: [
  element:;
  result: @element Owner;
  @element @result.init
  @result
];

ownerDerived: [
  element: base: destructor:;;;
  result: @base @destructor OwnerWithDestructor;
  @element @result.initDerived
  @result
];

getHeapUsedSize: ["OWNER" has] [
  arg:;
  arg.valid? [
    i: 0;
    arg.elementType objectSize
    arg.get getHeapUsedSize +
  ] [
    0nx
  ] if
] pfunc;
