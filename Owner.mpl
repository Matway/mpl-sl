"control.assert" use
"control.pfunc" use
"control.when" use
"memory.deleteWith" use
"memory.new" use

OwnerWithDestructor: [{
  virtual OWNER: ();
  destructor:;
  schema elementType:;
  memory: 0nx @elementType addressToReference;

  assigned: [
    addr: memory storageAddress;
    addr 0nx = ~
  ];

  init: [
    [assigned ~] "Can init only empty pointers!" assert
    new !memory
  ];

  initDerived: [
    [assigned ~] "Can init only empty pointers!" assert
    new storageAddress @elementType addressToReference !memory
  ];

  get: [
    [assigned] "Pointer is null!" assert
    @memory
  ];

  clear: [
    assigned [
      @memory @destructor deleteWith
      0nx @elementType addressToReference !memory
    ] when
  ];

  release: [clear];

  INIT: [
    0nx @elementType addressToReference !memory
  ];

  DIE: [
    assigned [
      @memory @destructor deleteWith
    ] when
  ];
}];

Owner: [
  [
    x:;
    @x manuallyDestroyVariable
    @x storageSize
  ] OwnerWithDestructor
];

owner: [
  elementIsMoved: isMoved;
  element:;

  result: @element Owner;
  @element elementIsMoved moveIf @result.init

  @result
];

ownerDerived: [
  destructor:;
  base:;
  elementIsMoved: isMoved;
  element:;

  result: @base @destructor OwnerWithDestructor;
  @element elementIsMoved moveIf @result.initDerived

  @result
];

getHeapUsedSize: ["OWNER" has] [
  arg:;
  arg.assigned [
    i: 0;
    arg.elementType storageSize
    arg.get getHeapUsedSize +
  ] [
    0nx
  ] if
] pfunc;
