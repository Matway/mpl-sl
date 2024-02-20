# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.case"          use
"objectTools.insertField" use
"objectTools.unwrapField" use

"control" use # failProc does not work with separate [use]s

FUNCTION_ASSIGN_KEY:  [0];
FUNCTION_CALL_KEY:    [1];
FUNCTION_DIE_KEY:     [2];
FUNCTION_INIT_KEY:    [3];
FUNCTION_INVALID_KEY: [4];

Function2: [{
  SCHEMA_NAME: "Function" virtual;

  DATA_SIZE: new virtual;
  [DATA_SIZE 8 < ~] "The [Function] data size is less than 8 bytes" assert

  Signature: dup dup virtual? [] [Ref virtual] uif;

  [ # Add context to the callable signature
    signature:;
    inputs:  0 @signature @;
    options: 2 @signature @;
    @inputs (Natx) "context" 0 insertField
    @signature 1 unwrapField
    options codeRef
  ] call

  ASSIGN_CODE: {this: Natx; other: Natx;} {} {} codeRef virtual;
  CALL_CODE:   virtual;
  DIE_CODE:    {this: Natx;} {} {} codeRef virtual;
  INIT_CODE:   {this: Natx;} {} {} codeRef virtual;

  data:   Nat64; # Beginning of data, Nat64 is used to force 8-byte alignment
  pad:    Nat8 DATA_SIZE 8 - array; # Remaining data
  vtable: {functionKey: Int32;} Natx {} codeRef; # Special function used to dynamically dispatch the polymorphic operations

  ASSIGN: [
    other:;
    @other.@vtable @vtable is ~ [
      data storageAddress FUNCTION_DIE_KEY vtable @DIE_CODE addressToReference call
      @other.@vtable !vtable
      data storageAddress FUNCTION_INIT_KEY vtable @INIT_CODE addressToReference call
    ] when

    @other.data storageAddress data storageAddress FUNCTION_ASSIGN_KEY vtable @ASSIGN_CODE addressToReference call
  ];

  CALL: [
    data storageAddress FUNCTION_CALL_KEY vtable @CALL_CODE addressToReference call
  ];

  DIE: [
    data storageAddress FUNCTION_DIE_KEY vtable @DIE_CODE addressToReference call
  ];

  INIT: [
    [
      (
        FUNCTION_ASSIGN_KEY [
          f: @ASSIGN_CODE;
          [drop drop] !f
          @f storageAddress
        ]

        FUNCTION_CALL_KEY [
          f: @CALL_CODE;
          [
            0 Signature @ fieldCount 1 + [drop] times
            "Invalid function called" failProc
            1 Signature @ {} same ~ [@Signature 1 @unwrapField ucall] when
          ] !f
          @f storageAddress
        ]

        FUNCTION_DIE_KEY [
          f: @DIE_CODE;
          [drop] !f
          @f storageAddress
        ]

        FUNCTION_INIT_KEY [
          f: @INIT_CODE;
          [drop] !f
          @f storageAddress
        ]

        [0nx]
      ) case
    ] !vtable
  ];

  assign: [
    callable0:;
    @callable0 @self same [
      @callable0 @self set
    ] [
      updateVtable: [
        [
          (
            FUNCTION_ASSIGN_KEY [
              f: @ASSIGN_CODE;
              @Callable sized? [
                @Callable virtual? [
                  [drop drop] !f
                ] [
                  @Callable assignable? [
                    [
                      this:  @Callable addressToReference;
                      other: @Callable const addressToReference;
                      @other @this set
                    ] !f
                  ] [
                    [drop drop "Non-assignable callable" failProc] !f
                  ] if
                ] if
              ] [
                [
                  this:  @Callable AsRef addressToReference;
                  other: @Callable AsRef addressToReference const;
                  @other @this set
                ] !f
              ] if

              @f storageAddress
            ]

            FUNCTION_CALL_KEY [
              f: @CALL_CODE;
              @Callable sized? [
                @Callable virtual? [
                  [drop @Callable call] !f
                ] [
                  [@Callable addressToReference call] !f
                ] if
              ] [
                [@Callable AsRef addressToReference .@data call] !f
              ] if

              @f storageAddress
            ]

            FUNCTION_DIE_KEY [
              f: @DIE_CODE;
              @Callable sized? [
                @Callable virtual? [
                  [drop @Callable manuallyDestroyVariable] !f
                ] [
                  [@Callable addressToReference manuallyDestroyVariable] !f
                ] if
              ] [
                [drop] !f
              ] if

              @f storageAddress
            ]

            FUNCTION_INIT_KEY [
              f: @INIT_CODE;
              @Callable sized? [
                @Callable virtual? [
                  @Callable initializable? [
                    [drop @Callable manuallyInitVariable] !f
                  ] [
                    [drop] !f
                  ] if
                ] [
                  [@Callable addressToReference manuallyInitVariable] !f
                ] if
              ] [
                [drop] !f
              ] if

              @f storageAddress
            ]

            [1nx]
          ) case
        ] !vtable
      ];

      oldVtable: @vtable;
      Callable: @callable0 @callable0 virtual? [] [Ref unconst virtual] uif;
      updateVtable

      @vtable @oldVtable is ~ [
        data storageAddress FUNCTION_DIE_KEY oldVtable @DIE_CODE addressToReference call

        @Callable sized? [
          @Callable virtual? [
            @Callable initializable? [
              @Callable manuallyInitVariable
            ] when
          ] [
            data storageAddress @Callable addressToReference manuallyInitVariable
          ] if
        ] when
      ] when

      @Callable sized? [
        [@Callable storageSize DATA_SIZE Natx cast > ~] "The object is too large to be encapsulated in a [Function]" assert
        @Callable virtual? ~ [
          @callable0 data storageAddress @Callable addressToReference set
        ] when
      ] [
        @callable0 AsRef data storageAddress @Callable AsRef addressToReference set
      ] if
    ] if
  ];

  hasContext: [
    FUNCTION_INVALID_KEY vtable 0nx = ~
  ];

  release: [
    data storageAddress FUNCTION_DIE_KEY vtable @DIE_CODE addressToReference call
    INIT
  ];

  INIT
}];

Function: [
  32 Function2
];

makeFunction: [
  callable: signature:;;
  function: @signature Function;
  @callable @function.assign
  @function
];
