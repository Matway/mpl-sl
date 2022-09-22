# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"RandomLCG.RandomLCG" use
"algebra.&"           use
"algebra.*"           use
"algebra.PI"          use
"algebra.PI64"        use
"algebra.neg"         use
"algebra.trans"       use
"algebra.unit"        use
"algebra.vector?"     use
"algorithm.each"      use
"control.Real32"      use
"control.Real64"      use
"control.abs"         use
"control.ensure"      use
"control.pfunc"       use
"control.times"       use

"Quaternion.!"                        use
"Quaternion.*"                        use
"Quaternion.+"                        use
"Quaternion.@"                        use
"Quaternion.axisAngleQuaternion"      use
"Quaternion.conj"                     use
"Quaternion.dot"                      use
"Quaternion.fieldCount"               use
"Quaternion.identityQuaternion"       use
"Quaternion.matrix"                   use
"Quaternion.nlerp"                    use
"Quaternion.quaternion"               use
"Quaternion.quaternionCast"           use
"Quaternion.rotationQuaternion"       use
"Quaternion.slerp"                    use
"Quaternion.unit"                     use
"Quaternion.unitChecked"              use
"Quaternion.unitCheckedWithThreshold" use

QuaternionTest: [];

# test helpers
random: RandomLCG;

generateFromRange: [
  from: to:;;
  @random.getr32 to from - * from +
];

equal: [
  v0: v1:;;
  epsilon: 1.0e-6 v0 cast;
  v0 v1 - abs epsilon > ~
];

equal: [
  v0: v1:;;
  v0 vector?
  v1 vector? and
  v0 fieldCount v1 fieldCount = and
] [
  v0: v1:;;
  TRUE
  v0 fieldCount [
    i v0 @ i v1 @ equal and
  ] times
] pfunc;

equal: [
  q0: q1:;;
  q0 "QUATERNION" has
  q1 "QUATERNION" has and
] [
  q0: q1:;;
  q2: q1.entries neg quaternion;
  q0.entries q1.entries equal q0.entries q2.entries equal or
] pfunc;

checkEqual: [
  value0: value1:;;
  [value0 value1 equal] "value0 and value1 differ" ensure
];

testInterpolation: [
  tests: interpolation:;;
  q0: q1: new; new;
  2 [
    tests [
      t:;
      q0 q1 t.fraction                     interpolation t.q checkEqual
      q1 q0 1 t.fraction cast t.fraction - interpolation t.q checkEqual
    ] each
    q1.entries neg @q1.!entries
  ] times
];

