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

MSG_NOSIGNAL: [0x4000n32];

SHUT_WR: [1];

SOCK_STREAM: [1];

SOL_SOCKET: [1];

SOMAXCONN: [128];

SO_ERROR:     [4];
SO_REUSEADDR: [2];

TCP_NODELAY: [1];

addrinfo: [{
  ai_flags:     Int32;
  ai_family:    Int32;
  ai_socktype:  Int32;
  ai_protocol:  Int32;
  ai_addrlen:   Natx;
  ai_addr:      Natx;
  ai_canonname: Natx;
  ai_next:      Natx;
}];

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
