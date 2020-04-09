"user32" useModule

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
