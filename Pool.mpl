# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Union.Union" use
"control.&&" use
"control.Cref" use
"control.Int32" use
"control.Nat32" use
"control.Nat8" use
"control.Natx" use
"control.Ref" use
"control.assert" use
"control.drop" use
"control.isNil" use
"control.swap" use
"control.times" use
"control.when" use
"control.while" use
"memory.mplFree" use
"memory.mplMalloc" use
"memory.mplRealloc" use

Pool: [
  element:;
  {
    virtual POOL: ();
    virtual SCHEMA_NAME: "Pool";
    virtual elementSchema: @element Ref;
    virtual entrySize: (0 @element newVarOfTheSameType) Union storageSize;

    data: @elementSchema Ref;
    dataSize: 0 dynamic;
    firstFree: -1 dynamic;
    exactAllocatedMemSize: 0nx dynamic;

    iter:   [@self [{key: swap new; value:;}] makeIter];
    keys:   [self  [drop                    ] makeIter];
    values: [@self [swap drop               ] makeIter];

    getSize: [
      dataSize new
    ];

    at: [
      index:;
      [index valid] "Pool::at: element is invalid!" assert
      index elementAt
    ];

    getAddressByIndex: [
      Natx cast entrySize * @data storageAddress +
    ];

    getTailAddressByIndex: [
      Natx cast dataSize Natx cast entrySize * + @data storageAddress +
    ];

    elementAt: [
      getAddressByIndex @elementSchema addressToReference
    ];

    nextFreeAt: [
      getAddressByIndex Int32 addressToReference
    ];

    validAt: [
      getTailAddressByIndex Nat8 addressToReference
    ];

    valid: [
      index:;
      index 0i32 same ~ [0 .ONLY_I32_ALLOWED] when
      [index 0 < ~ [index dataSize <] &&] "Index is out of range!" assert
      position: index 3n32 rshift;
      offset: index Nat32 cast 7n32 and Nat8 cast;
      bitBlock: position validAt;
      bitBlock 1n8 offset lshift and 0n8 = ~
    ];

    getNextIndex: [
      firstFree 0 < [
        dataSize new
      ] [
        firstFree new
      ] if
    ];

    erase: [
      index:;
      [index valid] "Pool::erase: element is invalid!" assert
      index getAddressByIndex @elementSchema addressToReference manuallyDestroyVariable
      firstFree index nextFreeAt set

      position: index 3n32 rshift;
      offset: index Nat32 cast 7n32 and Nat8 cast;
      bitBlock: position validAt;
      bitBlock 1n8 offset lshift xor @bitBlock set

      index @firstFree set
    ];

    clear: [
      i: firstValid;
      [i getSize <] [
        i erase
        i nextValid !i
      ] while
    ];

    firstValid: [
      i: 0;
      [
        i dataSize < [i valid ~] && [i 1 + !i TRUE] &&
      ] loop

      i
    ];

    nextValid: [
      i: 1 +;
      [
        i dataSize < [i valid ~] && [i 1 + !i TRUE] &&
      ] loop

      i
    ];

    insert: [
      element:;

      index: -1 dynamic;

      firstFree 0 < [
        dataSize @index set
        dataSize 0 = [
          entrySize 8nx * 1nx + @exactAllocatedMemSize set
          exactAllocatedMemSize mplMalloc @elementSchema addressToReference !data
          7 [
            i 2 +
            i 1 + nextFreeAt set
          ] times

          -1 7 nextFreeAt set
          8 @dataSize set
          1 @firstFree set
          0n8 0 validAt set
        ] [
          upTo8: [Nat32 cast 7n32 + 7n32 ~ and Int32 cast];
          newDataSize: dataSize dataSize 4 / + upTo8;
          tailSize: dataSize 3n32 rshift;
          newTailSize: newDataSize 3n32 rshift;

          newExactAllocatedMemSize: entrySize newDataSize Natx cast * newTailSize Natx cast +;
          newExactAllocatedMemSize exactAllocatedMemSize @data storageAddress mplRealloc @elementSchema addressToReference !data
          newExactAllocatedMemSize @exactAllocatedMemSize set

          getNewTailAddressByIndex: [
            Natx cast newDataSize Natx cast entrySize * + @data storageAddress +
          ];

          newValidAt: [
            getNewTailAddressByIndex Nat8 addressToReference
          ];

          #set valid
          tailSize [
            i validAt const i newValidAt set
          ] times

          newTailSize tailSize - [
            0n8 tailSize i + newValidAt set
          ] times

          #set nextFree entries
          newDataSize dataSize - 1 - [
            dataSize 2 + i +
            dataSize 1 + i + nextFreeAt set
          ] times

          -1 newDataSize 1 - nextFreeAt set

          dataSize 1 + @firstFree set
          newDataSize @dataSize set
        ] if
      ] [
        firstFree @index set
        index nextFreeAt const @firstFree set
      ] if

      newElement: index elementAt;
      @newElement manuallyInitVariable
      @element @newElement set

      position: index 3n32 rshift;
      offset: index Nat32 cast 7n32 and Nat8 cast;
      bitBlock: position validAt;
      bitBlock 1n8 offset lshift or @bitBlock set

      index
    ];

    makeIter: [{
      virtual method:;
      pool:;
      index: pool.firstValid;

      next: [
        index pool.dataSize = [0 @pool.@elementSchema method FALSE] [
          index new index @pool.at method
          index pool.nextValid !index
          TRUE
        ] if
      ];
    }];

    INIT: [
      @elementSchema Ref !data
      0  !dataSize
      -1 !firstFree
    ];

    DIE: [
      clear
      @data isNil ~ [
        exactAllocatedMemSize @data storageAddress mplFree
      ] when
    ];
  }
];
