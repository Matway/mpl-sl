# Copyright (C) 2022 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32" use
"control.Natx" use
"control.Text" use
"conventions.stdcall" use
"user32.user32" use

{
  Arg1: user32.HDC;
} user32.HGLRC {convention: stdcall;} "wglCreateContext" importFunction

{
  Arg1: user32.HGLRC;
} Int32 {convention: stdcall;} "wglDeleteContext" importFunction

{
  procedureName: Text;
} Natx {convention: stdcall;} "wglGetProcAddress" importFunction

{
  arg1: user32.HDC;
  arg2: user32.HGLRC;
} Int32 {convention: stdcall;} "wglMakeCurrent" importFunction
