# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algebra.&"             use
"algebra.*"             use
"algebra.+"             use
"algebra.acos"          use
"algebra.dot"           use
"algebra.getColCount"   use
"algebra.getRowCount"   use
"algebra.length"        use
"algebra.lerp"          use
"algebra.matrix?"       use
"algebra.neg"           use
"algebra.squaredLength" use
"algebra.trans"         use
"algebra.unit"          use
"algorithm.each"        use
"control.Ref"           use
"control.isReal"        use
"control.pfunc"         use
"control.sqr"           use
"control.times"         use
"control.when"          use

Quaternion: [{
  QUATERNION: ();
  entries: 4 array;
}];

axisAngleQuaternion: [
  axisAngle:;
  third: 3 axisAngle @;
  ah: third 0.5 third cast *;
  ahs: ah sin;
  (
    0 axisAngle @ ahs *
    1 axisAngle @ ahs *
    2 axisAngle @ ahs *
    ah cos
  ) quaternion
];

identityQuaternion: [
  entry:;
  (0 entry cast 0 entry cast 0 entry cast 1 entry cast) quaternion
];

matrix: ["QUATERNION" has] [
  q:;
  one: 1 0 q @ cast;
  x2: 0 q @ 0 q @ +;
  y2: 1 q @ 1 q @ +;
  z2: 2 q @ 2 q @ +;
  omxx2: one x2 0 q @ * -;
  xy2: x2 1 q @ *;
  xz2: x2 2 q @ *;
  xw2: x2 3 q @ *;
  yy2: y2 1 q @ *;
  yz2: y2 2 q @ *;
  yw2: y2 3 q @ *;
  zz2: z2 2 q @ *;
  zw2: z2 3 q @ *;
  (
    (one yy2 - zz2 - xy2 zw2 +   xz2 yw2 -  )
    (xy2 zw2 -       omxx2 zz2 - yz2 xw2 +  )
    (xz2 yw2 +       yz2 xw2 -   omxx2 yy2 -)
  )
] pfunc;

quaternion: [{
  QUATERNION: ();
  entries: new;
}];

quaternion: [
  m:;
  m matrix?
  m getColCount 3 = and
  m getRowCount 3 = and
] [
  m: trans;
  trace: 3 [i i m @ @] times + +;
  trace 0 trace cast > [
    w: trace 1 trace cast + sqrt 0.5 trace cast *;
    fr: 0.25 w cast w /;
    (
      1 2 m @ @ 2 1 m @ @ - fr *
      2 0 m @ @ 0 2 m @ @ - fr *
      0 1 m @ @ 1 0 m @ @ - fr *
      w new
    ) quaternion
  ] [
    next: (1 2 0);
    i: 1 1 m @ @ 0 0 m @ @ > [1] [0] if;
    2 2 m @ @ i i m @ @ > [
      2 !i
    ] when

    j: i next @;
    k: j next @;

    q: trace Quaternion;
    qi: i i m @ @ j j m @ @ - k k m @ @ - 1 trace cast + sqrt 0.5 trace cast *;
    fr: 0.25 qi cast qi /;

    qi                         i @q @ set
    i j m @ @ j i m @ @ + fr * j @q @ set
    i k m @ @ k i m @ @ + fr * k @q @ set
    j k m @ @ k j m @ @ - fr * 3 @q @ set
    q
  ] if
] pfunc;

quaternionCast: [
  q: virtual Schema: Ref;;
  q.entries [@Schema cast] (each) quaternion
];

rotationQuaternion: [
  rotation:;
  rotation 1.0e-12 rotationQuaternion
];

rotationQuaternion: [rotation: threshold:;; threshold isReal] [
  rotation: threshold:;;
  threshold: threshold 0 rotation @ cast;
  rotation squaredLength threshold sqr < [
    0 rotation @ identityQuaternion
  ] [
    angle: rotation length;
    rotation unit (angle) & axisAngleQuaternion
  ] if
] pfunc;

