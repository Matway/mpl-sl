# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Mref"           use
"control.AsRef"       use
"control.Cref"        use
"control.Int32"       use
"control.Nat16"       use
"control.Nat32"       use
"control.Nat8"        use
"control.Natx"        use
"control.Ref"         use
"conventions.stdcall" use

"kernel32.OVERLAPPED" use

FN_ACCEPTEXRef: [{
  sListenSocket:         Natx;
  sAcceptSocket:         Natx;
  lpOutputBuffer:        Natx;
  dwReceiveDataLength:   Nat32;
  dwLocalAddressLength:  Nat32;
  dwRemoteAddressLength: Nat32;
  lpdwBytesReceived:     Nat32 Ref;
  lpOverlapped:          OVERLAPPED Ref;
} Int32 {convention: stdcall;} codeRef];

FN_CONNECTEXRef: [{
  s:                Natx;
  name:             Natx;
  namelen:          Int32;
  lpSendBuffer:     Natx;
  dwSendDataLength: Nat32;
  lpdwBytesSent:    Nat32 Ref;
  lpOverlapped:     OVERLAPPED Ref;
} Int32 {convention: stdcall;} codeRef];

FN_GETACCEPTEXSOCKADDRSRef: [{
  lpOutputBuffer:        Natx;
  dwReceiveDataLength:   Nat32;
  dwLocalAddressLength:  Nat32;
  dwRemoteAddressLength: Nat32;
  LocalSockaddr:         sockaddr AsRef Ref;
  LocalSockaddrLength:   Int32 Ref;
  RemoteSockaddr:        sockaddr AsRef Ref;
  RemoteSockaddrLength:  Int32 Ref;
} {} {convention: stdcall;} codeRef];

WSAOVERLAPPED_COMPLETION_ROUTINERef: [{
  dwError:       Nat32;
  cbTransferred: Nat32;
  lpOverlapped:  OVERLAPPED Ref;
  dwFlags:       Nat32;
} {} {convention: stdcall;} codeRef];

LOOKUPSERVICE_COMPLETION_ROUTINERef: [{
  dwError:      Nat32;
  dwBytes:      Nat32;
  lpOverlapped: OVERLAPPED Ref;
} () {convention: stdcall;} codeRef];

AF_INET: [2];

FIONBIO: [-2147195266];

INADDR_ANY: [0x00000000n32];

INVALID_SOCKET: [0nx 1nx -];

IPPROTO_TCP: [6];

SD_RECEIVE: [0];
SD_SEND:    [1];
SD_BOTH:    [2];

SIO_GET_EXTENSION_FUNCTION_POINTER: [0x80000000n32 0x40000000n32 or 0x08000000n32 or 6n32 or];

SOCK_STREAM: [1];

SOL_SOCKET: [0xffff];

SOMAXCONN: [0x7fffffff];

SO_UPDATE_ACCEPT_CONTEXT:  [0x700B];
SO_UPDATE_CONNECT_CONTEXT: [0x7010];

TCP_NODELAY: [1];

WSAEWOULDBLOCK: [10035];

WSAID_ACCEPTEX:             [(0xB5367DF1n32 0xCBACn16 0x11CFn16 (0x95n8 0xCAn8 0x00n8 0x80n8 0x5Fn8 0x48n8 0xA1n8 0x92n8))];
WSAID_CONNECTEX:            [(0x25A207B9n32 0xDDF3n16 0x4660n16 (0x8En8 0xE9n8 0x76n8 0xE5n8 0x8Cn8 0x74n8 0x06n8 0x3En8))];
WSAID_GETACCEPTEXSOCKADDRS: [(0xB5367DF2n32 0xCBACn16 0x11CFn16 (0x95n8 0xCAn8 0x00n8 0x80n8 0x5Fn8 0x48n8 0xA1n8 0x92n8))];

WSA_IO_PENDING: [997];

NS_DNS: [12n32];

WSABUF: [{
  len: Nat32;
  buf: Natx;
}];

WSADESCRIPTION_LEN: [256];
WSASYS_STATUS_LEN:  [128];

WSADATA: [{
  wVersion:     Nat16;
  wHighVersion: Nat16;
  Natx storageSize 8nx = [
    iMaxSockets:    Nat16;
    iMaxUdpDg:      Nat16;
    lpVendorInfo:   Nat8 Ref;
    szDescription:  Nat8 WSADESCRIPTION_LEN 1 + array;
    szSystemStatus: Nat8 WSASYS_STATUS_LEN 1 + array;
  ] [
    szDescription:  Nat8 WSADESCRIPTION_LEN 1 + array;
    szSystemStatus: Nat8 WSASYS_STATUS_LEN 1 + array;
    iMaxSockets:    Nat16;
    iMaxUdpDg:      Nat16;
    lpVendorInfo:   Nat8 Ref;
  ] uif
}];

addrinfo: [{
  ai_flags:     Int32;
  ai_family:    Int32;
  ai_socktype:  Int32;
  ai_protocol:  Int32;
  ai_addrlen:   Natx;
  ai_canonname: Natx;
  ai_addr:      Natx;
  ai_next:      Natx;
}];

ADDRINFOEXW: [{
  ai_flags:     0;
  ai_family:    0;
  ai_socktype:  0;
  ai_protocol:  0;
  ai_addrlen:   0nx;
  ai_canonname: 0nx;
  ai_addr:      0nx;
  ai_blob:      0nx;
  ai_bloblen:   0nx;
  ai_provider:  0nx;
  ai_next:      Natx;
}];

fd_set: [{
  fd_count: Nat32;
  fd_array: Natx 64 array;
}];