# axisAngleQuaternion
[
  axis: (1.0 2.0 neg 3.0) unit;
  tests: (
    {angle:   0.0; q: 0.0 identityQuaternion                                                                 ;}
    {angle:  35.0; q: (0.08036700542578 0.160734010851561 neg 0.241101016277342 0.953716950748227) quaternion;}
    {angle:  90.0; q: (0.18898223650461 0.377964473009227 neg 0.566946709513841 0.707106781186548) quaternion;}
  );

  tests [
    t:;
    angle: t.angle PI64 * 180.0 /;
    axis     (angle)        &     axisAngleQuaternion t.q                                       checkEqual
    axis     (angle)        & neg axisAngleQuaternion t.q                                       checkEqual
    axis     (angle PI64 +) &     axisAngleQuaternion axis (angle PI64 -) & axisAngleQuaternion checkEqual
    axis neg (angle)        &     axisAngleQuaternion axis (angle neg   ) & axisAngleQuaternion checkEqual

    63 [
      angle': 0.1 i 0.0 cast *;
      q:  axis (angle angle' +) & axisAngleQuaternion;
      q0: axis (angle         ) & axisAngleQuaternion;
      q1: axis (angle'        ) & axisAngleQuaternion;

      q q0 q1 * checkEqual
      q q1 q0 * checkEqual
    ] times
  ] each
] call

# identityQuaternion
[
  Real32 identityQuaternion (0.0r32 0.0r32 0.0r32 1.0r32) quaternion checkEqual
  Real64 identityQuaternion (0.0    0.0    0.0    1.0   ) quaternion checkEqual
] call

# matrix
[
  q0: (1.0 2.0 neg 3.0 4.0) quaternion unit;

  rotationMatrix: (
    (0.13333333 0.93333333 neg 0.33333333 neg)
    (0.66666667 0.33333333     0.66666667 neg)
    (0.73333333 0.13333333 neg 0.66666667    )
  );
  q0 matrix trans rotationMatrix checkEqual

  100 dynamic [
    q0: (4 [-1.0r32 1.0r32 generateFromRange] times) unit quaternion;
    q1: (4 [-1.0r32 1.0r32 generateFromRange] times) unit quaternion;

    m:  q0 matrix q1 matrix *;
    m': q0 q1 * matrix;
    m m' checkEqual
  ] times
] call

# quaternion
[
  100 dynamic [
    q0: (4 [-1.0r32 1.0r32 generateFromRange] times) unit quaternion;
    q1: q0 matrix quaternion;
    q0 q1 checkEqual
  ] times
] call

# quaternionCast
[
  q0: (1.2    3.4    neg 5.6    7.8   ) quaternion;
  q1: (1.2r32 3.4r32 neg 5.6r32 7.8r32) quaternion;

  q0 Real32 quaternionCast q1 checkEqual
  q1 Real64 quaternionCast q0 checkEqual
] call

# rotationQuaternion
[
  random: RandomLCG;
  100 dynamic [
    axis: (3 [-1.0r32 1.0r32 generateFromRange] times) unit;
    angle: 0.0r32 2.0r32 PI * generateFromRange;
    axis (angle) & axisAngleQuaternion axis angle * rotationQuaternion checkEqual
  ] times
] call

# ! @ fieldCount
[
  q0: (1.0 2.0 neg 3.0 4.0) quaternion;
  q1: (1.0 5.5     3.0 4.0) quaternion;

  q0 fieldCount 4 checkEqual
  2 q0 @ 3.0 checkEqual
  5.5 2 @q0 !
  2 q0 @ 5.5 checkEqual
] call

# Basic operations
[
  q0: (1.0 2.0 neg 3.0 4.0    ) quaternion;
  q1: (5.0 6.0     7.0 8.0 neg) quaternion;

  iq: Real64 identityQuaternion;
  q: (0.182574185835055 0.365148371670111 neg 0.5477225575051 0.7302967433402) quaternion;
  tests: (
    {operation: [q0 q1 + ]; expected: ( 6.0  4.0     10.0      4.0 neg) quaternion;}
    {operation: [q0 2.0 *]; expected: ( 2.0  4.0 neg  6.0      8.0    ) quaternion;}
    {operation: [2.0 q0 *]; expected: ( 2.0  4.0 neg  6.0      8.0    ) quaternion;}
    {operation: [q0 q1 * ]; expected: (44.0 32.0     12.0 neg 46.0 neg) quaternion;}
    {operation: [q0 iq * ]; expected: q0                                          ;}
    {operation: [iq q0 * ]; expected: q0                                          ;}
    {operation: [q0 conj ]; expected: ( 1.0  2.0 neg  3.0      4.0 neg) quaternion;}

    {operation: [q0 q1 dot]; expected: 18.0 neg;}

    {operation: [q0 unit                          ]; expected: q ;}
    {operation: [q0 unitChecked                   ]; expected: q ;}
    {operation: [q0 100.0 unitCheckedWithThreshold]; expected: iq;}
  );

  tests [
    t:;
    t.operation t.expected checkEqual
  ] each
] call

# Interpolation
# nlerp
[
  q0: (1.0 2.0 neg 3.0 4.0    ) quaternion;
  q1: (5.0 6.0     7.0 8.0 neg) quaternion;
  tests: (
    {fraction: 0.0; q: q0 unit                                                                                        ;}
    {fraction: 0.3; q: (0.129913960492326 neg 0.519655841969305 neg 0.0                   0.84444074320012) quaternion;}
    {fraction: 0.6; q: (0.298083609185736 neg 0.504449184775861 neg 0.343942625983541 neg 0.73374426876488) quaternion;}
    {fraction: 1.0; q: q1 unit                                                                                        ;}
  );
  q0 q1 tests @nlerp testInterpolation
] call

# slerp
[
  q0: (1.0 2.0 neg 3.0 4.0    ) quaternion unit;
  q1: (5.0 6.0     7.0 8.0 neg) quaternion unit;
  tests: (
    {fraction: 0.0; q: q0 new                                                                                      ;}
    {fraction: 0.3; q: (0.000501537327541 neg 0.48176120346404 neg 0.23987752707694     0.8428313373983) quaternion;}
    {fraction: 0.6; q: (0.183499748964156 neg 0.52391886713953 neg 0.10504006435854 neg 0.8251081430121) quaternion;}
    {fraction: 1.0; q: q1 new                                                                                      ;}
  );
  q0 q1 tests @slerp testInterpolation
] call
