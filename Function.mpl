"Function" module
"control" includeModule

Function: [{
  virtual CONTEXT_SIZE: 32;
  contextData: Nat8 CONTEXT_SIZE array;
  deleter: {context: Natx;} {} {convention: cdecl;} codeRef;
  function:;

  [drop] !deleter

  assign: [drop fieldCount TRUE] [
    code:;
    context0IsMoved: isMoved;
    context0:;
    context0IsMoved ~ [
      "Function.assign, context is not moved" printCompilerMessage
      0 .ERROR
    ] when

    context0 storageSize CONTEXT_SIZE Natx cast > [
      "Function.assign, context storageSize is larger than Function.CONTEXT_SIZE" printCompilerMessage
      0 .ERROR
    ] when

    destroy
    schema contextType: @context0;
    context0 storageSize 0nx > [
      context: contextData storageAddress @contextType addressToReference;
      @context manuallyInitVariable
      @context0 move @context set
      [@contextType addressToReference @code call] !function
      [@contextType addressToReference manuallyDestroyVariable] !deleter
    ] [
      [drop @contextType @code call] !function
      [drop] !deleter
    ] if
  ] pfunc;

  release: [
    destroy
    0nx @function addressToReference !function
    [drop] !deleter
  ];

  destroy: [
    contextData storageAddress deleter
  ];

  CALL: [
    contextData storageAddress function
  ];

  INIT: [
    0nx @function addressToReference !function
    [drop] !deleter
  ];

  DIE: [
    destroy
  ];
}];

makeFunction: [
  code:;
  signature:;
  contextIsMoved: isMoved;
  context:;
  function: @signature Function;
  @context contextIsMoved moveIf @code @function.assign
  @function
];
