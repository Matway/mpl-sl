"ws2_32Private" module
"kernel32" useModule

WSAOVERLAPPED_COMPLETION_ROUTINERef: [{
  dwError: Nat32;
  cbTransferred: Nat32;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  dwFlags: Nat32;
} {} {} codeRef] func;

WSABUF: [{
  len: Nat32;
  buf: Natx;
}] func;

WSADESCRIPTION_LEN: [256] func;
WSASYS_STATUS_LEN: [128] func;

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
}] func;

{
} Int32 {} "WSACleanup" importFunction

{
} Int32 {} "WSAGetLastError" importFunction

{
  s: Natx;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  lpcbTransfer: Nat32 Ref;
  fWait: Int32;
  lpdwFlags: Nat32 Ref;
} Int32 {} "WSAGetOverlappedResult" importFunction

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
} Int32 {} "WSAIoctl" importFunction

{
  s: Natx;
  lpBuffers: WSABUF Ref;
  dwBufferCount: Nat32;
  lpNumberOfBytesRecvd: Nat32 Ref;
  lpFlags: Nat32 Ref;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  lpCompletionRoutine: WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {} "WSARecv" importFunction

{
  s: Natx;
  lpBuffers: WSABUF Ref;
  dwBufferCount: Nat32;
  lpNumberOfBytesSent: Nat32 Ref;
  dwFlags: Nat32;
  lpOverlapped: kernel32.OVERLAPPED Ref;
  lpCompletionRoutine: WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {} "WSASend" importFunction

{
  iError: Int32;
} {} {} "WSASetLastError" importFunction

{
  wVersionRequested: Nat16;
  lpWSAData: WSADATA Ref;
} Int32 {} "WSAStartup" importFunction

{
  s: Natx;
  name: Natx;
  namelen: Int32;
} Int32 {} "bind" importFunction

{
  s: Natx;
} Int32 {} "closesocket" importFunction

{
  hostlong: Nat32;
} Nat32 {} "htonl" importFunction

{
  hostshort: Nat16;
} Nat16 {} "htons" importFunction

{
  s: Natx;
  backlog: Int32;
} Int32 {} "listen" importFunction

{
  s: Natx;
  level: Int32;
  optname: Int32;
  optval: Natx;
  optlen: Int32;
} Int32 {} "setsockopt" importFunction

{
  af: Int32;
  type: Int32;
  protocol: Int32;
} Natx {} "socket" importFunction
