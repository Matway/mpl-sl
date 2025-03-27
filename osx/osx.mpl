# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Cref"      use
"control.Int32"     use
"control.Nat32"     use
"control.Nat64"     use
"control.Natx"      use
"control.Ref"       use
"control.swap"      use
"control.when"      use
"conventions.cdecl" use

"posix.itimerspec"  use
"posix.timespec"    use

# kevent

# Mimic:
#     struct kevent {
#             uintptr_t       ident;          /* identifier for this event */
#             int16_t         filter;         /* filter for event */
#             uint16_t        flags;          /* general flags */
#             uint32_t        fflags;         /* filter-specific flags */
#             intptr_t        data;           /* filter-specific data */
#             void            *udata;         /* opaque user data identifier */
#     };
kevent: [{
  ident:    Nat32 Ref;  # identifier for this event
  filter:   Int16;      # filter for event
  flags:    Nat16;      # general flags
  fflags:   Int32;      # filter-specific flags
  data:     Int32 Ref;  # filter-specific data
  udata:    Natx;       # opaque user data identifier
}];

# EV_SET(&kev, ident, filter, flags, fflags, data, udata);
EV_SET: [
  kev: ident: filter: flags: fflags: data: udata:;;;;;;;
  ident     @kev.!ident
  filter    @kev.!filter
  flags     @kev.!flags
  fflags    @kev.!fflags
  data      @kev.!data
  udata     @kev.!udata
];

# Filter types
EVFILT_READ:        -1;
EVFILT_WRITE        -2;
EVFILT_AIO:         -3;     # attached to aio requests
EVFILT_VNODE:       -4;     # attached to vnodes
EVFILT_PROC:        -5;     # attached to struct proc
EVFILT_SIGNAL:      -6;     # attached to struct proc
EVFILT_TIMER:       -7;     # timers
EVFILT_MACHPORT:    -8;     # Mach portsets
EVFILT_FS:          -9;     # Filesystem events
EVFILT_USER:        -10;    # User events
EVFILT_VM:          -12;    # Virtual memory events
EVFILT_EXCEPT:      -15;    # Exception events

# kevent system call flags
KEVENT_FLAG_NONE:           0x000000;   # no flag value
KEVENT_FLAG_IMMEDIATE:      0x000001;   # immediate timeout
KEVENT_FLAG_ERROR_EVENTS:   0x000002;   # output events only include change errors

# actions
EV_ADD:     0x0001;     # add event to kq (implies enable)
EV_DELETE:  0x0002;     # delete event from kq
EV_ENABLE:  0x0004;     # enable event
EV_DISABLE: 0x0008;     # disable event (not reported)

# flags
EV_ONESHOT: 0x0010;     # only report one occurrence
EV_CLEAR:   0x0020;     # clear event state after reporting
EV_RECEIPT: 0x0040;     # force immediate event output
                        # ... with or without EV_ERROR
                        # ... use KEVENT_FLAG_ERROR_EVENTS
                        #     on syscalls supporting flags

EV_DISPATCH:        0x0080;     # disable event after reporting
EV_UDATA_SPECIFIC:  0x0100;     # unique kevent per udata value

EV_DISPATCH2:       EV_DISPATCH EV_UDATA_SPECIFIC |;
# ... in combination with EV_DELETE
# will defer delete until udata-specific
# event enabled. EINPROGRESS will be
# returned to indicate the deferral

EV_VANISHED:    0x0200;     # report that source has vanished 
                            # ... only valid with EV_DISPATCH2

EV_SYSFLAGS:    0xF000;     # reserved by system
EV_FLAG0:       0x1000;     # filter-specific flag
EV_FLAG1:       0x2000;     # filter-specific flag


{} Int32 {convention: cdecl;} "kqueue" importFunction 

{
  kq:           Int32;
  changelist:   kevent Cref;
  nchanges:     Int32;
  eventlist:    kevent Ref;
  nevents:      Int32;
  timeout:      timespec Cref;
} Int32 {convention: cdecl;} "kevent" importFunction


# timerfd

TFD_NONBLOCK: [2048];

{
  clockid: Int32;
  flags:   Int32;
} Int32 {convention: cdecl;} "timerfd_create" importFunction

{
  fd:        Int32;
  flags:     Int32;
  new_value: itimerspec Cref;
  old_value: itimerspec Ref;
} Int32 {convention: cdecl;} "timerfd_settime" importFunction
