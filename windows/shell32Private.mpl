"control" useModule
"user32" useModule

{
  hwnd: user32.HWND;
  csidl: Int32;
  hToken: Natx;
  dwFlags: Nat32;
  pszPath: Natx;
} Int32 {convention: stdcall;} "SHGetFolderPathW" importFunction
