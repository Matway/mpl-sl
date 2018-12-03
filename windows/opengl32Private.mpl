"opengl32Private" module
"user32" useModule

{
  Arg1: user32.HDC;
} user32.HGLRC {} "wglCreateContext" importFunction

{
  Arg1: user32.HGLRC;
} Int32 {} "wglDeleteContext" importFunction

{
  arg1: user32.HDC;
  arg2: user32.HGLRC;
} Int32 {} "wglMakeCurrent" importFunction
