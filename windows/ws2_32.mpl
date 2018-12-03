"ws2_32" module
"kernel32" includeModule
"ws2_32Private" useModule

winsock2: {
  FN_ACCEPTEXRef: [{
    sListenSocket: Natx;
    sAcceptSocket: Natx;
    lpOutputBuffer: Natx;
    dwReceiveDataLength: Nat32;
    dwLocalAddressLength: Nat32;
    dwRemoteAddressLength: Nat32;
    lpdwBytesReceived: Nat32 Ref;
    lpOverlapped: kernel32.OVERLAPPED Ref;
  } Int32 {} codeRef] func;

  FN_CONNECTEXRef: [{
    s: Natx;
    name: Natx;
    namelen: Int32;
    lpSendBuffer: Natx;
    dwSendDataLength: Nat32;
    lpdwBytesSent: Nat32 Ref;
    lpOverlapped: kernel32.OVERLAPPED Ref;
  } Int32 {} codeRef] func;

  WSAOVERLAPPED_COMPLETION_ROUTINERef: @WSAOVERLAPPED_COMPLETION_ROUTINERef;

  AF_INET: [2] func;

  INADDR_ANY: [0x00000000n32] func;

  INVALID_SOCKET: [0nx 1nx -] func;

  IPPROTO_TCP: [6] func;

  SIO_GET_EXTENSION_FUNCTION_POINTER: [0x80000000n32 0x40000000n32 or 0x08000000n32 or 6n32 or] func;

  SOCK_STREAM: [1] func;

  SOL_SOCKET: [0xffff] func;

  SOMAXCONN: [0x7fffffff] func;

  SO_UPDATE_ACCEPT_CONTEXT: [0x700B] func;
  SO_UPDATE_CONNECT_CONTEXT: [0x7010] func;

  TCP_NODELAY: [1] func;

  WSAID_ACCEPTEX: [(0xB5367DF1n32 0xCBACn16 0x11CFn16 (0x95n8 0xCAn8 0x00n8 0x80n8 0x5Fn8 0x48n8 0xA1n8 0x92n8))] func;
  WSAID_CONNECTEX: [(0x25A207B9n32 0xDDF3n16 0x4660n16 (0x8En8 0xE9n8 0x76n8 0xE5n8 0x8Cn8 0x74n8 0x06n8 0x3En8))] func;

  WSA_IO_PENDING: [997] func;

  WSABUF: @WSABUF;

  WSADESCRIPTION_LEN: @WSADESCRIPTION_LEN;
  WSASYS_STATUS_LEN: @WSASYS_STATUS_LEN;

  WSADATA: @WSADATA;

  sockaddr_in: [{
    sin_family: Nat16;
    sin_port: Nat16;
    sin_addr: Nat32;
    sin_zero: Nat8 8 array;
  }] func;

  # WS2_32.Lib should be included for these functions
  WSACleanup: @WSACleanup;
  WSAGetLastError: @WSAGetLastError;
  WSAGetOverlappedResult: @WSAGetOverlappedResult;
  WSAIoctl: @WSAIoctl;
  WSARecv: @WSARecv;
  WSASend: @WSASend;
  WSASetLastError: @WSASetLastError;
  WSAStartup: @WSAStartup;
  bind: @bind;
  closesocket: @closesocket;
  htonl: @htonl;
  htons: @htons;
  listen: @listen;
  setsockopt: @setsockopt;
  socket: @socket;
};
