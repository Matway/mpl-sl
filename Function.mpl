"Function" module

"control" includeModule
"objectTools" includeModule

addContextToSignature: [
  signature:;
  args: 0 @signature @;
  options: 2 @signature @;

  (Natx) 0 "context" @args move insertField
  1 @signature fieldIsRef [1 @signature @] [1 @signature @ newVarOfTheSameType] uif
  options codeRef
];

CALL_FUNC: [0nx];
DELETE_FUNC: [1nx];
COPY_FUNC: [2nx];

Function: [{
  virtual CONTEXT_SIZE: 32;
  contextData: Nat8 CONTEXT_SIZE array;
  schema CALL_FUNC_SCHEMA: addContextToSignature;
  schema DIE_FUNC_SCHEMA: {this: Natx;} {} {} codeRef;
  schema ASSIGN_FUNC_SCHEMA: {this: Natx; other: Natx;} {} {} codeRef;

  vtable: {number: Natx;} Natx {} codeRef;

  assign: [
    context0IsMoved: isMoved;
    context0:;

    context0IsMoved @context0 isCopyable or ~ [
      0 .ERROR_CONTEXT_NEITHER_MOVED_NOR_COPYABLE
    ] when

    @context0 storageSize CONTEXT_SIZE Natx cast > [
      0 .ERROR_CONTEXT_SIZE_LARGER_THAN_FUNCTION_CONTEXT_SIZE
    ] when

    release
    @context0 storageSize 0nx > [
      context: contextData storageAddress @context0 addressToReference;
      @context manuallyInitVariable
      @context0 context0IsMoved moveIf @context set
    ] when

    schema contextType: @context0;
    updateVtable
  ];

  hasContext: [
    CALL_FUNC vtable 0nx = ~
  ];

  release: [
    @contextData storageAddress DELETE_FUNC vtable @DIE_FUNC_SCHEMA addressToReference call
    makeEmptyVtable
  ];

  updateVtable: [
    schema CALL_FUNC_SCHEMA: @CALL_FUNC_SCHEMA;
    schema DIE_FUNC_SCHEMA: @DIE_FUNC_SCHEMA;
    schema ASSIGN_FUNC_SCHEMA: @ASSIGN_FUNC_SCHEMA;
    [
      number:;
      number (
        CALL_FUNC [
          f: @CALL_FUNC_SCHEMA Ref;
          @contextType @CALL_FUNC_SCHEMA same [
          ] [
            @contextType storageSize 0nx > [
              [@contextType addressToReference call] !f
            ] [
              [drop @contextType call] !f
            ] uif
          ] uif
          @f storageAddress
        ]

        DELETE_FUNC [
          f: @DIE_FUNC_SCHEMA Ref;
          @contextType storageSize 0nx > [
            [@contextType addressToReference manuallyDestroyVariable] !f
          ] [
            [drop] !f
          ] uif

          @f storageAddress
        ]

        COPY_FUNC [
          f: @ASSIGN_FUNC_SCHEMA Ref;
          @contextType isCopyable [
            @contextType storageSize 0nx > [
              [
                this: @contextType addressToReference;
                other: @contextType addressToReference;
                @other @this set
              ] !f
            ] [
              [drop drop] !f
            ] uif

            @f storageAddress
          ] [
            0nx
          ] uif
        ]

        [0nx]
      ) case
    ] !vtable
  ];

  makeEmptyVtable: [
    schema CALL_FUNC_SCHEMA: @CALL_FUNC_SCHEMA;
    schema DIE_FUNC_SCHEMA: @DIE_FUNC_SCHEMA;
    schema ASSIGN_FUNC_SCHEMA: @ASSIGN_FUNC_SCHEMA;
    [
      number:;
      number (
        CALL_FUNC [0nx]

        DELETE_FUNC [
          f: DIE_FUNC_SCHEMA Ref;
          [drop] !f
          @f storageAddress
        ]

        COPY_FUNC [
          f: ASSIGN_FUNC_SCHEMA Ref;
          [drop drop] !f
          @f storageAddress
        ]

        [0nx]
      ) case
    ] !vtable
  ];

  CALL: [
    @contextData storageAddress CALL_FUNC vtable @CALL_FUNC_SCHEMA addressToReference call
  ];

  INIT: [makeEmptyVtable];

  ASSIGN: [
    other:;
    @other.@vtable @closure.!vtable
    @other.@contextData storageAddress @closure.@contextData storageAddress COPY_FUNC vtable @ASSIGN_FUNC_SCHEMA addressToReference call
  ];

  DIE: [release];

  makeEmptyVtable
}];

makeFunction: [
  signature:;
  contextIsMoved: isMoved;
  context:;
  function: @signature Function;
  @context contextIsMoved moveIf @function.assign
  @function
];
