"interface" module

interface: [
  methods:;
  {
    virtual InterfaceVtable:
    {} methods fieldCount [
      object:;
      signature: i @methods @;
      (
        (Natx) 0 "self" signature fieldCount 1 - @signature removeField insertField
        signature fieldCount 1 - @signature unwrapField
        {} codeRef
      ) i methods i fieldName @object insertField
    ] times;

    CALL: [
      (
        {
          virtual Vtable: InterfaceVtable;
          CALL: [v: Vtable; v];
        }
      ) 0 "Vtable" {} insertField object:;
      (InterfaceVtable Ref) 1 "vtable" @object insertField
      InterfaceVtable fieldCount [
        object:;
        name: InterfaceVtable i fieldName;
        (
          {
            virtual name: name;
            CALL: [self storageAddress vtable name callField];
          }
        ) i 2 + name @object insertField
      ] times
    ];
  }
];

implement: [
  base: body:;;
  {
    implementationVtable: base.Vtable;
    implementationBase: 1 base removeField;
    implementationBody: @body;

    CALL: [
      ((implementationVtable) 1 "vtable" implementationBase insertField) 0 "base"
      implementationBody
      insertField
    ];

    [
      Object: schema CALL;
      implementationVtable fieldCount [
        virtual name: implementationVtable i fieldName;
        [Object addressToReference name callField] i @implementationVtable !
      ] times
    ] call
  }
];
