"control.&&" use
"control.assert" use
"control.pfunc" use
"control.when" use
"memory.mplFree" use
"memory.mplMalloc" use

AVLMap: [
  value:;
  key:;

  {
    virtual AVL_MAP: ();
    schema keyType: @key;
    schema valueType: @value;

    makeNode: [{
      copy value:;
      copy key:;
      balance: 0 dynamic;
      left: 0nx dynamic;
      right: 0nx dynamic;
    }];

    schema nodeType: key newVarOfTheSameType value newVarOfTheSameType makeNode;

    asNode: [@nodeType addressToReference];

    root: 0nx dynamic;

    find: [
      key:;
      [
        result: {
          success: FALSE;
          value: 0nx @valueType addressToReference;
        };

        current: root copy;
        [
          current 0nx = [
            FALSE
          ] [
            curNode: current asNode;
            key curNode.key = [
              {
                success: TRUE;
                value: @curNode.@value;
              } @result set
              FALSE
            ] [
              key curNode.key < [curNode.left] [curNode.right] if @current set
              TRUE
            ] if
          ] if
        ] loop

        result
      ] call
    ];

    fixRotateLeft: [
      addr:;
      n: addr asNode;
      r: n.right asNode;
      r.balance 1 = [
        rl: r.left asNode;
        rl.balance 0 > [-1][0] if @r.@balance set
        rl.balance 0 < [ 1][0] if @n.@balance set
        0 @rl.@balance set

        tmp: rl.left copy;
        addr @rl.@left set
        r.left @addr set
        rl.right @r.@left set
        n.right @rl.@right set
        tmp @n.@right set
      ] [
        r.balance 0 = [
          -1 @n.@balance set
          1 @r.@balance set
        ] [
          0 @n.@balance set
          0 @r.@balance set
        ] if

        tmp: n.right copy;
        r.left @n.@right set
        addr @r.@left set
        tmp @addr set
      ] if
    ];

    fixRotateRight: [
      addr:;
      n: addr asNode;
      l: n.left asNode;
      l.balance -1 = [
        lr: l.right asNode;
        lr.balance 0 < [ 1][0] if @l.@balance set
        lr.balance 0 > [-1][0] if @n.@balance set
        0 @lr.@balance set

        tmp: lr.right copy;
        addr @lr.@right set
        l.right @addr set
        lr.left @l.@right set
        n.left @lr.@left set
        tmp @n.@left set
      ] [
        l.balance 0 = [
          1 @n.@balance set
          -1 @l.@balance set
        ] [
          0 @n.@balance set
          0 @l.@balance set
        ] if

        tmp: n.left copy;
        l.right @n.@left set
        addr @l.@right set
        tmp @addr set
      ] if
    ];

    swapNodes: [
      addr2:;
      addr1:;
      addr1 addr2 = ~ [
        node1: addr1 asNode;
        node2: addr2 asNode;
        iswap: [i1:; i2:; tmp: i1 copy; i2 @i1 set tmp @i2 set];
        @node1.@balance @node2.@balance iswap

        node1.left addr2 = [
          tmp: addr2 copy;
          node2.left @addr2 set
          addr1 @node2.@left set
          tmp @addr1 set
          @node1.@right @node2.@right iswap
          @node2.@left
        ] [
          node1.right addr2 = [
            tmp: addr2 copy;
            node2.right @addr2 set
            addr1 @node2.@right set
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
      ] [
        @addr1
      ] if
    ];

    insert: [
      valueIsMoved: isMoved;
      value:;
      keyIsMoved: isMoved;
      key:;

      [
        # stage1: find prime node
        current: @root;
        prime: @root;
        [
          current 0nx = [
            FALSE
          ] [
            curNode: current asNode;
            [key curNode.key = ~] "Inserting existing element!" assert
            curNode.balance 0 = ~ [@current !prime] when
            key curNode.key < [@curNode.@left !current] [@curNode.@right !current] if
            TRUE
          ] if
        ] loop

        addr: nodeType storageSize mplMalloc;
        newNode: addr asNode;
        @newNode manuallyInitVariable
        valueIsMoved [
          keyIsMoved [@key move @value move makeNode @newNode set] [@key @value move makeNode @newNode set] if
        ] [
          keyIsMoved [@key move @value makeNode @newNode set] [@key @value makeNode @newNode set] if
        ] if

        addr @current set

        current prime is ~ [
          # stage2: correct balance value
          p: @prime;
          [
            pNode: p asNode;
            pNode.key newNode.key < [
              pNode.balance 1 - @pNode.@balance set
              @pNode.@right !p
            ] [
              pNode.balance 1 + @pNode.@balance set
              @pNode.@left !p
            ] if
            p current is ~
          ] loop

          # stage3: rebalance
          primeNode: prime asNode;
          primeNode.balance 2 = [
            @prime fixRotateRight
          ] [
            primeNode.balance -2 = [
              @prime fixRotateLeft
            ] [
            ] if
          ] if
        ] when
      ] call
    ];

    erase: [
      key:;
      [
        current: @root;
        prime: @root;
        last: FALSE dynamic;
        prev: @root;
        haveP: FALSE dynamic;
        dropped: 0nx;
        droppedRef: @current;

        [
          current 0nx = [
            FALSE
          ] [
            curNode: current asNode;
            haveP [
              curNode.balance 0 = [curNode.left 0nx = ~] && [
                @current !prime
              ] [
                pNode: prev asNode;
                last [pNode.balance 1 =][pNode.balance -1 =] if [
                  last [pNode.left copy] [pNode.right copy] if asNode .balance 0 = [@prev !prime] when
                ] when
              ] if
            ] when

            TRUE @haveP set
            @current !prev
            key curNode.key = [
              @current !droppedRef
              @current @dropped set
              FALSE @last set
              @curNode.@left !current
            ] [
              key curNode.key < [
                FALSE @last set
                @curNode.@left !current
              ] [
                TRUE @last set
                @curNode.@right !current
              ] if
            ] if
            TRUE
          ] if
        ] loop

        [dropped 0nx = ~] "Erasing unexisting element!" assert


        [
          prime prev is ~ [
            primeNode: prime asNode;
            primeNode.key key < [
              primeNode.balance 1 + @primeNode.@balance set
              primeNode.balance 2 = [
                @prime fixRotateRight
                prime asNode.@right !prime
              ] when
              prime dropped = [@prime !droppedRef] when
              prime asNode.@right !prime
            ] [
              primeNode.balance 1 - @primeNode.@balance set
              primeNode.balance -2 = [
                @prime fixRotateLeft
                @prime asNode.@left !prime
              ] when
              prime dropped = [@prime !droppedRef] when
              @prime asNode.@left !prime
            ] if
            TRUE
          ] &&
        ] loop


        [droppedRef asNode.key key =] "Invalid dropped node!" assert

        @droppedRef @prev swapNodes !droppedRef

        droppedNode: droppedRef asNode;
        droppedChild: droppedNode.left 0nx = [droppedNode.right copy][droppedNode.left copy] if;

        droppedRef asNode manuallyDestroyVariable
        nodeType storageSize droppedRef mplFree
        droppedChild @droppedRef set
      ] call
    ];

    debugPrint: [
      "Debug print" print LF print

      debugPrintImpl: [
        copy depth:;
        copy nodeAddr:;
        recursive

        nodeAddr 0nx = ~ [
          node: nodeAddr asNode;
          node.left depth 1 + debugPrintImpl
          depth ["  " print] times
          ("(" node.balance ") " node.key ": " node.value LF) printList
          node.right depth 1 + debugPrintImpl
        ] when
      ];

      root 0 dynamic debugPrintImpl
    ];

    clear: [
      clearImpl: [
        copy nodeAddr:;
        recursive

        nodeAddr 0nx = ~ [
          node: nodeAddr asNode;
          node.left clearImpl
          node.right clearImpl
          nodeType storageSize nodeAddr mplFree
        ] when
      ];

      root clearImpl
      0nx dynamic @root set
    ];

    INIT: [0nx dynamic @root set];

    ASSIGN: [
      other:;
      clear

      cloneImpl: [
        copy nodeAddr:;
        recursive

        nodeAddr 0nx = [
          0nx
        ] [
          node: nodeAddr asNode;
          result: 0nx;
          nodeType storageSize mplMalloc @result set
          resultNode: result asNode;
          @resultNode manuallyInitVariable
          node.left  cloneImpl @resultNode.@left set
          node.right cloneImpl @resultNode.@right set
          node.key             @resultNode.@key set
          node.value           @resultNode.@value set
          node.balance         @resultNode.@balance set
          result
        ] if
      ];

      other.root cloneImpl @root set
    ];

    DIE: [
      clear
    ];
  }];

each: [b:; "AVL_MAP" has] [
  eachInTreeBody:;
  eachInTreeTree:;
  eachImpl: [
    copy eachNodeAddr:;
    recursive

    eachNodeAddr 0nx = ~ [
      eachNode: eachNodeAddr @eachInTreeTree.asNode;
      eachNode.left eachImpl
      {key: eachNode.key; value: @eachNode.@value;} @eachInTreeBody call
      eachNode.right eachImpl
    ] when
  ];

  eachInTreeTree.root eachImpl
] pfunc;
