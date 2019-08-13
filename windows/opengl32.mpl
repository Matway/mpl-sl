"opengl32" module
"control" includeModule
"opengl32Private" useModule

opengl32: {
  # OpenGL32.Lib should be included for these functions
  wglCreateContext: @wglCreateContext;
  wglDeleteContext: @wglDeleteContext;
  wglGetProcAddress: @wglGetProcAddress;
  wglMakeCurrent: @wglMakeCurrent;
};
