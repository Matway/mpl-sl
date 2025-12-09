# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32"     use
"control.Intx"      use
"control.Cref"      use
"control.Nat16"     use
"control.Nat32"     use
"control.Natx"      use
"control.Ref"       use
"conventions.cdecl" use

"socket.addrinfo"  use
"socket.sockaddr"  use
"socket.socklen_t" use

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
