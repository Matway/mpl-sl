# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Mref.Mref"         use
"control.Int32"     use
"control.Int64"     use
"control.Intx"      use
"control.Nat16"     use
"control.Nat32"     use
"control.Nat64"     use
"control.Natx"      use
"control.Ref"       use
"conventions.cdecl" use

EAGAIN:      [11];
EINPROGRESS: [115];
EINTR:       [4];
EWOULDBLOCK: [EAGAIN];

long: [Intx];

# fcntl

O_NONBLOCK: [2048];

# signal

stack_t: [{
  ss_sp:    Natx;
  ss_flags: Int32;
  ss_size:  Natx;
}];

_SIGSET_NWORDS: [1024 Natx storageSize Int32 cast 8 * /];
sigset_t:       [Natx _SIGSET_NWORDS array];

# time

CLOCK_MONOTONIC: [1];

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

# ucontext

Natx storageSize 8nx = [ # __x86_64__
  greg_t: [Int64];

  __NGREG: [23];

  gregset_t: [greg_t __NGREG array];

  _libc_fpxreg: [{
    significand:       Nat16 4 array;
    exponent:          Nat16;
    __glibc_reserved1: Nat16 3 array;
  }];

  _libc_xmmreg: [{
    element: Nat32 4 array;
  }];

  _libc_fpstate: [{
    cwd:               Nat16;
    swd:               Nat16;
    ftw:               Nat16;
    fop:               Nat16;
    rip:               Nat64;
    rdp:               Nat64;
    mxcsr:             Nat32;
    mxcr_mask:         Nat32;
    _st:               _libc_fpxreg 8 array;
    _xmm:              _libc_xmmreg 16 array;
    __glibc_reserved1: Nat32 24 array;
  }];

  fpregset_t: [_libc_fpstate Ref];

  mcontext_t: [{
    gregs:       gregset_t;
    fpregs:      fpregset_t;
    __reserved1: Nat64 8 array;
  }];

  ucontext_t: [{
    uc_flags:     Natx;
    uc_link:      [ucontext_t] Mref;
    uc_stack:     stack_t;
    uc_mcontext:  mcontext_t;
    uc_sigmask:   sigset_t;
    __fpregs_mem: _libc_fpstate;
    __ssp:        Nat64 4 array;
  }];
] [ # !__x86_64__
  greg_t: [Int32];

  __NGREG: [19];

  gregset_t: [greg_t __NGREG array];

  _libc_fpreg: [{
    significand: Nat16 4 array;
    exponent:    Nat16;
  }];

  _libc_fpstate: [{
    cw:      Natx;
    sw:      Natx;
    tag:     Natx;
    ipoff:   Natx;
    cssel:   Natx;
    dataoff: Natx;
    datasel: Natx;
    _st:     _libc_fpreg 8 array;
    status:  Natx;
  }];

  fpregset_t: [_libc_fpstate Ref];

  mcontext_t: [{
    gregs:   gregset_t;
    fpregs:  fpregset_t;
    oldmask: Natx;
    cr2:     Natx;
  }];

  ucontext_t: [{
    uc_flags:     Natx;
    uc_link:      [ucontext_t] Mref;
    uc_stack:     stack_t;
    uc_mcontext:  mcontext_t;
    uc_sigmask:   sigset_t;
    __fpregs_mem: _libc_fpstate;
    __ssp:        Natx 4 array;
  }];
] uif

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
