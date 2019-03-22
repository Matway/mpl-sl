"Owner" module
"control" includeModule

OwnerWithDestructor: [{
  virtual OWNER: ();
  destructor:;
  schema elementType:;
  memory: 0nx @elementType addressToReference;

  assigned: [
    addr: memory storageAddress;
    addr 0nx = not
  ] func;

  init: [
    [assigned not] "Can init only empty pointers!" assert
    new !memory
  ] func;

  initDerived: [
    [assigned not] "Can init only empty pointers!" assert
    new storageAddress @elementType addressToReference !memory
  ] func;

  get: [
    [assigned] "Pointer is null!" assert
    @memory
  ] func;

  clear: [
    assigned [
      @memory @destructor deleteWith
      0nx @elementType addressToReference !memory
    ] when
  ] func;

  release: [clear] func;

  INIT: [
    0nx @elementType addressToReference !memory
  ];

  DIE: [
    assigned [
      @memory @destructor deleteWith
    ] when
  ];
}] func;

Owner: [[manuallyDestroyVariable] OwnerWithDestructor] func;

owner: [
  elementIsMoved: isMoved;
  element:;

  result: @element Owner;
  @element elementIsMoved moveIf @result.init

  @result
] func;

ownerDerived: [
  destructor:;
  base:;
  elementIsMoved: isMoved;
  element:;

  result: @base @destructor OwnerWithDestructor;
  @element elementIsMoved moveIf @result.initDerived

  @result
] func;

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
