# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Nat32"       use
"control.Ref"         use
"conventions.stdcall" use

JOYINFOEX: [{
  dwSize:         Nat32;
  dwFlags:        Nat32;
  dwXpos:         Nat32;
  dwYpos:         Nat32;
  dwZpos:         Nat32;
  dwRpos:         Nat32;
  dwUpos:         Nat32;
  dwVpos:         Nat32;
  dwButtons:      Nat32;
  dwButtonNumber: Nat32;
  dwPOV:          Nat32;
  dwReserved1:    Nat32;
  dwReserved2:    Nat32;
}];

{
  uJoyID: Nat32;
  pji:    JOYINFOEX Ref;
} Nat32 {convention: stdcall;} "joyGetPosEx" importFunction
