"control.when" use

Union: [{
  virtual UNION: ();

  schema typeList:;

  virtual maxSize: [
    result: 1 static;
    i: 0 static;
    [
      i typeList fieldCount < [
        curSize: i typeList @ storageSize 0ix cast 0 cast;
        curSize result > [
          curSize @result set
        ] when

        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
    result
  ] call;

  virtual maxAlignment: [
    result: 1 static;
    i: 0 static;
    [
      i typeList fieldCount < [
        curSize: i typeList @ alignment 0ix cast 0 cast;
        curSize result > [
          curSize @result set
        ] when

        i 1 + @i set
        TRUE static
      ] [
        FALSE static
      ] if
    ] loop
    result
  ];

  memory: [
    maxAlignment 1 static = [0n8 dynamic] [
      maxAlignment 2 static = [0n16 dynamic] [
        maxAlignment 4 static = [0n32 dynamic] [
          maxAlignment 8 static = [0n64 dynamic] [
            ().ALIGNMENT_HAS_INCORRECT_VALUE
          ] if
        ] if
      ] if
    ] if
  ] call;

  filler: 0n8 maxSize maxAlignment - array dynamic;

  get: [
    index: copy;
    @memory storageAddress index @typeList @ addressToReference
  ];
}];
