# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Union.Union"         use
"algorithm.="         use
"algorithm.each"      use
"algorithm.enumerate" use
"control.Nat16"       use
"control.Nat32"       use
"control.Nat64"       use
"control.Nat8"        use
"control.compilable?" use
"control.ensure"      use
"control.max"         use
"control.unwrap"      use

UNION_TEST: [];

# Can create empty unions.
[
  [[emptyUnion: () Union;] compilable?] "Empty union creation failed" ensure
] call

# Can create virtual unions.
[
  [[virtualUnion: (()) Union;] compilable?] "Virtual union creation failed" ensure
] call

# Unions are properly aligned.
[
  (
    ()
    (())
    (() Nat8)
    (() Nat8 Nat16)
    (() Nat8 Nat16 Nat32)
    (() Nat8 Nat16 Nat32 Nat64)
  ) [
    Schemas:;
    maxAlignment: 0nx @Schemas [alignment max] each;
    union: @Schemas Union;
    [@union alignment maxAlignment =] "Union is improperly aligned" ensure
  ] each
] call

# Can access and modify union items.
[
  items: (
    ()
    1n8
    2n16
    3n32
    4n64
    (5n64 6n64)
  );

  union: @items Union;

  items 0 enumerate [
    key: item: unwrap;;
    [[key union.get] compilable?] "Union item access failed" ensure

    @item key @union.get set
    [@item key union.get =] "Invalid union item value" ensure
  ] each
] call
