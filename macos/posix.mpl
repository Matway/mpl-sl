# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Mref.Mref"         use
"String.print"      use
"control.Int32"     use
"control.Intx"      use
"control.Nat16"     use
"control.Nat32"     use
"control.Nat64"     use
"control.Nat8"      use
"control.Natx"      use
"control.Ref"       use
"control.pfunc"     use
"control.print"     use
"conventions.cdecl" use

EAGAIN:      [    35];
EINPROGRESS: [    36];
EINTR:       [     4];
EINVAL:      [    22];
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

O_NONBLOCK: [4];

stack_t: [{
  ss_sp:    Natx;
  ss_flags: Int32;
  ss_size:  Natx;
}];

_SIGSET_NWORDS: [1024 Natx storageSize Int32 cast 8 * /];
sigset_t:       [Natx _SIGSET_NWORDS array];

CLOCK_MONOTONIC:  [1];
CLOCK_BOOTTIME:   [7];
CLOCK_UPTIME_RAW: [8];

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

__darwin_sigaltstack: [{
  ss_sp:    Natx;
  ss_size:  Nat64;
  ss_flags: Int32;
}];

__darwin_x86_exception_state64: [{
  __trapno:     Nat16;
  __cpu:        Nat16;
  __err:        Nat32;
  __faultvaddr: Nat64;
}];

__darwin_x86_thread_state64: [{
  __rax:    Nat64;
  __rbx:    Nat64;
  __rcx:    Nat64;
  __rdx:    Nat64;
  __rdi:    Nat64;
  __rsi:    Nat64;
  __rbp:    Nat64;
  __rsp:    Nat64;
  __r8:     Nat64;
  __r9:     Nat64;
  __r10:    Nat64;
  __r11:    Nat64;
  __r12:    Nat64;
  __r13:    Nat64;
  __r14:    Nat64;
  __r15:    Nat64;
  __rip:    Nat64;
  __rflags: Nat64;
  __cs:     Nat64;
  __fs:     Nat64;
  __gs:     Nat64;
}];

__darwin_fp_control: [{
  FORMAT_OPTIONS: [{
    call: TRUE;
  }];
  private data: Nat16;
  __invalid: [data              1n16 and];
  __denorm:  [data 1n8   rshift 1n16 and];
  __zdiv:    [data 2n8   rshift 1n16 and];
  __ovrfl:   [data 3n8   rshift 1n16 and];
  __undfl:   [data 4n8   rshift 1n16 and];
  __precis:  [data 5n8   rshift 1n16 and];
  __pc:      [data 8n8   rshift 3n16 and];
  __rc:      [data 10n8  rshift 3n16 and];
}];

__darwin_fp_status: [{
  FORMAT_OPTIONS: [{
    call: TRUE;
  }];
  data: Nat16;
  __invalid: [data              1n16 and];
  __denorm:  [data 1n8   rshift 1n16 and];
  __zdiv:    [data 2n8   rshift 1n16 and];
  __ovrfl:   [data 3n8   rshift 1n16 and];
  __undfl:   [data 4n8   rshift 1n16 and];
  __precis:  [data 5n8   rshift 1n16 and];
  __stkflt:  [data 6n8   rshift 1n16 and];
  __errsumm: [data 7n8   rshift 1n16 and];
  __c0:      [data 8n8   rshift 1n16 and];
  __c1:      [data 9n8   rshift 1n16 and];
  __c2:      [data 10n8  rshift 1n16 and];
  __tos:     [data 11n8  rshift 7n16 and];
  __c3:      [data 14n8  rshift 1n16 and];
  __busy:    [data 15n8  rshift 1n16 and];
}];

__darwin_mmst_reg: [{
  __mmst_reg:   Nat8 10 array;
  __mmst_rsrv:  Nat8 6  array;
}];

__darwin_xmm_reg: [{
  __xmm_reg: Nat8 16 array;
}];

__darwin_x86_float_state64: [{
  __fpu_reserved:   Int32 2 array;
  __fpu_fcw:        __darwin_fp_control;
  __fpu_fsw:        __darwin_fp_status;
  __fpu_ftw:        Nat8;
  __fpu_rsrv1:      Nat8;
  __fpu_fop:        Nat16;

  __fpu_ip: Nat32;
  __fpu_cs: Nat16;

  __fpu_rsrv2: Nat16;

  __fpu_dp: Nat32;
  __fpu_ds: Nat16;

  __fpu_rsrv3:      Nat16;
  __fpu_mxcsr:      Nat32;
  __fpu_mxcsrmask:  Nat32;
  __fpu_stmm0:      __darwin_mmst_reg;
  __fpu_stmm1:      __darwin_mmst_reg;
  __fpu_stmm2:      __darwin_mmst_reg;
  __fpu_stmm3:      __darwin_mmst_reg;
  __fpu_stmm4:      __darwin_mmst_reg;
  __fpu_stmm5:      __darwin_mmst_reg;
  __fpu_stmm6:      __darwin_mmst_reg;
  __fpu_stmm7:      __darwin_mmst_reg;
  __fpu_xmm0:       __darwin_xmm_reg;
  __fpu_xmm1:       __darwin_xmm_reg;
  __fpu_xmm2:       __darwin_xmm_reg;
  __fpu_xmm3:       __darwin_xmm_reg;
  __fpu_xmm4:       __darwin_xmm_reg;
  __fpu_xmm5:       __darwin_xmm_reg;
  __fpu_xmm6:       __darwin_xmm_reg;
  __fpu_xmm7:       __darwin_xmm_reg;
  __fpu_xmm8:       __darwin_xmm_reg;
  __fpu_xmm9:       __darwin_xmm_reg;
  __fpu_xmm10:      __darwin_xmm_reg;
  __fpu_xmm11:      __darwin_xmm_reg;
  __fpu_xmm12:      __darwin_xmm_reg;
  __fpu_xmm13:      __darwin_xmm_reg;
  __fpu_xmm14:      __darwin_xmm_reg;
  __fpu_xmm15:      __darwin_xmm_reg;
  __fpu_rsrv4:      Nat8 6 16 * array;
  __fpu_reserved1:  Int32;
}];

__darwin_mcontext64: [{
  __es: __darwin_x86_exception_state64;
  __ss: __darwin_x86_thread_state64;
  __fs: __darwin_x86_float_state64;
}];

ucontext_t: [{
  uc_onstack:       Int32;
  uc_sigmask:       Nat32;
  uc_stack:         __darwin_sigaltstack;
  uc_link:          [ucontext_t] Mref;
  uc_mcsize:        Natx;
  uc_mcontext:      [__darwin_mcontext64] Mref;
  __mcontext_data:  __darwin_mcontext64;
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

{
  ucp: ucontext_t Ref;
} Int32 {convention: cdecl;} "getcontext" importFunction

{
  ucp:  ucontext_t Ref;
  func: Natx;
  argc: Int32;
} {} {variadic: TRUE; convention: cdecl;} "makecontext" importFunction

{
  oucp: ucontext_t Ref;
  ucp:  ucontext_t Ref;
} Int32 {convention: cdecl;} "swapcontext" importFunction
