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
