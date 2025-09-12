# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32"     use
"control.Intx"      use
"control.Nat32"     use
"control.Natx"      use
"control.Ref"       use
"conventions.cdecl" use

F_SETFD: [2];

FD_CLOEXEC: [1];

SIGKILL: [9];

WEXITSTATUS: [
  status: Nat32 cast;
  status 0xFF00n32 and 8n32 rshift Int32 cast
];

WIFEXITED: [
  status: Nat32 cast;
  status 0x7Fn32 and 0n32 =
];

{
  fildes: Int32;
} Int32 {convention: cdecl;} "close" importFunction

{
  file: Natx;
  argv: Natx;
} Int32 {convention: cdecl;} "execvp" importFunction

{
  fildes: Int32;
  cmd:    Int32;
} Int32 {convention: cdecl; variadic: TRUE;} "fcntl" importFunction

{} Int32 {convention: cdecl;} "fork" importFunction

{
  pid: Int32;
  sig: Int32;
} Int32 {convention: cdecl;} "kill" importFunction

{
  filedes: {in: Int32; out: Int32;} Ref;
} Int32 {convention: cdecl;} "pipe" importFunction

{
  filedes: Int32;
  buffer:  Natx;
  size:    Natx;
} Intx {convention: cdecl;} "read" importFunction

{
  pid:     Int32;
  wstatus: Int32 Ref;
  options: Int32;
} Int32 {convention: cdecl;} "waitpid" importFunction

{
  filedes: Int32;
  buffer:  Natx;
  size:    Natx;
} Intx {convention: cdecl;} "write" importFunction
