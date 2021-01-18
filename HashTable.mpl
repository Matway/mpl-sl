"Array.Array"         use
"algorithm.findIndex" use
"algorithm.unhead"    use
"control.&&"          use
"control.="           use
"control.Ref"         use
"control.assert"      use
"control.dup"         use
"control.isAutomatic" use
"control.new"         use
"control.pfunc"       use
"control.set"         use
"control.when"        use
"control.while"       use

HashTable: [
  value:;
  key:;

  {
    virtual HASH_TABLE: ();
    virtual SCHEMA_NAME: "HashTable";
    virtual keyType: @key Ref;
    virtual valueType: @value Ref;

    Node: [{
      key: key newVarOfTheSameType;
      value: @value newVarOfTheSameType;
    }];

    data: Node Array Array;
    dataSize: 0;

    iter:   [@self.@data [itemRef:; {key: itemRef.key; value: @itemRef.@value;}] makeIter];
    keys:   [self .data  [.key                                                 ] makeIter];
    values: [@self.@data [.@value                                              ] makeIter];

    getSize: [dataSize new];

    at: [
      result: find;
      [result.success] "Key is not in the collection" assert
      @result.@value
    ];

    find: [
      key:;
      keyHash: @key hash dynamic;
      [
        result: {
          success: FALSE dynamic;
          value: 0nx dynamic @valueType addressToReference;
        };

        dataSize 0 = ~ [
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
        dataSize 0 = ~ [
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
              "Erasing unexisting element!" failProc
              FALSE
            ] if
          ] loop

          dataSize 1 - @dataSize set
        ] when
      ] call
    ];

    insert: [
      DEBUG [
        key: value:;;
        fr: key find;
        [fr.success ~] "Inserting existing element!" assert
        @key @value insertUnsafe
      ] [
        insertUnsafe
      ] if
    ];

    insertUnsafe: [ # make find before please
      value:;
      key:;
      keyHash: key hash dynamic;

      [
        dataSize data.dataSize = [
          newBucketSize: dataSize 0 = [16][dataSize 2 *] if;
          newBucketSize rebuild
        ] when

        bucketIndex: keyHash data.dataSize 1 - 0n32 cast and 0 cast;

        {
          key: @key new;
          value: @value dup isAutomatic ~ [const] when new;
        } dup isAutomatic ~ [const] when bucketIndex @data.at.pushBack

        dataSize 1 + @dataSize set
      ] call
    ];

    clear: [
      @data.clear
      0 dynamic @dataSize set
    ];

    release: [
      @data.release
      0 dynamic @dataSize set
    ];

    makeIter: [{
      virtual method:;
      data:;
      bucket: data [.size 0 = ~] findIndex;
      item: 0;

      valid: [bucket -1 = ~];

      get: [item bucket @data.at.at @method call];

      next: [
        item 1 + !item
        item bucket data.at.size = [
          data bucket 1 + unhead [.size 0 = ~] findIndex dup -1 = [new] [bucket 1 + +] if !bucket
          0 !item
        ] when
      ];
    }];

    rebuild: [
      newBucketSize:;

      newBucketSize @data.resize
      b: 0 dynamic;
      [b data.dataSize <] [
        current: b @data.at;
        i: 0 dynamic;
        j: 0 dynamic;
        [i current.dataSize <] [
          h: i current.at.@key hash;
          newB: h newBucketSize 1 - 0n32 cast and 0i32 cast;

          newB b = [
            i j = ~ [
              i @current.at dup isAutomatic ~ [const] when
              j @current.at set
            ] when
            j 1 + @j set
          ] [
            pushTo: newB @data.at;
            i @current.at dup isAutomatic ~ [const] when @pushTo.pushBack
          ] if

          i 1 + @i set
        ] while

        j @current.resize

        b 1 + @b set
      ] while
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

hash: ["hash" has] [.hash] pfunc;
