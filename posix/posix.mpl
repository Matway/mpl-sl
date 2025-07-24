# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32"        use
"control.Intx"         use
"control.Nat32"        use
"control.Natx"         use
"control.Ref"          use
"conventions.cdecl"    use
"ucontext.getcontext"  use
"ucontext.makecontext" use
"ucontext.swapcontext" use
"ucontext.ucontext_t"  use

EAGAIN:      [11];
EINPROGRESS: [115];
EINTR:       [4];
EWOULDBLOCK: [EAGAIN];

F_SETFD: [2];

FD_CLOEXEC: [1];

SIGKILL: [9];

WNOHANG: [1];

WEXITSTATUS: [
  status: Nat32 cast;
  status 0xFF00n32 and 8n32 rshift Int32 cast
];

WIFEXITED: [
  status: Nat32 cast;
  status 0x7Fn32 and 0n32 =
];

long: [Intx];

O_NONBLOCK: [2048];

stack_t: [{
  ss_sp:    Natx;
  ss_flags: Int32;
  ss_size:  Natx;
}];

_SIGSET_NWORDS: [1024 Natx storageSize Int32 cast 8 * /];
sigset_t:       [Natx _SIGSET_NWORDS array];

CLOCK_MONOTONIC:    [1];
CLOCK_BOOTTIME:     [7];
CLOCK_UPTIME_RAW:   [8];

time_t: [Intx];

clockid_t: [Int32];

itimerspec: [{
  it_interval: timespec;
  it_value:    timespec;
}];

timespec: [{
  tv_sec:  time_t;
  tv_nsec: long;
}];

{
  clk_id: clockid_t;
  tp:     timespec Ref;
} Int32 {convention: cdecl;} "clock_gettime" importFunction

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

ucontext_t: @ucontext_t;
getcontext: @getcontext;
makecontext: @makecontext;
swapcontext: @swapcontext;
