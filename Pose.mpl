"Quaternion.*" use
"Quaternion.Quaternion" use
"Quaternion.conj" use
"Quaternion.identityQuaternion" use
"Quaternion.matrix" use
"Quaternion.nlerp" use
"algebra.*" use
"algebra.+" use
"algebra.-" use
"algebra.Vector" use
"algebra.lerp" use
"algebra.neg" use
"algebra.trans" use
"algebra.vector?" use
"control.Real32" use
"control.pfunc" use
"control.when" use

pose: [
  position0: orientation0: ;;
  position0 Real32 3 Vector same ~ [0 .POSITION_TYPE_MISMATCH] when
  orientation0 Real32 Quaternion same ~ [0 .ORIENTATION_TYPE_MISMATCH] when
  {
    virtual POSE: ();
    position: position0 copy;
    orientation: orientation0 copy;

    getMatrix: [orientation matrix];
    translate: [position + !position];
  }
];

Pose: [
  Real32 3 Vector Real32 Quaternion pose
];

identityPose: [
  (0.0r32 0.0r32 0.0r32) Real32 identityQuaternion pose
];

*: [
  p0:p1:;;
  p0 "POSE" has
  p1 "POSE" has and
] [
  p0:p1:;;
  p0.position p1.getMatrix * p1.position +
  p0.orientation p1.orientation * pose
] pfunc;

*: [
  v:p:;;
  v vector?
  p "POSE" has and
] [
  v:p:;;
  v p.getMatrix * p.position +
] pfunc;

inverse: ["POSE" has] [
  p:;
  p.position neg p.getMatrix trans *
  p.orientation conj pose
] pfunc;

interpolate: [
  p0:p1:f:;;;
  p0 "POSE" has
  p1 "POSE" has and
] [
  p0:p1:f:;;;
  p0.position p1.position f lerp
  p0.orientation p1.orientation f nlerp pose
] pfunc;

mirrorVertically: [
  p:m:;;
  p "POSE" has
] [
  p:m:;;
  (
    0 p.position @ copy
    1 p.position @ copy
    m 2 p.position @ -
  )
  (
    0 p.orientation @ neg
    1 p.orientation @ neg
    2 p.orientation @ copy
    3 p.orientation @ copy
  ) quatertion pose
] pfunc;
