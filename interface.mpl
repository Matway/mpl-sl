# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Natx" use
"control.Ref" use
"control.drop" use
"control.dup" use
"control.isVirtual" use
"control.pfunc" use
"control.when" use
"control.while" use

fieldIsRef: [drop drop FALSE];
fieldIsRef: [index: object:;; index @object @ Ref index @object ! TRUE] [drop drop TRUE] pfunc;
fieldIsref: [isConst] [0 .ERROR_CAN_ONLY_HANDLE_MUTABLE_OBJECTS] pfunc;

cloneField: [
  index: object:;;
  index @object @ index @object fieldIsRef [Ref] [newVarOfTheSameType] if
];

interface: [
  virtual methods: call dup isVirtual ~ [Ref] when;
  index: 0;
  inputIndex: 0;

  fillInputs: [
    inputIndex index @methods @ fieldCount 1 - = [] [
      inputIndex index @methods @ cloneField index @methods @ inputIndex fieldName def
      inputIndex 1 + !inputIndex
      @fillInputs ucall
    ] uif
  ];

  fillVtable: [
    index @methods fieldCount = [] [
      {
        self: Natx;
        0 !inputIndex
        @fillInputs ucall
      }

      index @methods @ fieldCount 1 - index @methods @ cloneField
      {} codeRef
      @methods index fieldName def
      index 1 + !index
      @fillVtable ucall
    ] uif
  ];

  {
    Vtable: {
      DIE_FUNC: {self: Natx;} {} {} codeRef;
      [drop] !DIE_FUNC
      SIZE: {self: Natx;} Natx {} codeRef;
      @fillVtable ucall
    };

    CALL: [
      fillMethods: [
        index @Vtable fieldCount = [] [
          @Vtable index fieldName "CALL" = [
            [@closure storageAddress @vtable.CALL]
          ] [
            {
              virtual NAME: @Vtable index fieldName;
              CALL: [@self storageAddress @vtable NAME callField];
            }
          ] if

          @Vtable index fieldName def
          index 1 + !index
          @fillMethods ucall
        ] uif
      ];

      index: 1;

      {
        vtable: @Vtable;
        DIE: [@closure storageAddress @vtable.DIE_FUNC];
        @fillMethods ucall
      }
    ];
  }
];

implement: [
  getBase: getObject:;;

  {
    virtual Base: getBase Ref;
    virtual getObject: @getObject;
    vtable: @Base.@vtable newVarOfTheSameType;

    CALL: [
      moveFields: [
        index @object fieldCount = [] [
          index @object @ index @object fieldIsRef ~ [new] when @object index fieldName def
          index 1 + !index
          @moveFields ucall
        ] uif
      ];

      object: getObject;
      index: 0;

      {
        base: {
          virtual Base: @Base;
          vtable: @vtable;
          CALL: [@self storageAddress @Base addressToReference];
        };

        @moveFields ucall
      }
    ];

    [
      virtual Object: CALL Ref;
      [@Object addressToReference manuallyDestroyVariable] @vtable.!DIE_FUNC
      [drop @Object storageSize] @vtable.!SIZE
      i: 2; [i @vtable fieldCount = ~] [
        virtual NAME: @vtable i fieldName;
        [@Object addressToReference NAME callField] i @vtable !
        i 1 + !i
      ] while
    ] call
  }
];