vector: ["QUATERNION" has] [
  .entries new
] pfunc;

!: ["QUATERNION" has] [
  value: index: q:;;;
  value new index @q.@entries !
] pfunc;

@: ["QUATERNION" has] [.@entries @] pfunc;

fieldCount: ["QUATERNION" has] [.entries fieldCount] pfunc;

# Basic operations
*: [value: q:;; q "QUATERNION" has value 0 q @ same and] [
  value: q:;;
  value q.entries * quaternion
] pfunc;

*: [q: value:;; q "QUATERNION" has value 0 q @ same and] [
  q: value:;;
  q.entries value * quaternion
] pfunc;

*: [q0: q1:;; q0 "QUATERNION" has q1 "QUATERNION" has and] [
  q0: q1:;;
  (
    0 q0 @ 3 q1 @ * 3 q0 @ 0 q1 @ * + 2 q0 @ 1 q1 @ * + 1 q0 @ 2 q1 @ * -
    1 q0 @ 3 q1 @ * 3 q0 @ 1 q1 @ * + 0 q0 @ 2 q1 @ * + 2 q0 @ 0 q1 @ * -
    2 q0 @ 3 q1 @ * 3 q0 @ 2 q1 @ * + 1 q0 @ 0 q1 @ * + 0 q0 @ 1 q1 @ * -
    3 q0 @ 3 q1 @ * 0 q0 @ 0 q1 @ * - 1 q0 @ 1 q1 @ * - 2 q0 @ 2 q1 @ * -
  ) quaternion
] pfunc;

+: [q0: q1:;; q0 "QUATERNION" has q1 "QUATERNION" has and] [
  q0: q1:;;
  q0.entries q1.entries + quaternion
] pfunc;

conj: ["QUATERNION" has] [
  q:;
  (
    0 q @ new
    1 q @ new
    2 q @ new
    3 q @ neg
  ) quaternion
] pfunc;

dot: [
  q0: q1:;;
  q0 "QUATERNION" has
  q1 "QUATERNION" has and
] [
  q0: q1:;;
  0 q0 @ 0 q1 @ *
  1 q0 @ 1 q1 @ * +
  2 q0 @ 2 q1 @ * +
  3 q0 @ 3 q1 @ * +
] pfunc;

squaredLength: ["QUATERNION" has] [
  q:;
  q q dot
] pfunc;

unit: ["QUATERNION" has] [
  q:;
  length: q squaredLength sqrt;
  one: 1 0 q @ cast;
  q one length / *
] pfunc;

unitChecked: [
  q:;
  q 1.0e-6 0 q @ cast unitCheckedWithThreshold
];

unitCheckedWithThreshold: [
  threshold: new;
  q:;
  squaredLength: q squaredLength;
  squaredLength threshold threshold * < [
    threshold identityQuaternion
  ] [
    one: 1 threshold cast;
    q one squaredLength sqrt / *
  ] if
];

# Interpolation
nlerp: [
  q0: q1: fraction:; new;;
  q0 q1 dot 0 0 q0 @ cast < [q1.entries neg @q1.!entries] when
  q0.entries q1.entries fraction lerp quaternion unitChecked
];

slerp: [
  fraction:;
  fraction 1.0e-6 fraction cast slerpWithEpsilon
];

slerpWithEpsilon: [
  q0: q1: fraction: epsilon:;;;;
  q2: q1 new;
  c: q0 q2 dot;

  c 0 fraction cast < [
    q2.entries neg @q2.!entries
    c neg !c
  ] when

  c 1 fraction cast epsilon - > ~ [
    angle: c acos;
    sr: 1 fraction cast angle sin /;
    angle2: angle fraction *;
    k0: angle angle2 - sin sr *;
    k2: angle2 sin sr *;
    q0 k0 * q2 k2 * + !q2
  ] when
  q2
];
