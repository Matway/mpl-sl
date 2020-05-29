"Array.Array" use
"control.assert" use
"control.drop" use
"control.each" use
"control.pfunc" use
"control.times" use
"control.when" use

Deque: [{
  # front: head tail :back
  virtual CONTAINER: ();
  virtual DEQUE: ();
  schema elementType:;
  head: @elementType Array;
  tail: @elementType Array;

  size: [getSize];

  getSize: [head.getSize tail.getSize +];

  pushBack: [@tail.pushBack];

  pushFront: [@head.pushBack];

  popBack: [
    tail.size 0 = [@head @tail swapBuffers] when
    @tail.popBack
  ];

  popFront: [
    head.size 0 = [@tail @head swapBuffers] when
    @head.popBack
  ];

  back: [
    tail.size 0 = [
      0 @head.at
    ] [
      @tail.last
    ] if
  ];

  front: [
    head.size 0 = [
      0 @tail.at
    ] [
      @head.last
    ] if
  ];

  at: [
    copy index:;
    index head.getSize < [
      head.getSize index - 1 - @head.at
    ] [
      index head.getSize - @tail.at
    ] if
  ];

  swapBuffers: [
    from:to:;;

    swapCount: from.getSize 1 + 2 /;

    [to.getSize 0 =] "Destination must be empty!" assert
    swapCount @to.resize

    swapCount [
      i @from.at move
      swapCount 1 - i - @to.at set
    ] times

    from.getSize swapCount - [
      i swapCount + @from.at move
      i @from.at set
    ] times

    from.getSize swapCount - @from.shrink
  ];

  clear: [
    @head.clear
    @tail.clear
  ];

  release: [
    @head.release
    @tail.release
  ];
}];
