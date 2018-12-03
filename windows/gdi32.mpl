"gdi32" module
"control" includeModule
"gdi32Private" useModule

gdi32: {
  PIXELFORMATDESCRIPTOR: @PIXELFORMATDESCRIPTOR;

  # Gdi32.Lib should be included for these functions
  ChoosePixelFormat: @ChoosePixelFormat;
  SetPixelFormat: @SetPixelFormat;
  SwapBuffers: @SwapBuffers;
};
