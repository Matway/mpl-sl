"algebra.*" use
"algebra.+" use
"algebra.dot" use
"algebra.lerp" use
"algebra.neg" use
"control.pfunc" use
"control.when" use

Quaternion: [{
  QUATERNION: ();
  entries: 4 array;
}];

quaternion: [{
  QUATERNION: ();
  entries: copy;
}];

identityQuaternion: [
  entry:;
  (0 entry cast 0 entry cast 0 entry cast 1 entry cast) quaternion
];

fieldCount: ["QUATERNION" has] [.@entries fieldCount] pfunc;

@: ["QUATERNION" has] [.@entries @] pfunc;

!: ["QUATERNION" has] [.@entries !] pfunc;

+: [q0:q1:;; q0 "QUATERNION" has q1 "QUATERNION" has and] [
  q0:q1:;;
  q0.entries q1.entries + quaternion
] pfunc;

*: [value:q:;; q "QUATERNION" has value 0 q @ same and] [
  value:q:;;
  value q.entries * quaternion
] pfunc;

*: [q:value:;; q "QUATERNION" has value 0 q @ same and] [
  q:value:;;
  q.entries value * quaternion
] pfunc;

*: [q0:q1:;; q0 "QUATERNION" has q1 "QUATERNION" has and] [
  q0:q1:;;
  (
    0 q0 @ 3 q1 @ * 3 q0 @ 0 q1 @ * + 2 q0 @ 1 q1 @ * + 1 q0 @ 2 q1 @ * -
    1 q0 @ 3 q1 @ * 3 q0 @ 1 q1 @ * + 0 q0 @ 2 q1 @ * + 2 q0 @ 0 q1 @ * -
    2 q0 @ 3 q1 @ * 3 q0 @ 2 q1 @ * + 1 q0 @ 0 q1 @ * + 0 q0 @ 1 q1 @ * -
    3 q0 @ 3 q1 @ * 0 q0 @ 0 q1 @ * - 1 q0 @ 1 q1 @ * - 2 q0 @ 2 q1 @ * -
  ) quaternion
] pfunc;

squaredLength: ["QUATERNION" has] [
  q:;
  q q dot
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

unit: ["QUATERNION" has] [
  q:;
  length: q squaredLength sqrt;
  one: 1 0 q @ cast;
  q one length / *
] pfunc;

unitCheckedWithThresold: [
  thresold: copy;
  q:;
  squaredLength: q squaredLength;
  squaredLength thresold thresold * < [
    thresold identityQuaternion
  ] [
    one: 1 thresold cast;
    q one squaredLength sqrt / *
  ] if
];

unitChecked: [
  q:;
  q 1.0e-6 0 q @ cast unitCheckedWithThresold
];

nlerp: [
  q0: q1: f:; copy;;
  q0 q1 dot 0 0 q0 @ cast < [q1.entries neg @q1.!entries] when
  q0.entries q1.entries f lerp quaternion unitChecked
];

conj: ["QUATERNION" has] [
  q:;
  (
    0 q @ copy
    1 q @ copy
    2 q @ copy
    3 q @ neg
  ) quaternion
] pfunc;

slerpWithEpsilon: [
  q0:q1:o:epsilon:;;;;
  q2: q1 copy;
  c: q0 q2 dot;

  c 0 o cast < [
    (
      0 q2 @ neg
      1 q2 @ neg
      2 q2 @ neg
      3 q2 @ neg
    ) quaternion !q2
    c neg !c
  ] when

  c 1 o cast epsilon - > ~ [
    a: c cos;
    sr: 1 o cast a sin /;
    a2: a o *;
    k0: a a2 - sin sr *;
    k2: a2 sin sr *;
    q0 k0 * q2 k2 * + !q2
  ] when
  q2
];

slerp: [
  o:;
  o 1.0e-6 o cast slerpWithEpsilon
];

vector: ["QUATERNION" has] [
  .entries copy
] pfunc;

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
    (one yy2 - zz2 - xy2 zw2 +   xz2 yw2 -)
    (xy2 zw2 -       omxx2 zz2 - yz2 xw2 +)
    (xz2 yw2 +       yz2 xw2 -   omxx2 yy2 -)
  )
] pfunc;

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
