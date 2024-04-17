# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32"       use
"control.Nat32"       use
"control.Natx"        use
"conventions.stdcall" use

"user32.HWND" use

CSIDL_APPDATA: [0x001A];

SHGFP_TYPE_CURRENT: [0]; # current value for user, verify it exists
SHGFP_TYPE_DEFAULT: [1]; # default value, may not exist

# shell32.lib should be included for these functions

{
  hwnd:    HWND;
  csidl:   Int32;
  hToken:  Natx;
  dwFlags: Nat32;
  pszPath: Natx;
} Int32 {convention: stdcall;} "SHGetFolderPathW" importFunction
