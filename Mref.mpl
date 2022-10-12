# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

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

  ASSIGN: [.data new !data];

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
