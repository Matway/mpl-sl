# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Natx" use

"user32Private" use

user32: {
  HBRUSH:   @HBRUSH;
  HCURSOR:  @HCURSOR;
  HDC:      @HDC;
  HGLRC:    @HGLRC;
  HICON:    @HICON;
  HMENU:    @HMENU;
  HMONITOR: @HMONITOR;
  HWND:     @HWND;

  MONITORINFO:     @MONITORINFO;
  MSG:             @MSG;
  POINT:           @POINT;
  RECT:            @RECT;
  WINDOWPLACEMENT: @WINDOWPLACEMENT;
  WNDCLASSW:       @WNDCLASSW;

  # User32.Lib should be included for these functions
  ClientToScreen:     @ClientToScreen                                                  virtual;
  CreateWindowExW:    @CreateWindowExW                                                 virtual;
  DefWindowProcW:     @DefWindowProcW                                                  virtual;
  DestroyWindow:      @DestroyWindow                                                   virtual;
  DispatchMessageW:   @DispatchMessageW                                                virtual;
  GetDC:              @GetDC                                                           virtual;
  GetMonitorInfoW:    @GetMonitorInfoW                                                 virtual;
  GetWindowLongPtrW:  Natx storageSize 8nx = [@GetWindowLongPtrW] [@GetWindowLongW] if virtual;
  GetWindowPlacement: @GetWindowPlacement                                              virtual;
  LoadCursorW:        @LoadCursorW                                                     virtual;
  MonitorFromWindow:  @MonitorFromWindow                                               virtual;
  PeekMessageW:       @PeekMessageW                                                    virtual;
  RegisterClassW:     @RegisterClassW                                                  virtual;
  ReleaseCapture:     @ReleaseCapture                                                  virtual;
  SetCapture:         @SetCapture                                                      virtual;
  SetCursorPos:       @SetCursorPos                                                    virtual;
  SetWindowLongPtrW:  Natx storageSize 8nx = [@SetWindowLongPtrW] [@SetWindowLongW] if virtual;
  SetWindowPlacement: @SetWindowPlacement                                              virtual;
  SetWindowPos:       @SetWindowPos                                                    virtual;
  ShowCursor:         @ShowCursor                                                      virtual;
  ShowWindow:         @ShowWindow                                                      virtual;
  TranslateMessage:   @TranslateMessage                                                virtual;
};
