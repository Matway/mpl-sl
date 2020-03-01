"Owner" module
"control" includeModule
"memory" includeModule

OwnerWithDestructor: [{
  virtual OWNER: ();
  destructor:;
  schema elementType:;
  memory: 0nx @elementType addressToReference;

  assigned: [
    addr: memory storageAddress;
    addr 0nx = not
  ];

  init: [
    [assigned not] "Can init only empty pointers!" assert
    new !memory
  ];

  initDerived: [
    [assigned not] "Can init only empty pointers!" assert
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

set: [
  owner0: owner1:;;
  owner0.get .base owner1.get same
] [
  owner0: owner1:;;
  @owner1.clear
  owner0.memory storageAddress @owner1.@elementType addressToReference @owner1.!memory
  0nx @owner0.@elementType addressToReference @owner0.!memory
] pfunc;
