"control.&&" use
"control.Nat8" use
"control.Natx" use
"control.Ref" use
"control.case" use
"control.drop" use
"control.isAutomatic" use
"control.isCodeRef" use
"control.isCopyable" use
"control.set" use
"control.when" use
"control.||" use
"conventions.moveOld" use
"objectTools.insertField" use
"objectTools.unwrapField" use

addContextToSignature: [
  signature:;
  args:    0 static @signature @;
  options: 2 static @signature @;

  (Natx) 0 static "context" @args moveOld insertField
  1 static @signature unwrapField
  options codeRef
];

CALL_FUNC: [0nx];
DIE_FUNC: [1nx];
ASSIGN_FUNC: [2nx];
INIT_FUNC: [3nx];

Function: [{
  CONTEXT_SIZE: [32 static];
  virtual CALL_FUNC_SCHEMA: addContextToSignature Ref;
  virtual DIE_FUNC_SCHEMA: {this: Natx;} {} {} codeRef Ref;
  virtual ASSIGN_FUNC_SCHEMA: {this: Natx; other: Natx;} {} {} codeRef Ref;
  virtual INIT_FUNC_SCHEMA: {this: Natx;} {} {} codeRef Ref;

  contextData: Nat8 CONTEXT_SIZE array;
  vtable: {functionIndex: Natx;} Natx {} codeRef;

  assign: [
    context0:;

    release

    @context0 isCodeRef [
      context: @contextData storageAddress Natx addressToReference;
      @context0 storageAddress @context set
    ] [
      @context0 storageSize CONTEXT_SIZE Natx cast > [
        0 .ERROR_CONTEXT_SIZE_LARGER_THAN_FUNCTION_CONTEXT_SIZE
      ] when

      @context0 storageSize 0nx static > [
        context: contextData storageAddress @context0 addressToReference;
        @context manuallyInitVariable
        @context0 @context0 isAutomatic ~ [const] when @context set
      ] when
    ] if

    virtual contextType: @context0 storageSize 0nx = [@context0][@context0 Ref] uif;
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
    virtual CALL_FUNC_SCHEMA: @CALL_FUNC_SCHEMA Ref;
    virtual DIE_FUNC_SCHEMA: @DIE_FUNC_SCHEMA Ref;
    virtual ASSIGN_FUNC_SCHEMA: @ASSIGN_FUNC_SCHEMA Ref;
    virtual INIT_FUNC_SCHEMA: @INIT_FUNC_SCHEMA Ref;

    [
      functionIndex:;
      @contextType isCodeRef contextIsCodeRef:;
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
                @other const @this set
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
    virtual CALL_FUNC_SCHEMA: @CALL_FUNC_SCHEMA Ref;
    virtual DIE_FUNC_SCHEMA: @DIE_FUNC_SCHEMA Ref;
    virtual ASSIGN_FUNC_SCHEMA: @ASSIGN_FUNC_SCHEMA Ref;
    virtual INIT_FUNC_SCHEMA: @INIT_FUNC_SCHEMA Ref;

    [
      (
        CALL_FUNC [0nx]

        DIE_FUNC [
          f: @DIE_FUNC_SCHEMA Ref;
          [drop] !f
          @f storageAddress
        ]

        ASSIGN_FUNC [
          f: @ASSIGN_FUNC_SCHEMA Ref;
          [drop drop] !f
          @f storageAddress
        ]

        INIT_FUNC [
          f: @INIT_FUNC_SCHEMA Ref;
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
    @closure.@contextData storageAddress @INIT_FUNC vtable @INIT_FUNC_SCHEMA addressToReference call
    @other.@contextData storageAddress @closure.@contextData storageAddress ASSIGN_FUNC vtable @ASSIGN_FUNC_SCHEMA addressToReference call
  ];

  DIE: [release];

  makeEmptyVtable
}];

makeFunction: [
  context: signature:;;
  function: @signature Function;
  @context @function.assign
  @function
];
