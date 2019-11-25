"Pool" module

"control" includeModule
"memory" includeModule
"Union" includeModule

Pool: [
  element:;
  {
    virtual POOL: ();
    schema elementSchema: @element;
    virtual entrySize: (0 @element newVarOfTheSameType) Union storageSize;

    data: 0nx dynamic;
    dataSize: 0 dynamic;
    firstFree: -1 dynamic;

    getAddressByIndex: [
      Natx cast entrySize * data +
    ];

    getTailAddressByIndex: [
      Natx cast dataSize Natx cast entrySize * data + +
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
      copy index:;
      index 0i32 same not [0 .ONLY_I32_ALLOWED] when
      [index 0 < not [index dataSize <] &&] "Index is out of range!" assert
      position: index 3n32 rshift;
      offset: index Nat32 cast 7n32 and Nat8 cast;
      bitBlock: position validAt;
      bitBlock 1n8 offset lshift and 0n8 = not
    ];

    getNextIndex: [
      firstFree 0 < [
        dataSize copy
      ] [
        firstFree copy
      ] if
    ];

    at: [
      copy index:;
      [index valid] "Pool::at: element is invalid!" assert
      index elementAt
    ];

    getSize: [
      dataSize copy
    ];

    erase: [
      copy index:;
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
        i dataSize < [i valid not] && [i 1 + !i TRUE] &&
      ] loop

      i
    ];

    nextValid: [
      i: 1 +;
      [
        i dataSize < [i valid not] && [i 1 + !i TRUE] &&
      ] loop

      i
    ];

    insert: [
      elementIsMoved: isMoved;
      element:;

      index: -1 dynamic;

      firstFree 0 < [
        dataSize @index set
        dataSize 0 = [
          entrySize 8nx * 1nx + mplMalloc @data set
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

          entrySize newDataSize Natx cast * newTailSize Natx cast + data mplRealloc @data set

          getNewTailAddressByIndex: [
            Natx cast newDataSize Natx cast entrySize * data + +
          ];

          newValidAt: [
            getNewTailAddressByIndex Nat8 addressToReference
          ];

          #set valid
          tailSize [
            i validAt i newValidAt set
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
        index nextFreeAt @firstFree set
      ] if

      newElement: index elementAt;
      @newElement manuallyInitVariable
      @element elementIsMoved moveIf @newElement set

      position: index 3n32 rshift;
      offset: index Nat32 cast 7n32 and Nat8 cast;
      bitBlock: position validAt;
      bitBlock 1n8 offset lshift or @bitBlock set

      index
    ];

    INIT: [
      0nx dynamic @data set
      0   dynamic @dataSize set
      -1  dynamic @firstFree set
    ];

    DIE: [
      clear
      data mplFree
    ];
  }
];

@: ["POOL" has] [.at] pfunc;
!: ["POOL" has] [.at set] pfunc;

each: [b:; "POOL" has] [
  eachInPoolBody:;
  eachInPoolPool:;
  eachInPoolIndex: eachInPoolPool.firstValid;
  [eachInPoolIndex eachInPoolPool.getSize <] [
    eachInPoolElement: eachInPoolIndex @eachInPoolPool.at;
    {index: eachInPoolIndex copy; value: @eachInPoolElement;} @eachInPoolBody call
    eachInPoolIndex eachInPoolPool.nextValid !eachInPoolIndex
  ] while
] pfunc;
