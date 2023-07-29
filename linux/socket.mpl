"control.Cref"      use
"control.Int32"     use
"control.Intx"      use
"control.Nat16"     use
"control.Nat32"     use
"control.Nat8"      use
"control.Natx"      use
"control.Ref"       use
"conventions.cdecl" use

AF_INET: [2];

F_GETFL: [3];
F_SETFL: [4];

INADDR_ANY: [0x00000000n32];

INVALID_SOCKET: [-1];

IPPROTO_TCP: [6];

MSG_NOSIGNAL: [0x4000n32];

SHUT_WR: [1];

SOCK_STREAM: [1];

SOL_SOCKET: [1];

SOMAXCONN: [128];

SO_ERROR:     [4];
SO_REUSEADDR: [2];

TCP_NODELAY: [1];

in_addr: [Nat32];

sockaddr: [{
  sa_family: Nat16;
  sa_data:   Nat8 14 array;
}];

sockaddr_in: [{
  sin_family: Nat16;
  sin_port:   Nat16;
  sin_addr:   in_addr;
  sin_zero:   Nat8 8 array;
}];

socklen_t: [Nat32];

{
  sockfd:  Int32;
  addr:    sockaddr Ref;
  addrlen: socklen_t Ref;
} Int32 {convention: cdecl;} "accept" importFunction

{
  sockfd:  Int32;
  addr:    sockaddr Cref;
  addrlen: socklen_t;
} Int32 {convention: cdecl;} "bind" importFunction

{
  fd: Int32;
} Int32 {convention: cdecl;} "close" importFunction

{
  sockfd:  Int32;
  addr:    sockaddr Cref;
  addrlen: socklen_t;
} Int32 {convention: cdecl;} "connect" importFunction

{
  fd:  Int32;
  cmd: Int32;
  arg: Int32;
} Int32 {convention: cdecl;} "fcntl" importFunction

{
  socket:       Int32;
  level:        Int32;
  option_name:  Int32;
  option_value: Natx;
  option_len:   socklen_t Ref;
} Int32 {convention: cdecl;} "getsockopt" importFunction

{
  hostlong: Nat32;
} Nat32 {convention: cdecl;} "htonl" importFunction

{
  hostshort: Nat16;
} Nat16 {convention: cdecl;} "htons" importFunction

{
  sockfd:  Int32;
  backlog: Int32;
} Int32 {convention: cdecl;} "listen" importFunction

{
  netlong: Nat32;
} Nat32 {convention: cdecl;} "ntohl" importFunction

{
  sockfd: Int32;
  buf:    Natx;
  len:    Natx;
  flags:  Int32;
} Intx {convention: cdecl;} "recv" importFunction

{
  sockfd: Int32;
  buf:    Natx;
  len:    Natx;
  flags:  Int32;
} Intx {convention: cdecl;} "send" importFunction

{
  socket:       Int32;
  level:        Int32;
  option_name:  Int32;
  option_value: Natx;
  option_len:   socklen_t;
} Int32 {convention: cdecl;} "setsockopt" importFunction

{
  sockfd: Int32;
  how:    Int32;
} Int32 {convention: cdecl;} "shutdown" importFunction

{
  domain:   Int32;
  type:     Int32;
  protocol: Int32;
} Int32 {convention: cdecl;} "socket" importFunction
