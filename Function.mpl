"control.&&" use
"control.Nat8" use
"control.Natx" use
"control.Ref" use
"control.case" use
"control.drop" use
"control.isCodeRef" use
"control.isCopyable" use
"control.when" use
"control.||" use
"objectTools.insertField" use
"objectTools.unwrapField" use

addContextToSignature: [
  signature:;
  args: 0 static @signature @;
  options: 2 static @signature @;

  (Natx) 0 static "context" @args move insertField
  1 static @signature unwrapField
  options codeRef
];

CALL_FUNC: [0nx];
DIE_FUNC: [1nx];
ASSIGN_FUNC: [2nx];
INIT_FUNC: [3nx];

Function: [{
  CONTEXT_SIZE: [32 static];
  schema CALL_FUNC_SCHEMA: addContextToSignature;
  schema DIE_FUNC_SCHEMA: {this: Natx;} {} {} codeRef;
  schema ASSIGN_FUNC_SCHEMA: {this: Natx; other: Natx;} {} {} codeRef;
  schema INIT_FUNC_SCHEMA: {this: Natx;} {} {} codeRef;

  contextData: Nat8 CONTEXT_SIZE array;
  vtable: {functionIndex: Natx;} Natx {} codeRef;

  assign: [
    context0IsMoved: isMoved;
    context0IsCodeRef: isCodeRef;
    context0:;

    release

    context0IsCodeRef [
      context: @contextData storageAddress Natx addressToReference;
      @context0 storageAddress @context set
    ] [
      context0IsMoved @context0 isCopyable or ~ [
        0 .ERROR_CONTEXT_NEITHER_MOVED_NOR_COPYABLE
      ] when

      @context0 storageSize CONTEXT_SIZE Natx cast > [
        0 .ERROR_CONTEXT_SIZE_LARGER_THAN_FUNCTION_CONTEXT_SIZE
      ] when

      @context0 storageSize 0nx static > [
        context: contextData storageAddress @context0 addressToReference;
        @context manuallyInitVariable
        @context0 context0IsMoved moveIf @context set
      ] when
    ] if

    schema contextType: @context0;
    updateVtable
  ];

  hasContext: [
    CALL_FUNC vtable 0nx = ~
  ];

  release: [
    @contextData storageAddress DIE_FUNC vtable @DIE_FUNC_SCHEMA addressToReference call
    makeEmptyVtable
  ];

  updateVtable: [
    schema CALL_FUNC_SCHEMA: @CALL_FUNC_SCHEMA;
    schema DIE_FUNC_SCHEMA: @DIE_FUNC_SCHEMA;
    schema ASSIGN_FUNC_SCHEMA: @ASSIGN_FUNC_SCHEMA;
    schema INIT_FUNC_SCHEMA: @INIT_FUNC_SCHEMA;

    [
      functionIndex:;
      @contextType isCodeRef contextIsCodeRef:; drop
      functionIndex (
        CALL_FUNC [
          f: @CALL_FUNC_SCHEMA Ref;
          contextIsCodeRef [@contextType storageSize 0nx static >] || [
            [@contextType addressToReference call] !f
          ] [
            [drop @contextType call] !f
          ] if

          @f storageAddress
        ]

        DIE_FUNC [
          f: @DIE_FUNC_SCHEMA Ref;
          contextIsCodeRef ~ [@contextType storageSize 0nx static >] && [
            [@contextType addressToReference manuallyDestroyVariable] !f
          ] [
            [drop] !f
          ] if

          @f storageAddress
        ]

        ASSIGN_FUNC [
          f: @ASSIGN_FUNC_SCHEMA Ref;
          @contextType isCopyable [
            @contextType storageSize 0nx static > [
              [
                this: @contextType addressToReference;
                other: @contextType addressToReference;
                @other @this set
              ] !f
            ] [
              [drop drop] !f
            ] if
          ] [
            contextIsCodeRef [
              [
                this: Natx addressToReference;
                other: Natx addressToReference;
                @other @this set
              ] !f
            ] when
          ] if

          @f storageAddress
        ]

        INIT_FUNC [
          f: @INIT_FUNC_SCHEMA Ref;
          contextIsCodeRef ~ [@contextType storageSize 0nx static >] && [
            [@contextType addressToReference manuallyInitVariable] !f
          ] [
            [drop] !f
          ] if

          @f storageAddress
        ]

        [0nx]
      ) case
    ] !vtable
  ];

  makeEmptyVtable: [
    schema CALL_FUNC_SCHEMA: @CALL_FUNC_SCHEMA;
    schema DIE_FUNC_SCHEMA: @DIE_FUNC_SCHEMA;
    schema ASSIGN_FUNC_SCHEMA: @ASSIGN_FUNC_SCHEMA;
    schema INIT_FUNC_SCHEMA: @INIT_FUNC_SCHEMA;

    [
      (
        CALL_FUNC [0nx]

        DIE_FUNC [
          f: DIE_FUNC_SCHEMA Ref;
          [drop] !f
          @f storageAddress
        ]

        ASSIGN_FUNC [
          f: ASSIGN_FUNC_SCHEMA Ref;
          [drop drop] !f
          @f storageAddress
        ]

        INIT_FUNC [
          f: INIT_FUNC_SCHEMA Ref;
          [drop] !f
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
    release
    @other.@vtable @closure.!vtable
    @closure.@contextData storageAddress INIT_FUNC vtable @INIT_FUNC_SCHEMA addressToReference call
    @other.@contextData storageAddress @closure.@contextData storageAddress ASSIGN_FUNC vtable @ASSIGN_FUNC_SCHEMA addressToReference call
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
