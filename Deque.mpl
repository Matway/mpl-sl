"Deque" module

"control" useModule

Deque: [{
  # front: head tail :back
  virtual CONTAINER: ();
  virtual DEQUE: ();
  elementType: copy; # not virtual because of bug in mplc 181102
  head: @elementType Array;
  tail: @elementType Array;

  getSize: [head.getSize tail.getSize +] func;

  pushBack: [@tail.pushBack] func;

  pushFront: [@head.pushBack] func;

  popBack: [
    tail fieldCount 0 = [@head @tail swapBuffers] when
    @tail.popBack
  ] func;

  popFront: [
    head fieldCount 0 = [@tail @head swapBuffers] when
    @head.popBack
  ] func;

  back: [
    tail fieldCount 0 = [
      0 @head.at
    ] [
      @tail.last
    ] if
  ] func;

  front: [
    head fieldCount 0 = [
      0 @tail.at
    ] [
      @head.last
    ] if
  ] func;

  at: [
    copy index:;
    index head.getSize < [
      head.getSize index - 1 - @head.at
    ] [
      index head.getSize - @tail.at
    ] if
  ] func;

  swapBuffers: [
    from:to:;;

    swapCount: from.getSize 1 + 2 /;

    [to.getSize 0 =] "Destination must me empty!" assert
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
  ] func;

  clear: [
    @head.clear
    @tail.clear
  ] func;

  release: [
    @head.release
    @tail.release
  ] func;
}] func;

@: ["DEQUE" has] [.at] pfunc;
!: ["DEQUE" has] [.at set] pfunc;
fieldCount: ["DEQUE" has] [.getSize] pfunc;
