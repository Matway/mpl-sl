"control.Ref" use
"control.assert" use
"control.dup" use
"control.isNil" use
"control.when" use
"control.while" use

# Intrusive singly linked list
# Requires item objects to have field 'next' of type '[Item] Mref'
IntrusiveStack: [{
  INIT: [@Item !last];

  DIE: [];

  empty?: [last isNil];

  append: [
    item:;
    @last @item.@prev.set
    @item !last
  ];

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

    [
      empty? [FALSE] [
        last @body call dup [
          cutLast
        ] [
          item: @last; [item.prev isNil ~] [
            item.prev @body call [
              @item.prev.prev @item.@prev.set
            ] [
              @item.prev !item
            ] if
          ] while
        ] if
      ] if
    ] loop
  ];

  removeLastIf: [
    body:;
    empty? ~ [
      last @body call [
        cutLast
      ] [
        item: @last;

        [
          item.prev isNil [FALSE] [
            item.prev @body call ~ dup [
              @item.prev !item
            ] [
              @item.prev.prev @item.@prev.set
            ] if
          ] if
        ] loop
      ] if
    ] when
  ];

  reverseIter: [{
    item: @last;

    valid: [item isNil ~];
    get: [@item];
    next: [@item.prev !item];
  }];

  virtual SCHEMA_NAME: "IntrusiveStack";
  virtual Item: Ref;
  last: @Item;
}];
