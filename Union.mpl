# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.each" use
"control.Int32"  use
"control.Nat16"  use
"control.Nat32"  use
"control.Nat64"  use
"control.Nat8"   use
"control.Ref"    use
"control.max"    use

Union: [{
  SCHEMA_NAME: "Union" virtual;
  Items: Ref virtual;

  get: [
    key:;
    data storageAddress key @Items @ addressToReference
  ];

  # Private

  MAXIMUM_ALIGNMENT: [
    1
    Items [alignment Int32 cast max] each
  ];

  MAXIMUM_SIZE: [
    1
    Items [storageSize Int32 cast max] each
  ];

  data:
    MAXIMUM_ALIGNMENT 1 = [Nat8] [
      MAXIMUM_ALIGNMENT 2 = [Nat16] [
        MAXIMUM_ALIGNMENT 4 = [Nat32] [
          MAXIMUM_ALIGNMENT 8 = [Nat64] [
            "Invalid alignment value" raiseStaticError
          ] if
        ] if
      ] if
    ] if
  ;

  pad: Nat8 MAXIMUM_SIZE MAXIMUM_ALIGNMENT - array;
}];
