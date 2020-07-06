"control.Natx" use
"control.Ref" use
"control.when" use

# Temporary solution until mplc supports recursive schemas
#
# Usage:
#   myRef: @getSchema Mref; # mutable reference
#   myRef: [getSchema Cref] Mref; # immutable reference
#
# getSchema is a function returning object or reference of the required schema
Mref: [{
  INIT: [0nx !data];

  DIE: [];

  ASSIGN: [.data copy !data];

  CALL: [
    data getSchema addressToReference @closure isConst [const] when
  ];

  set: [
    ref: getSchema Ref;
    !ref
    @ref storageAddress !data
  ];

  virtual SCHEMA_NAME: "Mref";
  virtual getSchema:;
  data: Natx;
}];
