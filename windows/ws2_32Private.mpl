"control.Cref" use
"control.Int32" use
"control.Nat16" use
"control.Nat32" use
"control.Nat8" use
"control.Natx" use
"control.Ref" use
"conventions.stdcall" use
"kernel32.kernel32" use

WSAOVERLAPPED_COMPLETION_ROUTINERef: [{
  dwError: Nat32;
  cbTransferred: Nat32;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  dwFlags: Nat32;
} {} {convention: stdcall;} codeRef];

WSABUF: [{
  len: Nat32;
  buf: Natx;
}];

WSADESCRIPTION_LEN: [256];
WSASYS_STATUS_LEN: [128];

WSADATA: [{
  wVersion: Nat16;
  wHighVersion: Nat16;
  Natx storageSize 8nx = [
    iMaxSockets: Nat16;
    iMaxUdpDg: Nat16;
    lpVendorInfo: Nat8 Ref;
    szDescription: Nat8 WSADESCRIPTION_LEN 1 + array;
    szSystemStatus: Nat8 WSASYS_STATUS_LEN 1 + array;
  ] [
    szDescription: Nat8 WSADESCRIPTION_LEN 1 + array;
    szSystemStatus: Nat8 WSASYS_STATUS_LEN 1 + array;
    iMaxSockets: Nat16;
    iMaxUdpDg: Nat16;
    lpVendorInfo: Nat8 Ref;
  ] uif
}];

addrinfo: [{
  ai_flags: Int32;
  ai_family: Int32;
  ai_socktype: Int32;
  ai_protocol: Int32;
  ai_addrlen: Natx;
  ai_canonname: Natx;
  ai_addr: Natx;
  ai_next: Natx;
}];

fd_set: [{
  fd_count: Nat32;
  fd_array: Natx 64 array;
}];

sockaddr: [{
  sa_family: Nat16;
  sa_data: Nat8 14 array;
}];

timeval: [{
  tv_sec: Int32;
  tv_usec: Int32;
}];

{
} Int32 {convention: stdcall;} "WSACleanup" importFunction

{
} Int32 {convention: stdcall;} "WSAGetLastError" importFunction

{
  s: Natx;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  lpcbTransfer: Nat32 Ref;
  fWait: Int32;
  lpdwFlags: Nat32 Ref;
} Int32 {convention: stdcall;} "WSAGetOverlappedResult" importFunction

{
  s: Natx;
  dwIoControlCode: Nat32;
  lpvInBuffer: Natx;
  cbInBuffer: Nat32;
  lpvOutBuffer: Natx;
  cbOutBuffer: Nat32;
  lpcbBytesReturned: Nat32 Ref;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  lpCompletionRoutine: WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {convention: stdcall;} "WSAIoctl" importFunction

{
  s: Natx;
  lpBuffers: WSABUF Ref;
  dwBufferCount: Nat32;
  lpNumberOfBytesRecvd: Nat32 Ref;
  lpFlags: Nat32 Ref;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  lpCompletionRoutine: WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {convention: stdcall;} "WSARecv" importFunction

{
  s: Natx;
  lpBuffers: WSABUF Ref;
  dwBufferCount: Nat32;
  lpNumberOfBytesSent: Nat32 Ref;
  dwFlags: Nat32;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  lpCompletionRoutine: WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {convention: stdcall;} "WSASend" importFunction

{
  iError: Int32;
} {} {convention: stdcall;} "WSASetLastError" importFunction

{
  wVersionRequested: Nat16;
  lpWSAData: WSADATA Ref;
} Int32 {convention: stdcall;} "WSAStartup" importFunction

{
  s: Natx;
  name: Natx;
  namelen: Int32;
} Int32 {convention: stdcall;} "bind" importFunction

{
  s: Natx;
} Int32 {convention: stdcall;} "closesocket" importFunction

{
  s: Natx;
  name: sockaddr Ref;
  nameLen: Int32;
} Int32 {convention: stdcall;} "connect" importFunction

{
  pNodeName: Natx;
  pServiceName: Natx;
  pHints: addrinfo Cref;
  ppResult: Natx;
} Int32 {convention: stdcall;} "getaddrinfo" importFunction

{
  pAddrInfo: addrinfo Ref;
} {} {convention: stdcall;} "freeaddrinfo" importFunction

{
  hostlong: Nat32;
} Nat32 {convention: stdcall;} "htonl" importFunction

{
  hostshort: Nat16;
} Nat16 {convention: stdcall;} "htons" importFunction

{
  s: Natx;
  cmd: Int32;
  argp: Natx;
} Int32 {convention: stdcall;} "ioctlsocket" importFunction

{
  s: Natx;
  backlog: Int32;
} Int32 {convention: stdcall;} "listen" importFunction

{
  netlong: Nat32;
} Nat32 {convention: stdcall;} "ntohl" importFunction

{
  netshort: Nat16;
} Nat16 {convention: stdcall;} "ntohs" importFunction

{
  s: Natx;
  buf: Natx;
  len: Int32;
  flags: Int32;
} Int32 {convention: stdcall;} "recv" importFunction

{
  s: Natx;
  buf: Natx;
  len: Int32;
  flags: Int32;
} Int32 {convention: stdcall;} "send" importFunction

{
  ndfs: Int32;
  readfds: fd_set Ref;
  writefds: fd_set Ref;
  exceptfds: fd_set Ref;
  timeout: timeval Ref;
} Int32 {convention: stdcall;} "select" importFunction

{
  s: Natx;
  level: Int32;
  optname: Int32;
  optval: Natx;
  optlen: Int32;
} Int32 {convention: stdcall;} "setsockopt" importFunction

{
  s: Natx;
  how: Int32;
} Int32 {convention: stdcall;} "shutdown" importFunction

{
  af: Int32;
  type: Int32;
  protocol: Int32;
} Natx {convention: stdcall;} "socket" importFunction
