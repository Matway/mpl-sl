"control.Ref" use
"control.assert" use
"control.dup" use
"control.ensure" use
"control.isNil" use
"control.when" use
"control.while" use

# Intrusive doubly linked list
# Requires item objects to have fields 'prev' and 'next' of type '[Item] Mref'
IntrusiveDeque: [{
  INIT: [clear];

  DIE: [];

  empty?: [@first isNil];

  append: [
    item:;
    @last @item.@prev.set
    @Item @item.@next.set
    @last isNil [
      [@first isNil] "invalid linked list state" assert
      @item !first
    ] [
      [@last.next isNil] "invalid linked list state" assert
      @item @last.@next.set
    ] if

    @item !last
  ];

  clear: [
    @Item !first
    @Item !last
  ];

  cutFirst: [
    [empty? ~] "deque is empty" assert
    item: @first;
    @item.next !first
    @first isNil [
      [@last @item is] "invalid linked list state" assert
      @Item !last
    ] [
      [@first.prev @item is] "invalid linked list state" assert
      @Item @first.@prev.set
    ] if
  ];

  cutLast: [
    [empty? ~] "deque is empty" assert
    prev: @last.prev;
    @prev isNil [
      [@first @last is] "invalid linked list state" assert
      @Item !first
    ] [
      [@prev.next @last is] "invalid linked list state" assert
      @Item @prev.@next.set
    ] if

    @prev !last
  ];

  iter: [{
    item: @first;

    valid: [@item isNil ~];
    get: [@item];
    next: [@item.next !item];
  }];

  popFirst: [
    [empty? ~] "deque is empty" assert
    @first
    cutFirst
  ];

  popLast: [
    [empty? ~] "deque is empty" assert
    @last
    cutLast
  ];

  prepend: [
    item:;
    next: @first;
    @Item @item.@prev.set
    @next @item.@next.set
    @item !first
    @next isNil [
      [@last isNil] "invalid linked list state" assert
      @item !last
    ] [
      [@next.prev isNil] "invalid linked list state" assert
      @item @next.@prev.set
    ] if
  ];

  removeAllIf: [
    body:;
    count: 0;

    empty? ~ [
      item: @first;
      skip: FALSE;
      @item @body call [
        [
          count 1 + !count
          prev: @item;
          @item.next !item
          @item isNil [
            @Item !first
            [@last @prev is] "invalid linked list state" assert
            @Item !last
            TRUE !skip
            FALSE
          ] [
            @item @body call dup ~ [
              @item !first
              [@item.prev @prev is] "invalid linked list state" assert
              @Item @item.@prev.set
            ] when
          ] if
        ] loop
      ] when

      [skip ~] [
        lastToKeep: @item;

        [
          @item.next !item
          @item isNil [
            TRUE !skip
            FALSE
          ] [
            @item @body call ~ dup [
              @item !lastToKeep
            ] when
          ] if
        ] loop

        skip ~ [
          [
            count 1 + !count
            prev: @item;
            @item.next !item
            @item isNil [
              @Item @lastToKeep.@next.set
              [@last @prev is] "invalid linked list state" assert
              @lastToKeep !last
              TRUE !skip
              FALSE
            ] [
              @item @body call dup ~ [
                @item @lastToKeep.@next.set
                [@item.prev @prev is] "invalid linked list state" assert
                @lastToKeep @item.@prev.set
              ] when
            ] if
          ] loop
        ] when
      ] while
    ] when

    count
  ];

  removeIf: [
    body:;
    count: 0;
    empty? ~ [
      item: @first;
      @item @body call [
        1 !count
        cutFirst
      ] [
        [
          prev: @item;
          @item.next !item
          @item isNil [FALSE] [
            @item @body call ~ dup ~ [
              1 !count
              next: @item.next;
              @next @prev.@next.set
              @next isNil [
                [@last @item is] "invalid linked list state" assert
                @prev !last
              ] [
                [@next.prev @item is] "invalid linked list state" assert
                @prev @next.@prev.set
              ] if
            ] when
          ] if
        ] loop
      ] if
    ] when

    count
  ];

  removeLastIf: [
    body:;
    count: 0;
    empty? ~ [
      item: @last;
      @item @body call [
        1 !count
        cutLast
      ] [
        [
          next: @item;
          @item.prev !item
          @item isNil [FALSE] [
            @item @body call ~ dup ~ [
              1 !count
              prev: @item.prev;
              @prev isNil [
                [@first @item is] "invalid linked list state" assert
                @next !first
              ] [
                [@prev.next @item is] "invalid linked list state" assert
                @next @prev.@next.set
              ] if

              @prev @next.@prev.set
            ] when
          ] if
        ] loop
      ] if
    ] when

    count
  ];

  reverse: [
    empty? ~ [
      item: @first.next;
      @item isNil ~ [
        prev: @first;
        [@prev.prev @Item is] "invalid linked list state" assert
        @item @prev.@prev.set
        @Item @prev.@next.set

        [
          next: @item.next;
          [@item.prev @prev is] "invalid linked list state" assert
          @next @item.@prev.set
          @prev @item.@next.set
          @next isNil ~ dup [
            @item !prev
            @next !item
          ] when
        ] loop

        firstItem: @first;
        @item !first
        [@last @item is] "invalid linked list state" assert
        @firstItem !last
      ] when
    ] when
  ];

  reverseIter: [{
    item: @last;

    valid: [@item isNil ~];
    get: [@item];
    next: [@item.prev !item];
  }];

  validate: [
    DEBUG [
      item: @Item;
      next: @first;
      [@next isNil ~] [
        [@next.prev @item is] "invalid linked list state" ensure
        @next !item
        @next.next !next
      ] while

      [@last @item is] "invalid linked list state" ensure
    ] when
  ];

  virtual SCHEMA_NAME: "IntrusiveDeque";
  virtual Item: Ref;
  first: @Item;
  last: @Item;
}];
