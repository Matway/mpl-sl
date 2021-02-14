"control.Ref" use
"control.assert" use
"control.dup" use
"control.pfunc" use
"control.when" use
"memory.mplFree" use
"memory.mplMalloc" use

objectSize: [storageSize];
objectSize: ["SIZE" has] [.SIZE] pfunc;

OwnerWithDestructor: [{
  virtual OWNER: ();
  virtual SCHEMA_NAME: "Owner";
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
