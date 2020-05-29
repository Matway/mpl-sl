"control.Ref" use
"control.drop" use
"control.pfunc" use
"control.times" use

fieldIsRef: [drop drop FALSE];
fieldIsRef: [index:object:;; index @object @ Ref index @object ! TRUE] [drop drop TRUE] pfunc;
fieldIsref: [isConst] [0 .ERROR_CAN_ONLY_HANDLE_MUTABLE_OBJECTS] pfunc;

unwrapField: [
  objectIsMoved: isMoved;
  object:;
  index:;

  index @object fieldIsRef [index @object @] [index @object @ objectIsMoved moveIf copy] uif
];

unwrapFields: [
  object:;
  @object fieldCount [i @object unwrapField] times
];

insertField: [
  insertField_objectIsMoved: isMoved;
  insertField_object:;
  insertField_name:;
  insertField_index:;
  insertField_wrappedValue:;
  insertField_loopIndex: 0 static;
  insertField_uloopBody: [
    insertField_index insertField_loopIndex = [
      0 static @insertField_wrappedValue unwrapField insertField_name def
    ] [] uif

    insertField_loopIndex @insertField_object fieldCount < [
      insertField_loopIndex @insertField_object unwrapField @insertField_object insertField_loopIndex fieldName def
      insertField_loopIndex 1 static + !insertField_loopIndex
      @insertField_uloopBody ucall
    ] [
    ] uif
  ];

  {@insertField_uloopBody ucall}
];

removeField: [
  removeField_objectIsMoved: isMoved;
  removeField_object:;
  removeField_index:;

  removeField_loopIndex: 0;
  removeField_uloopBody: [
    removeField_loopIndex @removeField_object fieldCount < [
      removeField_index removeField_loopIndex = ~ [
        removeField_loopIndex @removeField_object unwrapField @removeField_object removeField_loopIndex fieldName def
      ] [] uif

      removeField_loopIndex 1 + !removeField_loopIndex
      @removeField_uloopBody ucall
    ] [
    ] uif
  ];

  {@removeField_uloopBody ucall}
];
