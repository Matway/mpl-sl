# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Quaternion.Quaternion" use
"Quaternion.quaternion" use
"algebra.Vector"        use
"algorithm.="           use
"control.&&"            use
"control.Real32"        use
"control.compilable?"   use
"control.ensure"        use
"control.print"         use
"control.when"          use

"Pose.*"                use
"Pose.Pose"             use
"Pose.identityPose"     use
"Pose.interpolate"      use
"Pose.inverse"          use
"Pose.mirrorVertically" use
"Pose.pose"             use
"Pose.poseCast"         use

PoseTest: [];

[
  [Pose.SCHEMA_NAME "Pose" =                        ] "[Pose] produced a wrong [.SCHEMA_NAME]"        ensure
  [Pose Pose "SCHEMA_NAME" fieldIndex fieldIsVirtual] "[Pose] produced a non-virtual [.SCHEMA_NAME]"  ensure
  [Pose.position    Real32 3 Vector   same          ] "[Pose] produced a wrong [.position] schema"    ensure
  [Pose.orientation Real32 Quaternion same          ] "[Pose] produced a wrong [.orientation] schema" ensure
] call

[
  [(1.0r32 2.0r32 3.0r32) (0.0    0.0    0.0    1.0   ) quaternion pose .position            (1.0r32 2.0r32 3.0r32       ) =] "[pose] produced a wrong [.position]"    ensure
  [(2.0    3.0    4.0   ) (0.0    0.0    0.0    1.0   ) quaternion pose .position            (2.0    3.0    4.0          ) =] "[pose] produced a wrong [.position]"    ensure
  [(0.0    0.0    0.0   ) (1.0r32 0.0r32 0.0r32 0.0r32) quaternion pose .orientation.entries (1.0r32 0.0r32 0.0r32 0.0r32) =] "[pose] produced a wrong [.orientation]" ensure
  [(0.0    0.0    0.0   ) (0.0r32 1.0r32 0.0r32 0.0r32) quaternion pose .orientation.entries (0.0r32 1.0r32 0.0r32 0.0r32) =] "[pose] produced a wrong [.orientation]" ensure
  [(0.0    0.0    0.0   ) (0.0    0.0    1.0    0.0   ) quaternion pose .orientation.entries (0.0    0.0    1.0    0.0   ) =] "[pose] produced a wrong [.orientation]" ensure
  [(0.0    0.0    0.0   ) (0.0    0.0    0.0    1.0   ) quaternion pose .orientation.entries (0.0    0.0    0.0    1.0   ) =] "[pose] produced a wrong [.orientation]" ensure
] call

[
  pose:
    (1.0r32 2.0r32 3.0r32) (1.0  0.0  0.0  0.0 ) quaternion pose
    (2      3      4     ) (0n32 1n32 0n32 0n32) quaternion pose *;
  [pose.position            (1.0r32 5.0r32  1.0r32    ) =] "[*] produced a wrong [.position]"    ensure
  [pose.orientation.entries (0.0    0.0    -1.0    0.0) =] "[*] produced a wrong [.orientation]" ensure
] call

[
  [(1.0r32 2.0r32 3.0r32) (2.0 3.0 4.0) (1 0 0 0) quaternion pose * (3.0r32 1.0r32 1.0r32) =] "[*] produced a wrong vector" ensure
] call

[
  [identityPose .position            (0.0r32 0.0r32 0.0r32       ) =] "[identityPose] produced a wrong [.position]"    ensure
  [identityPose .orientation.entries (0.0r32 0.0r32 0.0r32 1.0r32) =] "[identityPose] produced a wrong [.orientation]" ensure
] call

[
  pose0:
    (1.0r32 2.0r32 3.0r32) (1.0  0.0  0.0  0.0 ) quaternion pose
    (2      3      4     ) (0n32 1n32 0n32 0n32) quaternion pose 0.25r32 interpolate;
  pose1:
    (1.0r32 2.0r32 3.0r32) (1.0  0.0  0.0  0.0 ) quaternion pose
    (2      3      4     ) (0n32 1n32 0n32 0n32) quaternion pose 1.0 interpolate;
  [pose0.position            (1.25r32            2.25r32            3.25r32    ) =] "[interpolate] produced a wrong [.position]"    ensure
  [pose0.orientation.entries (0.9486832980505137 0.3162277660168379 0.0     0.0) =] "[interpolate] produced a wrong [.orientation]" ensure
  [pose1.position            (2.0r32             3.0r32             4.0r32     ) =] "[interpolate] produced a wrong [.position]"    ensure
  [pose1.orientation.entries (0.0                1.0                0.0     0.0) =] "[interpolate] produced a wrong [.orientation]" ensure
] call

[
  pose: (1.0r32 2.0r32 3.0r32) (0.5 0.5 0.5 0.5) quaternion pose inverse;
  [pose.position            (-2.0r32 -3.0r32 -1.0r32     ) =] "[inverse] produced a wrong [.position]"    ensure
  [pose.orientation.entries ( 0.5     0.5     0.5    -0.5) =] "[inverse] produced a wrong [.orientation]" ensure
] call

[
  pose: (1.0r32 2.0r32 3.0r32) (0.5 0.5 0.5 0.5) quaternion pose 4 mirrorVertically;
  [pose.position            ( 1.0r32  2.0r32  5.0r32    ) =] "[mirrorVertically] produced a wrong [.position]"    ensure
  [pose.orientation.entries (-0.5     -0.5     0.5   0.5) =] "[mirrorVertically] produced a wrong [.orientation]" ensure
] call

[
  pose: (1 2 3) (0.5 0.5 0.5 0.5) quaternion pose Real32 poseCast;
  [pose.position            (1.0r32 2.0r32 3.0r32       ) =] "[poseCast] produced a wrong [.position]"    ensure
  [pose.orientation.entries (0.5r32 0.5r32 0.5r32 0.5r32) =] "[poseCast] produced a wrong [.orientation]" ensure
] call

[
  [(1.0r32 2.0r32 3.0r32) (0.5 0.5 0.5 0.5) quaternion pose .getMatrix ((0.0 1.0 0.0) (0.0 0.0 1.0) (1.0 0.0 0.0)) =] "[Pose.getMatrix] produced a wrong matrix" ensure
] call

[
  pose: (1.0r32 2.0r32 3.0r32) (0.5 0.5 0.5 0.5) quaternion pose;
  4 @pose.scale
  [pose.position            (4.0r32 8.0r32 12.0r32    ) =] "[Pose.scale] produced a wrong [.position]"    ensure
  [pose.orientation.entries (0.5    0.5     0.5    0.5) =] "[Pose.scale] produced a wrong [.orientation]" ensure
] call

[
  pose: (1.0r32 2.0r32 3.0r32) (0.5 0.5 0.5 0.5) quaternion pose;
  (2 3 4) @pose.translate
  [pose.position            (3.0r32 5.0r32 7.0r32    ) =] "[Pose.translate] produced a wrong [.position]"    ensure
  [pose.orientation.entries (0.5    0.5    0.5    0.5) =] "[Pose.translate] produced a wrong [.orientation]" ensure
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["PoseTest passed\n" print] when
