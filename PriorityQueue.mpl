"Array.Array" use

PriorityQueue: [{
  data: Array;

  swap: [
    copy i1:; copy i2:;
    i1ref: i1 @data.at;
    i2ref: i2 @data.at;
    tmp: @i1ref move copy;
    @i2ref move @i1ref set
    @tmp move @i2ref set
  ];

  parent: [1 - 2 /];
  lchild: [2 * 1 +];
  rchild: [2 * 2 +];

  lift: [
    copy i:;
    [
      i 0 > [
        p: i parent;
        p data.at i data.at < [
          i p swap
          p @i set
          TRUE
        ] &&
      ] &&
    ] loop
  ];

  push: [
    @data.pushBack
    data.getSize 1 - lift
  ];

  top: [0 @data.at];

  pop: [
    i: 0 dynamic;
    [
      l: i lchild;
      r: i rchild;
      l data.getSize < [
        r data.getSize < [
          c: r data.at l data.at < [l copy] [r copy] if;
          i c swap
          c @i set
          TRUE
        ] [
          i l swap
          FALSE
        ] if
      ] [
        i data.getSize 1 - < [
          i data.getSize 1 - swap
          i lift
        ] when
        FALSE
      ] if
    ] loop

    @data.popBack
  ];

  getSize: [data.getSize];
  empty: [data.getSize 0 =];
}];
