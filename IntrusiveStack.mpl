# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

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

  cutAllIf: [
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

  cutLast: [
    [empty? ~] "stack is empty" assert
    @last.prev !last
  ];

  cutLastIf: [
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
              @item.prev @next.@prev.set
            ] when
          ] if
        ] loop
      ] if
    ] when

    count
  ];

  popLast: [
    [empty? ~] "stack is empty" assert
    @last
    cutLast
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
    Item: virtual @Item Ref;
    item: @last;

    next: [
      @item isNil [@Item FALSE] [
        @item
        @item.prev !item
        TRUE
      ] if
    ];
  }];

  SCHEMA_NAME: virtual "IntrusiveStack";
  Item: virtual Ref;
  last: @Item;
}];
