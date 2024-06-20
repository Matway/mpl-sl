# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Nat32" use
"control.keep"  use

"AbortStatic.abortStatic" use

assignCount: 0n64;
dieCount:    0n64;
initCount:   0n64;

InvocationCounter: [
  resetInvocationCounter

  {
    item: 0;

    ASSIGN: [.item new !item @assignCount inc];
    DIE:    [                @dieCount    inc];
    INIT:   [                @initCount   inc];

    CALL: [abortStatic];
    PRE:  [abortStatic];

    assign: [new !item];

    equal: [.item item =];
    less:  [.item item <];

    hash: [item Nat32 cast];

    inc: [a:; a 1n64 + @a set];

    to: [InvocationCounter [.assign] keep];
  }
];

resetInvocationCounter: [
  0n64 !assignCount
  0n64 !dieCount
  0n64 !initCount
];
