# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Ref"    use
"control.assert" use
"control.dup"    use
"control.ensure" use
"control.isNil"  use
"control.when"   use
"control.while"  use

# Intrusive singly linked list
# Requires item objects to have field 'next' of type '[Item] Mref'
IntrusiveQueue: [
  Item:;
  {
    SCHEMA_NAME: "IntrusiveQueue<" @Item schemaName & ">" & virtual;

    INIT: [clear];

    DIE: [];

    empty?: [@first isNil];

    append: [
      item:;
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

    cutAllIf: [
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
                ] when
              ] if
            ] loop
          ] when
        ] while
      ] when

      count
    ];

    cutFirst: [
      [empty? ~] "queue is empty" assert
      item: @first;
      @item.next !first
      @first isNil [
        [@last @item is] "invalid linked list state" assert
        @Item !last
      ] when
    ];

    cutIf: [
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
                ] when
              ] when
            ] if
          ] loop
        ] if
      ] when

      count
    ];

    iter: [{
      Item: virtual @Item Ref;
      item: @first;

      next: [
        @item isNil [@Item FALSE] [
          @item
          @item.next !item
          TRUE
        ] if
      ];
    }];

    popFirst: [
      [empty? ~] "queue is empty" assert
      @first
      cutFirst
    ];

    prepend: [
      item:;
      next: @first;
      @next @item.@next.set
      @item !first
      @next isNil [
        [@last isNil] "invalid linked list state" assert
        @item !last
      ] when
    ];

    reverse: [
      empty? ~ [
        item: @first.next;
        @item isNil ~ [
          prev: @first;
          @Item @prev.@next.set

          [
            next: @item.next;
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

    validate: [
      DEBUG [
        item: @Item;
        next: @first;
        [@next isNil ~] [
          @next !item
          @next.next !next
        ] while

        [@last @item is] "invalid linked list state" ensure
      ] when
    ];

    Item:  @Item Ref virtual;
    first: @Item;
    last:  @Item;
  }
];