sockaddr: [{
  sa_family: Nat16;
  sa_data:   Nat8 14 array;
}];

sockaddr_in: [{
  sin_family: Nat16;
  sin_port:   Nat16;
  sin_addr:   Nat32;
  sin_zero:   Nat8 8 array;
}];

timeval: [{
  tv_sec:  Int32;
  tv_usec: Int32;
}];

# WS2_32.Lib should be included for these functions

{} Int32 {convention: stdcall;} "WSACleanup" importFunction

{} Int32 {convention: stdcall;} "WSAGetLastError" importFunction

{
  s:            Natx;
  lpOverlapped: OVERLAPPED Ref;
  lpcbTransfer: Nat32 Ref;
  fWait:        Int32;
  lpdwFlags:    Nat32 Ref;
} Int32 {convention: stdcall;} "WSAGetOverlappedResult" importFunction

{
  s:                   Natx;
  dwIoControlCode:     Nat32;
  lpvInBuffer:         Natx;
  cbInBuffer:          Nat32;
  lpvOutBuffer:        Natx;
  cbOutBuffer:         Nat32;
  lpcbBytesReturned:   Nat32 Ref;
  lpOverlapped:        OVERLAPPED Ref;
  lpCompletionRoutine: WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {convention: stdcall;} "WSAIoctl" importFunction

{
  s:                    Natx;
  lpBuffers:            WSABUF Ref;
  dwBufferCount:        Nat32;
  lpNumberOfBytesRecvd: Nat32 Ref;
  lpFlags:              Nat32 Ref;
  lpOverlapped:         OVERLAPPED Ref;
  lpCompletionRoutine:  WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {convention: stdcall;} "WSARecv" importFunction

{
  s:                   Natx;
  lpBuffers:           WSABUF Ref;
  dwBufferCount:       Nat32;
  lpNumberOfBytesSent: Nat32 Ref;
  dwFlags:             Nat32;
  lpOverlapped:        OVERLAPPED Ref;
  lpCompletionRoutine: WSAOVERLAPPED_COMPLETION_ROUTINERef;
} Int32 {convention: stdcall;} "WSASend" importFunction

{
  iError: Int32;
} {} {convention: stdcall;} "WSASetLastError" importFunction

{
  wVersionRequested: Nat16;
  lpWSAData:         WSADATA Ref;
} Int32 {convention: stdcall;} "WSAStartup" importFunction

{
  s:       Natx;
  name:    Natx;
  namelen: Int32;
} Int32 {convention: stdcall;} "bind" importFunction

{
  s: Natx;
} Int32 {convention: stdcall;} "closesocket" importFunction

{
  s:       Natx;
  name:    sockaddr Ref;
  nameLen: Int32;
} Int32 {convention: stdcall;} "connect" importFunction

{
  pAddrInfo: addrinfo Ref;
} {} {convention: stdcall;} "freeaddrinfo" importFunction

{
  pAddrInfoEx: ADDRINFOEXW Ref;
} () {convention: stdcall;} "FreeAddrInfoExW" importFunction

{
  pNodeName:    Natx;
  pServiceName: Natx;
  pHints:       addrinfo Cref;
  ppResult:     Natx;
} Int32 {convention: stdcall;} "getaddrinfo" importFunction

{
  pName:               Natx;
  pServiceName:        Natx;
  dwNameSpace:         Nat32;
  lpNspId:             Natx;
  pHints:              ADDRINFOEXW Ref;
  ppResult:            ADDRINFOEXW AsRef Ref;
  timeout:             Natx;
  lpOverlapped:        OVERLAPPED Ref;
  lpCompletionRoutine: LOOKUPSERVICE_COMPLETION_ROUTINERef;
  lpHandle:            Natx Ref;
} Int32 {convention: stdcall;} "GetAddrInfoExW" importFunction

{
  lpHandle: Natx Ref;
} Int32 {convention: stdcall;} "GetAddrInfoExCancel" importFunction

{
  hostlong: Nat32;
} Nat32 {convention: stdcall;} "htonl" importFunction

{
  hostshort: Nat16;
} Nat16 {convention: stdcall;} "htons" importFunction

{
  s:    Natx;
  cmd:  Int32;
  argp: Natx;
} Int32 {convention: stdcall;} "ioctlsocket" importFunction

{
  s:       Natx;
  backlog: Int32;
} Int32 {convention: stdcall;} "listen" importFunction

{
  netlong: Nat32;
} Nat32 {convention: stdcall;} "ntohl" importFunction

{
  netshort: Nat16;
} Nat16 {convention: stdcall;} "ntohs" importFunction

{
  s:     Natx;
  buf:   Natx;
  len:   Int32;
  flags: Int32;
} Int32 {convention: stdcall;} "recv" importFunction

{
  ndfs:      Int32;
  readfds:   fd_set Ref;
  writefds:  fd_set Ref;
  exceptfds: fd_set Ref;
  timeout:  timeval Ref;
} Int32 {convention: stdcall;} "select" importFunction

{
  s:     Natx;
  buf:   Natx;
  len:   Int32;
  flags: Int32;
} Int32 {convention: stdcall;} "send" importFunction

{
  s: Natx;
  level: Int32;
  optname: Int32;
  optval: Natx;
  optlen: Int32;
} Int32 {convention: stdcall;} "setsockopt" importFunction

{
  s:   Natx;
  how: Int32;
} Int32 {convention: stdcall;} "shutdown" importFunction

{
  af:       Int32;
  type:     Int32;
  protocol: Int32;
} Natx {convention: stdcall;} "socket" importFunction
