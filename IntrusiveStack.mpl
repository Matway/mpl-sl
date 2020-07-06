"control.Ref" use
"control.assert" use
"control.dup" use
"control.isNil" use
"control.when" use
"control.while" use

# Intrusive singly linked list
# Requires item objects to have field 'prev' of type '[Item] Mref'
IntrusiveStack: [{
  INIT: [clear];

  DIE: [];

  empty?: [@last isNil];

  append: [
    item:;
    @last @item.@prev.set
    @item !last
  ];

  clear: [@Item !last];

  cutLast: [
    [empty? ~] "stack is empty" assert
    @last.prev !last
  ];

  popLast: [
    [empty? ~] "stack is empty" assert
    @last
    cutLast
  ];

  removeAllIf: [
    body:;
    count: 0;

    empty? ~ [
      item: @last;
      skip: FALSE;
      @item @body call [
        [
          count 1 + !count
          @item.prev !item
          @item isNil [
            @Item !last
            TRUE !skip
            FALSE
          ] [
            @item @body call dup ~ [
              @item !last
            ] when
          ] if
        ] loop
      ] when

      [skip ~] [
        firstToKeep: @item;

        [
          @item.prev !item
          @item isNil [
            TRUE !skip
            FALSE
          ] [
            @item @body call ~ dup [
              @item !firstToKeep
            ] when
          ] if
        ] loop

        skip ~ [
          [
            count 1 + !count
            @item.prev !item
            @item isNil [
              @Item @firstToKeep.@prev.set
              TRUE !skip
              FALSE
            ] [
              @item @body call dup ~ [
                @item @firstToKeep.@prev.set
              ] when
            ] if
          ] loop
        ] when
      ] while
    ] when

    count
  ];

  removeLastIf: [
    body:;
    count: 0;
    empty? ~ [
      @last @body call [
        1 !count
        cutLast
      ] [
        next: @last;

        [
          item: @next.prev;
          @item isNil [FALSE] [
            @item @body call ~ dup [
              @item !next
            ] [
              1 !count
              @item.prev @next.@prev.set
            ] if
          ] if
        ] loop
      ] if
    ] when

    count
  ];

  reverse: [
    empty? ~ [
      item: @last.prev;
      @item isNil ~ [
        next: @last;
        @Item @next.@prev.set

        [
          prev: @item.prev;
          @next @item.@prev.set
          @prev isNil ~ dup [
            @item !next
            @prev !item
          ] when
        ] loop

        @item !last
      ] when
    ] when
  ];

  reverseIter: [{
    item: @last;

    valid: [@item isNil ~];
    get: [@item];
    next: [@item.prev !item];
  }];

  virtual SCHEMA_NAME: "IntrusiveStack";
  virtual Item: Ref;
  last: @Item;
}];
