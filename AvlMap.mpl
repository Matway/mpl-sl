# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.<"      use
"algorithm.="      use
"control.&&"       use
"control.<"        use
"control.="        use
"control.Int32"    use
"control.Natx"     use
"control.Ref"      use
"control.assert"   use
"control.when"     use
"memory.mplFree"   use
"memory.mplMalloc" use

AvlMap: [
  Key: Value: Ref virtual; Ref virtual;

  toNode2: [
    key: value:;;
    {
      key:     @key   new;
      value:   @value new;
      balance: 0;
      left:    0nx;
      right:   0nx;
    }
  ];

  {
    SCHEMA_NAME: "AvlMap<" @Key schemaName & ", " & @Value schemaName & ">" & virtual;

    Node: @Key newVarOfTheSameType @Value newVarOfTheSameType toNode2 Ref virtual;

    root: 0nx dynamic;

    clear: [
      [
        nodeAddress:;
        nodeAddress 0nx = ~ [
          node: nodeAddress asNode;
          node.left  avlMapClear
          node.right avlMapClear
          node manuallyDestroyVariable
          Node storageSize nodeAddress mplFree
        ] when
      ] !avlMapClear

      root avlMapClear
      0nx dynamic !root
    ];

    debugPrint: [
      "String.printList" use
      "control.print"    use
      "control.times"    use

      [
        nodeAddress: depth:;;
        nodeAddress 0nx = ~ [
          node: nodeAddress asNode;

          depth ["  " print] times
          ("(" node.balance ") " node.@key.item ": " node.@value.item LF) printList

          node.left  depth 1 + avlMapDebugPrint
          node.right depth 1 + avlMapDebugPrint
        ] when
      ] !avlMapDebugPrint

      root 0 avlMapDebugPrint
    ];

    each: [
      body:;

      [
        nodeAddress:;
        nodeAddress 0nx = ~ [
          node: nodeAddress asNode;
          {key: node.@key const; value: @node.@value;} body
          node.left  avlMapEach
          node.right avlMapEach
        ] when
      ] !avlMapEach

      root avlMapEach
    ];

    erase: [
      key:;
      [
        currentRef:     @root;
        previousRef:    @root;
        primeRef:       @root;
        droppedRef:     @currentRef;
        droppedAddress: 0nx;
        last:           FALSE dynamic;
        haveP:          FALSE dynamic;

        [
          currentRef 0nx = ~ [
            currentNode: currentRef asNode;
            haveP [
              currentNode.balance 0 = [currentNode.left 0nx = ~] && [@currentRef !primeRef] [
                previousNode: previousRef asNode;
                last [previousNode.balance 1 =] [previousNode.balance -1 =] if [
                  last [previousNode.left new] [previousNode.right new] if asNode.balance 0 = [@previousRef !primeRef] when
                ] when
              ] if
            ] when

            TRUE !haveP
            @currentRef !previousRef
            @key currentNode.@key = [
              @currentRef        !droppedRef
              currentRef new     !droppedAddress
              @currentNode.@left !currentRef
              FALSE              !last
            ] [
              @key currentNode.@key < [
                @currentNode.@left !currentRef
                FALSE              !last
              ] [
                @currentNode.@right !currentRef
                TRUE                !last
              ] if
            ] if
            TRUE
          ] &&
        ] loop

        [droppedAddress 0nx = ~] "Attempted to erase a Node that was not inserted" assert

        [
          primeRef previousRef is ~ [
            primeNode: primeRef asNode;
            primeNode.@key @key < [
              primeNode.balance 1 + @primeNode.!balance
              primeNode.balance 2 = [
                @primeRef fixRotateRight
                primeRef asNode.@right !primeRef
              ] when
              primeRef droppedAddress = [@primeRef !droppedRef] when
              primeRef asNode.@right !primeRef
            ] [
              primeNode.balance 1 - @primeNode.!balance
              primeNode.balance -2 = [
                @primeRef fixRotateLeft
                primeRef asNode.@left !primeRef
              ] when
              primeRef droppedAddress = [@primeRef !droppedRef] when
              primeRef asNode.@left !primeRef
            ] if
            TRUE
          ] &&
        ] loop

        [droppedRef asNode.@key @key =] "Invalid dropped node" assert

        @droppedRef @previousRef swapNodes !droppedRef

        droppedNode:         droppedRef asNode;
        droppedChildAddress: droppedNode.left 0nx = [droppedNode.right new] [droppedNode.left new] if;

        droppedRef asNode manuallyDestroyVariable
        Node storageSize droppedRef mplFree
        droppedChildAddress @droppedRef set
      ] call
    ];

    find: [
      key:;
      [
        result: @Node.@value Ref;

        currentAddress: root new;
        [
          currentAddress 0nx = ~ [
            currentNode: currentAddress asNode;
            @key currentNode.@key = [
              @currentNode.@value !result
              FALSE
            ] [
              @key currentNode.@key < [currentNode.left new] [currentNode.right new] if !currentAddress
              TRUE
            ] if
          ] &&
        ] loop

        @result
      ] call
    ];

    insert: [
      key: value:;;
      [
        # stage1: find prime node
        currentRef: @root;
        primeRef0:  @root;
        [
          currentRef 0nx = ~ [
            currentNode: currentRef asNode;
            [@key currentNode.@key = ~] "Attempted to insert node with key that already exist" assert
            currentNode.balance 0 = ~ [@currentRef !primeRef0] when
            @key currentNode.@key < [@currentNode.@left !currentRef] [@currentNode.@right !currentRef] if
            TRUE
          ] &&
        ] loop

        newAddress: Node storageSize mplMalloc;
        newNode:    newAddress asNode;

        @newNode manuallyInitVariable
        @key @value toNode2 @newNode set
        newAddress @currentRef set

        currentRef primeRef0 is ~ [
          # stage2: correct balance value
          primeRef1: @primeRef0;
          [
            primeNode1: primeRef1 asNode;
            primeNode1.@key newNode.@key < [
              primeNode1.balance 1 - @primeNode1.!balance
              @primeNode1.@right !primeRef1
            ] [
              primeNode1.balance 1 + @primeNode1.!balance
              @primeNode1.@left !primeRef1
            ] if

            primeRef1 currentRef is ~
          ] loop

          # stage3: balance
          primeNode0: primeRef0 asNode;
          primeNode0.balance 2 = [@primeRef0 fixRotateRight] [
            primeNode0.balance -2 = [@primeRef0 fixRotateLeft] when
          ] if
        ] when
      ] call
    ];

    private ASSIGN: [
      other:;

      [
        nodeAddress:;
        result: 0nx;

        nodeAddress 0nx = ~ [
          Node storageSize mplMalloc !result
          node:       nodeAddress asNode;
          resultNode: result asNode;
          @resultNode manuallyInitVariable
          node.left   avlMapClone @resultNode.!left
          node.right  avlMapClone @resultNode.!right
          node.@key   const new @resultNode.!key
          node.@value const new @resultNode.!value
          node.balance      new @resultNode.!balance
        ] when

        result
      ] !avlMapClone

      clear
      other.root avlMapClone !root
    ];

    private DIE: [clear];

    private INIT: [0nx dynamic !root];

    private asNode: [@Node addressToReference];

    private fixRotateLeft: [
      addr:;
      n: addr asNode;
      r: n.right asNode;
      r.balance 1 = [
        rl: r.left asNode;
        rl.balance 0 > [-1] [0] if @r.!balance
        rl.balance 0 < [ 1] [0] if @n.!balance
        0 @rl.!balance

        tmp: rl.left new;
        addr new @rl.!left
        r.left @addr set
        rl.right new @r .!left
        n.right  new @rl.!right
        tmp      new @n .!right
      ] [
        r.balance 0 = [
          -1 @n.!balance
           1 @r.!balance
        ] [
          0 @n.!balance
          0 @r.!balance
        ] if

        tmp: n.right new;
        r.left new @n.!right
        addr   new @r.!left
        tmp @addr set
      ] if
    ];

    private fixRotateRight: [
      addr:;
      n: addr   asNode;
      l: n.left asNode;
      l.balance -1 = [
        lr: l.right asNode;
        lr.balance 0 < [ 1] [0] if @l.!balance
        lr.balance 0 > [-1] [0] if @n.!balance
        0 @lr.!balance

        tmp: lr.right new;
        addr new @lr.!right
        l.right @addr set
        lr.left new @l .!right
        n.left  new @lr.!left
        tmp     new @n .!left
      ] [
        l.balance 0 = [
           1 @n.!balance
          -1 @l.!balance
        ] [
          0 @n.!balance
          0 @l.!balance
        ] if

        tmp: n.left new;
        l.right new @n.!left
        addr    new @l.!right
        tmp @addr set
      ] if
    ];

    private swapNodes: [
      addr1: addr2:;;
      addr1 addr2 = ~ [
        node1: addr1 asNode;
        node2: addr2 asNode;
        iswap: [i1:; i2:; tmp: i1 new; i2 @i1 set tmp @i2 set];
        @node1.@balance @node2.@balance iswap

        node1.left addr2 = [
          tmp: addr2 new;
          node2.left @addr2 set
          addr1 @node2.@left set
          tmp @addr1 set
          @node1.@right @node2.@right iswap
          @node2.@left
        ] [
          node1.right addr2 = [
            tmp: addr2 new;
            node2.right @addr2 set
            addr1 new   @node2.!right
            tmp @addr1 set
            @node1.@right @node2.@left iswap
            @node2.@right
          ] [
            @node1.@left @node2.@left iswap
            @node1.@right @node2.@right iswap
            @addr1 @addr2 iswap
            @addr2
          ] if
        ] if
      ] [@addr1] if
    ];

    private toNode2: @toNode2;
  }
];

avlMapClear:      {root: Natx;              } {  } {} codeRef;
avlMapClone:      {root: Natx;              } Natx {} codeRef;
avlMapDebugPrint: {depth: Int32; root: Natx;} {  } {} codeRef;
avlMapEach:       {root: Natx;              } {  } {} codeRef;
