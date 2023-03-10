# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Quaternion.*"                  use
"Quaternion.@"                  use
"Quaternion.Quaternion"         use
"Quaternion.conj"               use
"Quaternion.identityQuaternion" use
"Quaternion.matrix"             use
"Quaternion.nlerp"              use
"Quaternion.quaternion"         use
"Quaternion.quaternionCast"     use
"algebra.*"                     use
"algebra.+"                     use
"algebra.Vector"                use
"algebra.cast"                  use
"algebra.lerp"                  use
"algebra.neg"                   use
"algebra.trans"                 use
"algebra.vector?"               use
"control.&&"                    use
"control.Real32"                use
"control.Ref"                   use
"control.dup"                   use
"control.hasSchemaName"         use
"control.pfunc"                 use

Pose: [
  Real32 3 Vector Real32 Quaternion pose
];

*: [
  pose0: pose1:;;
  pose0 "Pose" hasSchemaName [pose1 "Pose" hasSchemaName] &&
] [
  pose0: pose1:;;
  pose0.position    pose1.orientation 0 pose0.position    @ quaternionCast matrix * pose1.position pose0.position cast +
  pose0.orientation pose1.orientation 0 pose0.orientation @ quaternionCast * pose
] pfunc;

*: [
  vector: pose:;;
  vector vector? [pose "Pose" hasSchemaName] &&
] [
  vector: pose:;;
  vector pose.orientation 0 vector @ quaternionCast matrix * pose.position vector cast +
] pfunc;

identityPose: [
  (0.0r32 0.0r32 0.0r32) Real32 identityQuaternion pose
];

interpolate: [
  pose0: pose1: blend:;;;
  pose0 "Pose" hasSchemaName [pose1 "Pose" hasSchemaName] &&
] [
  pose0: pose1: blend:;;;
  pose0.position    pose1.position    pose0.position cast                  blend 0 pose0.position    @ cast lerp
  pose0.orientation pose1.orientation 0 pose0.orientation @ quaternionCast blend 0 pose0.orientation @ cast nlerp pose
] pfunc;

inverse: ["Pose" hasSchemaName] [
  pose0:;
  pose0.position neg pose0.orientation 0 pose0.position @ quaternionCast matrix trans *
  pose0.orientation conj pose
] pfunc;

mirrorVertically: [
  pose: z:;;
  pose "Pose" hasSchemaName
] [
  pose0: z:;;
  (
    0 pose0.position @ new
    1 pose0.position @ new
    z 0 pose0.position @ cast dup 2 pose0.position @ - +
  )
  (
    0 pose0.orientation @ neg
    1 pose0.orientation @ neg
    2 pose0.orientation @ new
    3 pose0.orientation @ new
  ) quaternion pose
] pfunc;

pose: [
  position0: orientation0:;;

  {
    position:    position0    new;
    orientation: orientation0 new;

    getMatrix: [orientation matrix];
    scale:     [0 position @ cast position * !position];
    translate: [  position   cast position + !position];

    SCHEMA_NAME: "Pose" virtual;
  }
];

poseCast: [
  pose0: Schema: Ref virtual;;
  pose0.position @Schema newVarOfTheSameType 3 Vector cast pose0.orientation @Schema quaternionCast pose
];
