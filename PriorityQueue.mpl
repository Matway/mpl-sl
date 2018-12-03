"PriorityQueue" module
"Array" includeModule

PriorityQueue: [{
  data: Array;

  swap: [
    copy i1:; copy i2:;
    i1ref: i1 @data.at;
    i2ref: i2 @data.at;
    tmp: @i1ref move copy;
    @i2ref move @i1ref set
    @tmp move @i2ref set
  ] func;

  parent: [1 - 2 /] func;
  lchild: [2 * 1 +] func;
  rchild: [2 * 2 +] func;

  lift: [
    copy i:;
    [
      i 0 > [
        p: i parent;
        i data.at p data.at < [
          i p swap
          p @i set
          TRUE
        ] &&
      ] &&
    ] loop
  ] func;

  push: [
    @data.pushBack
    data.getSize 1 - lift
  ] func;

  top: [0 @data.at] func;

  pop: [
    i: 0 dynamic;
    [
      l: i lchild;
      r: i rchild;
      l data.getSize < [
        r data.getSize < [
          c: l data.at r data.at < [l copy] [r copy] if;
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
  ] func;

  getSize: [data.getSize] func;
  empty: [data.getSize 0 =] func;
}] func;
