"control.Natx" use
"user32Private" use

user32Internal: {
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
  GetWindowLongPtrW: Natx storageSize 8nx = [@GetWindowLongPtrW] [@GetWindowLongW] if;
  LoadCursorW: @LoadCursorW;
  PeekMessageW: @PeekMessageW;
  RegisterClassW: @RegisterClassW;
  ReleaseCapture: @ReleaseCapture;
  SetCapture: @SetCapture;
  SetCursorPos: @SetCursorPos;
  SetWindowLongPtrW: Natx storageSize 8nx = [@SetWindowLongPtrW] [@SetWindowLongW] if;
  ShowCursor: @ShowCursor;
  ShowWindow: @ShowWindow;
  TranslateMessage: @TranslateMessage;
};

user32: [user32Internal];
