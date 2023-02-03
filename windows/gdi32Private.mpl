# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Cref"        use
"control.Int32"       use
"control.Nat16"       use
"control.Nat32"       use
"control.Nat8"        use
"conventions.stdcall" use

"user32.user32" use

PIXELFORMATDESCRIPTOR: [{
  nSize: Nat16;
  nVersion: Nat16;
  dwFlags: Nat32;
  iPixelType: Nat8;
  cColorBits: Nat8;
  cRedBits: Nat8;
  cRedShift: Nat8;
  cGreenBits: Nat8;
  cGreenShift: Nat8;
  cBlueBits: Nat8;
  cBlueShift: Nat8;
  cAlphaBits: Nat8;
  cAlphaShift: Nat8;
  cAccumBits: Nat8;
  cAccumRedBits: Nat8;
  cAccumGreenBits: Nat8;
  cAccumBlueBits: Nat8;
  cAccumAlphaBits: Nat8;
  cDepthBits: Nat8;
  cStencilBits: Nat8;
  cAuxBuffers: Nat8;
  iLayerType: Nat8;
  bReserved: Nat8;
  dwLayerMask: Nat32;
  dwVisibleMask: Nat32;
  dwDamageMask: Nat32;
}];

{
  hdc: user32.HDC;
  ppfd: PIXELFORMATDESCRIPTOR Cref;
} Int32 {convention: stdcall;} "ChoosePixelFormat" importFunction

{
  hdc: user32.HDC;
  format: Int32;
  ppfd: PIXELFORMATDESCRIPTOR Cref;
} Int32 {convention: stdcall;} "SetPixelFormat" importFunction

{
  Arg1: user32.HDC;
} Int32 {convention: stdcall;} "SwapBuffers" importFunction
