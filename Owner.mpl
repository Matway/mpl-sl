"Owner" module
"control" includeModule

Owner: [{
  virtual OWNER: ();
  schema elementType:;
  memory: 0nx @elementType addressToReference;

  assigned: [
    addr: memory storageAddress;
    addr 0nx = not
  ] func;

  init: [
    [assigned not] "Can init only empty pointers!" assert
    mplNew !memory
  ] func;

  initDerived: [
    [assigned not] "Can init only empty pointers!" assert
    mplNew storageAddress @elementType addressToReference !memory
  ] func;

  get: [
    [assigned] "Pointer is null!" assert
    @memory
  ] func;

  clear: [
    assigned [
      @memory mplDelete
      0nx @elementType addressToReference !memory
    ] when
  ] func;

  release: [clear] func;

  INIT: [
    0nx @elementType addressToReference !memory
  ];

  DIE: [
    assigned [
      memory manuallyDestroyVariable
      memory storageAddress mplFree
    ] when
  ];
}] func;

owner: [
  elementIsMoved: isMoved;
  element:;

  result: @element Owner;
  @element elementIsMoved moveIf @result.init

  @result
] func;

ownerDerived: [
  base:;
  elementIsMoved: isMoved;
  element:;

  result: @base Owner;
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
