# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"RandomLCG"      use
"algebra.unit"   use
"control.abs"    use
"control.ensure" use
"control.times"  use

"Quaternion" use

QuaternionTest: [];

[
  random: RandomLCG;

  test: [
    q:;
    q2: q matrix quaternion;
    error: 0.0r32 4 [i q @ i q2 @ - abs +] times;
    [error 1.0e-6r32 <] "q and q2 differ" ensure
  ];

  1000 dynamic [
    q: (4 [@random.getr32] times) unit quaternion;
    q test
  ] times
] call
