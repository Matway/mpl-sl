# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Cref" use
"control.Int32" use
"control.Intx" use
"control.Nat16" use
"control.Nat32" use
"control.Natx" use
"control.Ref" use
"conventions.stdcall" use
"kernel32.kernel32" use

WNDPROC: [{
  hwnd: HWND;
  uMsg: Nat32;
  wParam: Natx;
  lParam: Intx;
} Intx {convention: stdcall;} codeRef];

HCURSOR: [HICON];

HBRUSH: [{
  virtual BRUSH: {};
  unused: Int32;
} Cref];

HDC: [{
  virtual DC: {};
  unused: Int32;
} Cref];

HGLRC: [{
  virtual GLRC: {};
  unused: Int32;
} Cref];

HICON: [{
  virtual ICON: {};
  unused: Int32;
} Cref];

HMENU: [{
  virtual MENU: {};
  unused: Int32;
} Cref];

HMONITOR: [{
  virtual MONITOR: {};
  unused: Int32;
} Cref];

HWND: [{
  virtual WND: {};
  unused: Int32;
} Cref];

MONITORINFO: [{
  cbSize: Nat32;
  rcMonitor: RECT;
  rcWork: RECT;
  dwFlags: Nat32;
}];

MSG: [{
  hwnd: HWND;
  message: Nat32;
  wParam: Natx;
  lParam: Intx;
  time: Nat32;
  pt: POINT;
}];

POINT: [{
  x: Int32;
  y: Int32;
}];

RECT: [{
  left: Int32;
  top: Int32;
  right: Int32;
  bottom: Int32;
}];

WINDOWPLACEMENT: [{
  length: Nat32;
  flags: Nat32;
  showCmd: Nat32;
  ptMinPosition: POINT;
  ptMaxPosition: POINT;
  rcNormalPosition: RECT;
  rcDevice: RECT;
}];

WNDCLASSW: [{
  style: Nat32;
  lpfnWndProc: WNDPROC;
  cbClsExtra: Int32;
  cbWndExtra: Int32;
  hInstance: kernel32.HINSTANCE;
  hIcon: HICON;
  hCursor: HCURSOR;
  hbrBackground: HBRUSH;
  lpszMenuName: Natx;
  lpszClassName: Natx;
}];

{
  hWnd: HWND;
  lpPoint: POINT Ref;
} Int32 {convention: stdcall;} "ClientToScreen" importFunction

{
  dwExStyle: Nat32;
  lpClassName: Natx;
  lpWindowName: Natx;
  dwStyle: Nat32;
  X: Int32;
  Y: Int32;
  nWidth: Int32;
  nHeight: Int32;
  hWndParent: HWND;
  hMenu: HMENU;
  hInstance: kernel32.HINSTANCE;
  lpParam: Natx;
} HWND {convention: stdcall;} "CreateWindowExW" importFunction

{
  hWnd: HWND;
  Msg: Nat32;
  wParam: Natx;
  lParam: Intx;
} Intx {convention: stdcall;} "DefWindowProcW" importFunction

{
  hWnd: HWND;
} Int32 {convention: stdcall;} "DestroyWindow" importFunction

{
  lpMsg: MSG Cref;
} Intx {convention: stdcall;} "DispatchMessageW" importFunction

{
  hWnd: HWND;
} HDC {convention: stdcall;} "GetDC" importFunction

{
  hMonitor: HMONITOR;
  lpmi: MONITORINFO Ref;
} Int32 {convention: stdcall;} "GetMonitorInfoW" importFunction

Natx storageSize 8nx = [
  {
    hWnd: HWND;
    nIndex: Int32;
  } Intx {convention: stdcall;} "GetWindowLongPtrW" importFunction
] [
  {
    hWnd: HWND;
    nIndex: Int32;
  } Intx {convention: stdcall;} "GetWindowLongW" importFunction
] uif

{
  hWnd: HWND;
  lpwndpl: WINDOWPLACEMENT Ref;
} Int32 {convention: stdcall;} "GetWindowPlacement" importFunction

{
  hInstance: kernel32.HINSTANCE;
  lpCursorName: Natx;
} HCURSOR {convention: stdcall;} "LoadCursorW" importFunction

{
  hwnd: HWND;
  dwFlags: Nat32;
} HMONITOR {convention: stdcall;} "MonitorFromWindow" importFunction

{
  lpMsg: MSG Ref;
  hWnd: HWND;
  wMsgFilterMin: Nat32;
  wMsgFilterMax: Nat32;
  wRemoveMsg: Nat32;
} Int32 {convention: stdcall;} "PeekMessageW" importFunction

{
  lpWndClass: WNDCLASSW Cref;
} Nat16 {convention: stdcall;} "RegisterClassW" importFunction

{
} Int32 {convention: stdcall;} "ReleaseCapture" importFunction

{
  hWnd: HWND;
} HWND {convention: stdcall;} "SetCapture" importFunction

{
  X: Int32;
  Y: Int32;
} Int32 {convention: stdcall;} "SetCursorPos" importFunction

Natx storageSize 8nx = [
  {
    hWnd: HWND;
    nIndex: Int32;
    dwNewLong: Intx;
  } Intx {convention: stdcall;} "SetWindowLongPtrW" importFunction
] [
  {
    hWnd: HWND;
    nIndex: Int32;
    dwNewLong: Intx;
  } Intx {convention: stdcall;} "SetWindowLongW" importFunction
] uif

{
  hWnd: HWND;
  lpwndpl: WINDOWPLACEMENT Cref;
} Int32 {convention: stdcall;} "SetWindowPlacement" importFunction

{
  hWnd: HWND;
  hWndInsertAfter: HWND;
  X: Int32;
  Y: Int32;
  cx: Int32;
  cy: Int32;
  uFlags: Nat32;
} Int32 {convention: stdcall;} "SetWindowPos" importFunction

{
  bShow: Int32;
} Int32 {convention: stdcall;} "ShowCursor" importFunction

{
  hWnd: HWND;
  nCmdShow: Int32;
} Int32 {convention: stdcall;} "ShowWindow" importFunction

{
  lpMsg: MSG Cref;
} Int32 {convention: stdcall;} "TranslateMessage" importFunction
