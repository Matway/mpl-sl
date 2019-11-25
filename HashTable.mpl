"HashTable" module
"Array" includeModule

HashTable: [
  value:;
  key:;

  {
    virtual HASH_TABLE: ();
    schema keyType: @key;
    schema valueType: @value;

    Node: [{
      key: key newVarOfTheSameType;
      keyHash: 0n32 dynamic;
      value: value newVarOfTheSameType;
    }];

    data: Node Array Array;
    dataSize: 0 dynamic;

    getSize: [dataSize copy];

    rebuild: [
      copy newBucketSize:;

      newBucketSize @data.resize
      b: 0 dynamic;
      [b data.dataSize <] [
        current: b @data.at;
        i: 0 dynamic;
        j: 0 dynamic;
        [i current.dataSize <] [
          h: i current.at.keyHash copy;
          newB: h newBucketSize 1 - 0n32 cast and 0i32 cast;

          newB b = [
            i j = not [
              i @current.at move
              j @current.at set
            ] when
            j 1 + @j set
          ] [
            pushTo: newB @data.at;
            i @current.at move @pushTo.pushBack
          ] if

          i 1 + @i set
        ] while

        j @current.resize

        b 1 + @b set
      ] while
    ];

    find: [
      key:;
      keyHash: @key hash dynamic;
      [
        result: {
          success: FALSE dynamic;
          value: 0nx @valueType addressToReference;
        };

        dataSize 0 = not [
          bucketIndex: keyHash data.dataSize 1 - 0n32 cast and 0 cast;
          curBucket: bucketIndex @data.at;

          i: 0 dynamic;
          [
            i curBucket.dataSize < [
              node: i @curBucket.at;
              node.key key = [
                {
                  success: TRUE dynamic;
                  value: @node.@value;
                } @result set
                FALSE
              ] [
                i 1 + @i set TRUE
              ] if
            ] &&
          ] loop
        ] when

        @result
      ] call
    ];

    erase: [
      key:;
      keyHash: @key hash dynamic;
      [
        dataSize 0 = not [
          bucketIndex: keyHash data.dataSize 1 - 0n32 cast and 0 cast;
          curBucket: bucketIndex @data.at;

          i: 0 dynamic;
          [
            i curBucket.dataSize < [
              node: i @curBucket.at;
              node.key key = [
                i @curBucket.erase
                FALSE
              ] [
                i 1 + @i set TRUE
              ] if
            ] [
              [FALSE] "Erasing unexisting element!" assert
              FALSE
            ] if
          ] loop
        ] when
      ] call
    ];

    insertUnsafe: [ # make find before please
      valueIsMoved: isMoved;
      value:;
      keyIsMoved: isMoved;
      key:;
      keyHash: key hash dynamic;

      [
        dataSize data.dataSize = [
          newBucketSize: dataSize 0 = [16][dataSize 2 *] if;
          newBucketSize rebuild
        ] when

        bucketIndex: keyHash data.dataSize 1 - 0n32 cast and 0 cast;

        newNode: {
          key: @key keyIsMoved moveIf copy;
          keyHash: key hash;
          value: @value valueIsMoved moveIf copy;
        };

        pushTo: bucketIndex @data.at;
        @newNode move @pushTo.pushBack

        dataSize 1 + @dataSize set
      ] call
    ];

    insert: [
      DEBUG [
        valueIsMoved: isMoved;
        value:;
        keyIsMoved: isMoved;
        key:;
        fr: key find;
        [fr.success not] "Inserting existing element!" assert
        @key keyIsMoved moveIf @value valueIsMoved moveIf insertUnsafe
      ] [
        insertUnsafe
      ] if
    ];

    clear: [
      @data.clear
      0 dynamic @dataSize set
    ];

    release: [
      @data.release
      0 dynamic @dataSize set
    ];

    INIT: [
      0 dynamic @dataSize set
    ];

    ASSIGN: [
      other:;
      other.data     @data     set
      other.dataSize @dataSize set
    ];

    DIE: [
      #default
    ];
  }];

each: [b:; "HASH_TABLE" has] [
  eachInTableBody:;
  eachInTableTable:;

  eachInTableBucketIndex: 0;
  [
    eachInTableBucketIndex eachInTableTable.data.dataSize < [
      eachInTableCurrentBucket: eachInTableBucketIndex @eachInTableTable.@data.at;
      eachInTableI: 0;
      [
        eachInTableI eachInTableCurrentBucket.dataSize < [
          eachInTableNode: eachInTableI @eachInTableCurrentBucket.at;
          {key: eachInTableNode.key; value: @eachInTableNode.@value;} @eachInTableBody call
          eachInTableI 1 + @eachInTableI set TRUE
        ] &&
      ] loop

      eachInTableBucketIndex 1 + @eachInTableBucketIndex set TRUE
    ] &&
  ] loop
] pfunc;

hash: [0n8  same] [0n32 cast] pfunc;
hash: [0n16 same] [0n32 cast] pfunc;
hash: [0n32 same] [0n32 cast] pfunc;
hash: [0n64 same] [0n32 cast] pfunc;
hash: [0nx  same] [0n32 cast] pfunc;
hash: [0i8  same] [0i32 cast 0n32 cast] pfunc;
hash: [0i16 same] [0i32 cast 0n32 cast] pfunc;
hash: [0i32 same] [0i32 cast 0n32 cast] pfunc;
hash: [0i64 same] [0i32 cast 0n32 cast] pfunc;
hash: [0ix  same] [0i32 cast 0n32 cast] pfunc;
