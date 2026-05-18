# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

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

MSG_NOSIGNAL: [0x80000n32];

SHUT_WR: [1];

SOCK_STREAM: [1];

SOL_SOCKET: [0xFFFF];

SOMAXCONN: [128];

SO_ERROR:     [0x1007];
SO_REUSEADDR: [0x0004];

TCP_NODELAY: [1];

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

in_addr: [Nat32];

sockaddr: [{
  sa_len:    Nat8;
  sa_family: Nat8;
  sa_data:   Nat8 14 array;
}];

sockaddr_in: [{
  sin_len:    Nat8;
  sin_family: Nat8;
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
  sockfd:  Int32;
  addr:    sockaddr Cref;
  addrlen: socklen_t;
} Int32 {convention: cdecl;} "connect" importFunction

{
  res: addrinfo Ref;
} {} {convention: cdecl;} "freeaddrinfo" importFunction

{
  node:    Natx;
  service: Natx;
  hints:   addrinfo Cref;
  res:     Natx;
} Int32 {convention: cdecl;} "getaddrinfo" importFunction

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
