# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32" use
"control.Nat32" use
"control.Natx" use
"conventions.stdcall" use
"user32.user32" use

{
  hwnd: user32.HWND;
  csidl: Int32;
  hToken: Natx;
  dwFlags: Nat32;
  pszPath: Natx;
} Int32 {convention: stdcall;} "SHGetFolderPathW" importFunction
