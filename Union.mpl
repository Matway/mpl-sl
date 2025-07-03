# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.case" use
"algorithm.each" use
"control.Int32"  use
"control.Nat16"  use
"control.Nat32"  use
"control.Nat64"  use
"control.Nat8"   use
"control.Ref"    use
"control.dup"    use
"control.max"    use
"control.swap"   use
"control.when"   use

Union: [
  Schemas:;
  {
    SCHEMA_NAME: "Union" virtual;

    Schemas: @Schemas dup virtual? ~ [Ref] when virtual;

    get: [
      key:;
      @Schemas key fieldRead dup virtual? ~ [data storageAddress swap addressToReference] when
    ];

    private MAX_ALIGNMENT: [0 @Schemas [alignment   Int32 cast max] each];
    private MAX_SIZE:      [0 @Schemas [storageSize Int32 cast max] each];

    private data: (
      MAX_ALIGNMENT (
        0 [()   ]
        1 [Nat8 ]
        2 [Nat16]
        4 [Nat32]
        8 [Nat64]

        ["Invalid alignment" raiseStaticError]
      ) case

      Nat8 MAX_SIZE MAX_ALIGNMENT - array
    );
  }
];
