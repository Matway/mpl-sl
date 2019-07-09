"objectTools" module

"control" useModule

fieldIsRef: [drop drop FALSE];
fieldIsRef: [index:object:;; index @object @ Ref index @object ! TRUE] [drop drop TRUE] pfunc;
fieldIsref: [isConst] [0 .ERROR_CAN_ONLY_HANDLE_MUTABLE_OBJECTS] pfunc;

unwrapField: [
  objectIsMoved: isMoved;
  object:;
  index:;

  index @object fieldIsRef [index @object @] [index @object @ objectIsMoved moveIf copy] uif
];

insertField: [
  objectIsMoved: isMoved;
  object:;
  name:;
  index:;
  wrappedValue:;
  loopIndex: 0;
  uloopBody: [
    index loopIndex = [
      0 @wrappedValue unwrapField name def
    ] [] uif

    loopIndex @object fieldCount < [
      loopIndex @object unwrapField @object loopIndex fieldName def
      loopIndex 1 + !loopIndex
      @uloopBody ucall
    ] [
    ] uif
  ];

  {@uloopBody ucall}
];

removeField: [
  objectIsMoved: isMoved;
  object:;
  index:;

  loopIndex: 0;
  uloopBody: [
    loopIndex @object fieldCount < [
      index loopIndex = ~ [
        loopIndex @object unwrapField @object loopIndex fieldName def
      ] [] uif

      loopIndex 1 + !loopIndex
      @uloopBody ucall
    ] [
    ] uif
  ];

  {@uloopBody ucall}
];
