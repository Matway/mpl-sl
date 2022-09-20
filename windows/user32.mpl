# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Natx" use
"user32Private" use

user32Internal: {
  HBRUSH: @HBRUSH;
  HCURSOR: @HCURSOR;
  HDC: @HDC;
  HGLRC: @HGLRC;
  HICON: @HICON;
  HMENU: @HMENU;
  HMONITOR: @HMONITOR;
  HWND: @HWND;

  MONITORINFO: @MONITORINFO;
  MSG: @MSG;
  POINT: @POINT;
  RECT: @RECT;
  WINDOWPLACEMENT: @WINDOWPLACEMENT;
  WNDCLASSW: @WNDCLASSW;

  # User32.Lib should be included for these functions
  ClientToScreen: @ClientToScreen;
  CreateWindowExW: @CreateWindowExW;
  DefWindowProcW: @DefWindowProcW;
  DestroyWindow: @DestroyWindow;
  DispatchMessageW: @DispatchMessageW;
  GetDC: @GetDC;
  GetMonitorInfoW: @GetMonitorInfoW;
  GetWindowLongPtrW: Natx storageSize 8nx = [@GetWindowLongPtrW] [@GetWindowLongW] if;
  GetWindowPlacement: @GetWindowPlacement;
  LoadCursorW: @LoadCursorW;
  MonitorFromWindow: @MonitorFromWindow;
  PeekMessageW: @PeekMessageW;
  RegisterClassW: @RegisterClassW;
  ReleaseCapture: @ReleaseCapture;
  SetCapture: @SetCapture;
  SetCursorPos: @SetCursorPos;
  SetWindowLongPtrW: Natx storageSize 8nx = [@SetWindowLongPtrW] [@SetWindowLongW] if;
  SetWindowPlacement: @SetWindowPlacement;
  SetWindowPos: @SetWindowPos;
  ShowCursor: @ShowCursor;
  ShowWindow: @ShowWindow;
  TranslateMessage: @TranslateMessage;
};

user32: [user32Internal];
