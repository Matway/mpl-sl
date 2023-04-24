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
"control.nil?"   use
"control.when"   use
"control.while"  use

# Intrusive doubly linked list
# Requires item objects to have fields 'prev' and 'next' of type '[Item] Mref'
IntrusiveDeque: [
  Item:;
  {
    SCHEMA_NAME: "IntrusiveDeque<" @Item schemaName & ">" & virtual;

    INIT: [clear];

    DIE: [];

    empty?: [@first nil?];

    append: [
      item:;
      @last @item.@prev.set
      @Item @item.@next.set
      @last nil? [
        [@first nil?] "invalid linked list state" assert
        @item !first
      ] [
        [@last.next nil?] "invalid linked list state" assert
        @item @last.@next.set
      ] if

      @item !last
    ];

    appendAll: [
      other:;
      otherFirst: @other.@first;
      @otherFirst nil? ~ [
        @last nil? [
          [@first nil?] "invalid linked list state" assert
          @otherFirst !first
        ] [
          [@otherFirst.prev nil?] "invalid linked list state" assert
          @last @otherFirst.@prev.set
          [@last.next nil?] "invalid linked list state" assert
          @otherFirst @last.@next.set
        ] if

        [other.@last nil? ~] "invalid linked list state" assert
        @other.@last !last
        @Item @other.!first
        @Item @other.!last
      ] when
    ];

    clear: [
      @Item !first
      @Item !last
    ];

    cut: [
      item:;
      prev: @item.prev;
      next: @item.next;
      @prev nil? [
        [@first @item is] "invalid linked list state" assert
        @next !first
      ] [
        [@prev.next @item is] "invalid linked list state" assert
        @next @prev.@next.set
      ] if

      @next nil? [
        [@last @item is] "invalid linked list state" assert
        @prev !last
      ] [
        [@next.prev @item is] "invalid linked list state" assert
        @prev @next.@prev.set
      ] if
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
            @item nil? [
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
            @item nil? [
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
              @item nil? [
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

    cutFirst: [
      [empty? ~] "deque is empty" assert
      item: @first;
      @item.next !first
      @first nil? [
        [@last @item is] "invalid linked list state" assert
        @Item !last
      ] [
        [@first.prev @item is] "invalid linked list state" assert
        @Item @first.@prev.set
      ] if
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
            @item nil? [FALSE] [
              @item @body call ~ dup ~ [
                1 !count
                next: @item.next;
                @next @prev.@next.set
                @next nil? [
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

    cutLast: [
      [empty? ~] "deque is empty" assert
      prev: @last.prev;
      @prev nil? [
        [@first @last is] "invalid linked list state" assert
        @Item !first
      ] [
        [@prev.next @last is] "invalid linked list state" assert
        @Item @prev.@next.set
      ] if

      @prev !last
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
            @item nil? [FALSE] [
              @item @body call ~ dup ~ [
                1 !count
                prev: @item.prev;
                @prev nil? [
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

    iter: [{
      Item: virtual @Item Ref;
      item: @first;

      next: [
        @item nil? [@Item FALSE] [
          @item
          @item.next !item
          TRUE
        ] if
      ];
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
      @next nil? [
        [@last nil?] "invalid linked list state" assert
        @item !last
      ] [
        [@next.prev nil?] "invalid linked list state" assert
        @item @next.@prev.set
      ] if
    ];

    reverse: [
      empty? ~ [
        item: @first.next;
        @item nil? ~ [
          prev: @first;
          [@prev.prev @Item is] "invalid linked list state" assert
          @item @prev.@prev.set
          @Item @prev.@next.set

          [
            next: @item.next;
            [@item.prev @prev is] "invalid linked list state" assert
            @next @item.@prev.set
            @prev @item.@next.set
            @next nil? ~ dup [
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
      Item: virtual @Item Ref;
      item: @last;

      next: [
        @item nil? [@Item FALSE] [
          @item
          @item.prev !item
          TRUE
        ] if
      ];
    }];

    validate: [
      DEBUG [
        item: @Item;
        next: @first;
        [@next nil? ~] [
          [@next.prev @item is] "invalid linked list state" ensure
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
