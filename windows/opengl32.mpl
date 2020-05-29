"opengl32Private" use

opengl32Internal: {
  # OpenGL32.Lib should be included for these functions
  wglCreateContext: @wglCreateContext;
  wglDeleteContext: @wglDeleteContext;
  wglGetProcAddress: @wglGetProcAddress;
  wglMakeCurrent: @wglMakeCurrent;
};

opengl32: [opengl32Internal];
