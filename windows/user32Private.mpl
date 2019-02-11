"user32Private" module
"kernel32" useModule

WNDPROC: [{
  hwnd: HWND;
  uMsg: Nat32;
  wParam: Natx;
  lParam: Intx;
} Intx {convention: stdcall;} codeRef] func;

HCURSOR: [HICON] func;

HBRUSH: [{
  virtual BRUSH: {};
  unused: Int32;
} Cref] func;

HDC: [{
  virtual DC: {};
  unused: Int32;
} Cref] func;

HGLRC: [{
  virtual GLRC: {};
  unused: Int32;
} Cref] func;

HICON: [{
  virtual ICON: {};
  unused: Int32;
} Cref] func;

HMENU: [{
  virtual MENU: {};
  unused: Int32;
} Cref] func;

HWND: [{
  virtual WND: {};
  unused: Int32;
} Cref] func;

MSG: [{
  hwnd: HWND;
  message: Nat32;
  wParam: Natx;
  lParam: Intx;
  time: Nat32;
  pt: POINT;
}] func;

POINT: [{
  x: Int32;
  y: Int32;
}] func;

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
}] func;

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
  hWnd: HWND;
  nIndex: Int32;
} Intx {convention: stdcall;} "GetWindowLongPtrW" importFunction

{
  hInstance: kernel32.HINSTANCE;
  lpCursorName: Natx;
} HCURSOR {convention: stdcall;} "LoadCursorW" importFunction

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

{
  hWnd: HWND;
  nIndex: Int32;
  dwNewLong: Intx;
} Intx {convention: stdcall;} "SetWindowLongPtrW" importFunction

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
