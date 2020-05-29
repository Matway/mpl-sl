"gdi32Private" use

gdi32Internal: {
  PIXELFORMATDESCRIPTOR: @PIXELFORMATDESCRIPTOR;

  # Gdi32.Lib should be included for these functions
  ChoosePixelFormat: @ChoosePixelFormat;
  SetPixelFormat: @SetPixelFormat;
  SwapBuffers: @SwapBuffers;
};

gdi32: [gdi32Internal];
