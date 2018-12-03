"user32" module
"control" includeModule
"user32Private" useModule

user32: {
  HBRUSH: @HBRUSH;
  HCURSOR: @HCURSOR;
  HDC: @HDC;
  HGLRC: @HGLRC;
  HICON: @HICON;
  HMENU: @HMENU;
  HWND: @HWND;

  MSG: @MSG;
  POINT: @POINT;
  WNDCLASSW: @WNDCLASSW;

  # User32.Lib should be included for these functions
  ClientToScreen: @ClientToScreen;
  CreateWindowExW: @CreateWindowExW;
  DefWindowProcW: @DefWindowProcW;
  DestroyWindow: @DestroyWindow;
  DispatchMessageW: @DispatchMessageW;
  GetDC: @GetDC;
  GetWindowLongPtrW: @GetWindowLongPtrW;
  LoadCursorW: @LoadCursorW;
  PeekMessageW: @PeekMessageW;
  RegisterClassW: @RegisterClassW;
  ReleaseCapture: @ReleaseCapture;
  SetCapture: @SetCapture;
  SetCursorPos: @SetCursorPos;
  SetWindowLongPtrW: @SetWindowLongPtrW;
  ShowCursor: @ShowCursor;
  ShowWindow: @ShowWindow;
};
