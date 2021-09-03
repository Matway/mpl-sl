# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algebra" use
"control" use

algebraTest: [];

# trivialTest
[
  [((5)) (3) solve (3 5 /) =]                     "solve error" ensure
  [((3)) (5) solve (5 3 /) =]                     "solve error" ensure
  [((5.0r32)) (3.0r32) solve (3.0r32 5.0r32 /) =] "solve error" ensure
  [((5)) (3) solve (5) = ~]                       "solve error" ensure
] call


# dimention2
[
  [((1 2) (3 4)) (5 6) solve (-4 4) =]                                         "solve dimention2 error" ensure
  [((1.0r32 2.0r32) (3.0r32 4.0r32)) (5.0r32 6.0r32) solve (-4.0r32 4.5r32) =] "solve dimention2 error" ensure
] call

# dimention3
[
  [((1 2 3) (5 6 7) (9 1 2)) (4 8 3) solve (0 -1 2) =] "solve dimention3 error" ensure
  [((1 2 3) (5 0 7) (9 1 2)) (4 8 3) solve (0 0 1) =]  "solve dimention3 error" ensure
  [((1.0r32 2.0r32 3.0r32)
    (5.0r32 0.0r32 7.0r32)
    (9.0r32 1.0r32 2.0r32)) (4.0r32 8.0r32 3.0r32) solve (1.0r32  19.0r32 /
                                                          6.0r32  19.0r32 /
                                                          21.0r32 19.0r32 /
                                                          ) =] "solve dimention3 error" ensure
] call

# dimention4
[
  actual: ((1.0r32 2.0r32 3.0r32 4.0r32)
    (5.0r32 6.0r32 7.0r32 8.0r32)
    (9.0r32 10.0r32 11.5r32 12.0r32)
    (13.0r32 14.0r32 15.0r32 16.5r32)) (1.0r32 2.0r32 3.0r32 4.0r32) solve;
  fail: FALSE;
  THRESHOLD: [1.0e-6r32];
  expected: (-0.5r32 0.75r32 -0.0r32 -0.0r32);

  actual fieldCount [
    fail [i actual @ i expected @ - abs THRESHOLD >] || !fail
  ] times

  [fail ~] "solve dimention4 error" ensure
] call
