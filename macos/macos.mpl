# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Cref"      use
"control.Int16"     use
"control.Int32"     use
"control.Int64"     use
"control.Nat16"     use
"control.Nat32"     use
"control.Nat64"     use
"control.Natx"      use
"control.Ref"       use
"control.swap"      use
"control.when"      use
"conventions.cdecl" use

"posix.itimerspec" use
"posix.timespec"   use

# struct_kevent

# Mimic:
#     struct struct_kevent {
#             uintptr_t       ident;          /* identifier for this event */
#             int16_t         filter;         /* filter for event */
#             uint16_t        flags;          /* general flags */
#             uint32_t        fflags;         /* filter-specific flags */
#             intptr_t        data;           /* filter-specific data */
#             void            *udata;         /* opaque user data identifier */
#     };
struct_kevent: [{
  ident:    Nat32 Ref;  # identifier for this event
  filter:   Int16;      # filter for event
  flags:    Nat16;      # general flags
  fflags:   Nat32;      # filter-specific flags
  data:     Int32 Ref;  # filter-specific data
  udata:    Natx;       # opaque user data identifier
}];

# Mimic:
# struct struct_kevent64_s {
#   uint64_t ident;
#   int16_t filter;
#   uint16_t flags;
#   uint32_t fflags;
#   int64_t data;
#   uint64_t udata;
#   uint64_t ext[2];
# };

struct_kevent64_s: [{
  ident:    Nat64;          # identifier for this event
  filter:   Int16;          # filter for event
  flags:    Nat16;          # general flags
  fflags:   Nat32;          # filter-specific flags
  data:     Int64;          # filter-specific data
  udata:    Nat64;          # opaque user data identifier
  ext:      Nat64 2 array;  # filter-specific extensions
}];

EV_SET: [
  kev: ident: filter: flags: fflags: data: udata:;;;;;;;

  ident storageAddress Nat32 addressToReference     @kev.!ident
  data  storageAddress Int32 addressToReference     @kev.!data

  filter    @kev.@filter    set
  flags     @kev.@flags     set
  fflags    @kev.@fflags    set
  udata     @kev.@udata     set
];

EV_SET64: [
  kev: ident: filter: flags: fflags: data: udata: ext0: ext1:;;;;;;;;;

  ident Nat64 cast      @kev.@ident     set
  filter                @kev.@filter    set
  flags                 @kev.@flags     set
  fflags                @kev.@fflags    set
  data  Int64 cast      @kev.@data      set
  udata Nat64 cast      @kev.@udata     set
  @ext0                 0 @kev.@ext @   set
  @ext1                 1 @kev.@ext @   set
];

# Filter types
EVFILT_READ:        [-1i16];
EVFILT_WRITE:       [-2i16];
EVFILT_AIO:         [-3i16];     # attached to aio requests
EVFILT_VNODE:       [-4i16];     # attached to vnodes
EVFILT_PROC:        [-5i16];     # attached to struct proc
EVFILT_SIGNAL:      [-6i16];     # attached to struct proc
EVFILT_TIMER:       [-7i16];     # timers
EVFILT_MACHPORT:    [-8i16];     # Mach portsets
EVFILT_FS:          [-9i16];     # Filesystem events
EVFILT_USER:        [-10i16];    # User events
EVFILT_VM:          [-12i16];    # Virtual memory events
EVFILT_EXCEPT:      [-15i16];    # Exception events

# struct_kevent system call flags
KEVENT_FLAG_NONE:           0x000000;   # no flag value
KEVENT_FLAG_IMMEDIATE:      0x000001;   # immediate timeout
KEVENT_FLAG_ERROR_EVENTS:   0x000002;   # output events only include change errors

# actions
EV_ADD:     0x0001n16;     # add event to kq (implies enable)
EV_DELETE:  0x0002n16;     # delete event from kq
EV_ENABLE:  0x0004n16;     # enable event
EV_DISABLE: 0x0008n16;     # disable event (not reported)

# flags
EV_ONESHOT: 0x0010n16;     # only report one occurrence
EV_CLEAR:   0x0020n16;     # clear event state after reporting
EV_RECEIPT: 0x0040n16;     # force immediate event output
# ... with or without EV_ERROR
# ... use KEVENT_FLAG_ERROR_EVENTS
#     on syscalls supporting flags

EV_DISPATCH:        0x0080n16;     # disable event after reporting
EV_UDATA_SPECIFIC:  0x0100n16;     # unique struct_kevent per udata value

EV_DISPATCH2:       EV_DISPATCH Nat32 cast EV_UDATA_SPECIFIC Nat32 cast or;
# ... in combination with EV_DELETE
# will defer delete until udata-specific
# event enabled. EINPROGRESS will be
# returned to indicate the deferral

EV_VANISHED:    0x0200n16;     # report that source has vanished
# ... only valid with EV_DISPATCH2

EV_SYSFLAGS:    0xF000n16;     # reserved by system
EV_FLAG0:       0x1000n16;     # filter-specific flag
EV_FLAG1:       0x2000n16;     # filter-specific flag

NOTE_TRIGGER:                       0x01000000n32;
NOTE_FFNOP:                         0x00000000n32; # ignore input fflags 
NOTE_FFAND:                         0x40000000n32; # and fflags 
NOTE_FFOR:                          0x80000000n32; # or fflags 
NOTE_FFCOPY:                        0xc0000000n32; # copy fflags 
NOTE_FFCTRLMASK:                    0xc0000000n32; # mask for operations 
NOTE_FFLAGSMASK:                    0x00ffffffn32;
NOTE_LOWAT:                         0x00000001n32; # low water mark 
NOTE_OOB:                           0x00000002n32; # OOB data 
NOTE_DELETE:                        0x00000001n32; # vnode was removed 
NOTE_WRITE:                         0x00000002n32; # data contents changed 
NOTE_EXTEND:                        0x00000004n32; # size increased 
NOTE_ATTRIB:                        0x00000008n32; # attributes changed 
NOTE_LINK:                          0x00000010n32; # link count changed 
NOTE_RENAME:                        0x00000020n32; # vnode was renamed 
NOTE_REVOKE:                        0x00000040n32; # vnode access was revoked 
NOTE_NONE:                          0x00000080n32; # No specific vnode event; to test for EVFILT_READ activation
NOTE_FUNLOCK:                       0x00000100n32; # vnode was unlocked by flock(2) 
NOTE_LEASE_DOWNGRADE:               0x00000200n32; # lease downgrade requested 
NOTE_LEASE_RELEASE:                 0x00000400n32; # lease release requested 
NOTE_EXIT:                          0x80000000n32; # process exited 
NOTE_FORK:                          0x40000000n32; # process forked 
NOTE_EXEC:                          0x20000000n32; # process exec'd 
NOTE_REAP:                          0x00080000n32; # process reaped
NOTE_SIGNAL:                        0x08000000n32; # shared with EVFILT_SIGNAL 
NOTE_EXITSTATUS:                    0x04000000n32; # exit status to be returned, valid for child process or when allowed to signal target pid 
NOTE_EXIT_DETAIL:                   0x02000000n32; # provide details on reasons for exit 
NOTE_PDATAMASK:                     0x000fffffn32; # mask for signal & exit status 
NOTE_PCTRLMASK:                     NOTE_PDATAMASK ~;
NOTE_EXIT_REPARENTED:               0x00080000n32; # exited while reparented
NOTE_EXIT_DETAIL_MASK:              0x00070000n32;
NOTE_EXIT_DECRYPTFAIL:              0x00010000n32;
NOTE_EXIT_MEMORY:                   0x00020000n32;
NOTE_EXIT_CSERROR:                  0x00040000n32;
NOTE_VM_PRESSURE:                   0x80000000n32; # will react on memory pressure 
NOTE_VM_PRESSURE_TERMINATE:         0x40000000n32; # will quit on memory pressure, possibly after cleaning up dirty state 
NOTE_VM_PRESSURE_SUDDEN_TERMINATE:  0x20000000n32; # will quit immediately on memory pressure 
NOTE_VM_ERROR:                      0x10000000n32;    # there was an error 
NOTE_SECONDS:                       0x00000001n32;    # data is seconds         
NOTE_USECONDS:                      0x00000002n32;    # data is microseconds    
NOTE_NSECONDS:                      0x00000004n32;    # data is nanoseconds     
NOTE_ABSOLUTE:                      0x00000008n32;    # absolute timeout        
NOTE_LEEWAY:                        0x00000010n32;    # ext[1] holds leeway for power aware timers 
NOTE_CRITICAL:                      0x00000020n32;    # system does minimal timer coalescing 
NOTE_BACKGROUND:                    0x00000040n32;    # system does maximum timer coalescing 
NOTE_MACH_CONTINUOUS_TIME:          0x00000080n32;
NOTE_MACHTIME:                      0x00000100n32;    # data is mach absolute time units 
NOTE_TRACK:                         0x00000001n32;    # follow across forks 
NOTE_TRACKERR:                      0x00000002n32;    # could not track child 
NOTE_CHILD:                         0x00000004n32;    # am a child process 

{} Int32 {convention: cdecl;} "kqueue" importFunction

{
  kq:           Int32;
  changelist:   struct_kevent Cref;
  nchanges:     Int32;
  eventlist:    struct_kevent Ref;
  nevents:      Int32;
  timeout:      timespec Cref;
} Int32 {convention: cdecl;} "kevent" importFunction

# Mimic: int kevent64(int kq, const struct kevent64_s *changelist, int nchanges, struct kevent64_s *eventlist, int nevents, unsigned int flags, const struct timespec *timeout);
{
  kq:           Int32;
  changelist:   struct_kevent64_s Cref;
  nchanges:     Int32;
  eventlist:    struct_kevent64_s Ref;
  nevents:      Int32;
  flags:        Nat32;
  timeout:      timespec Cref;
} Int32 {convention: cdecl;} "kevent64" importFunction

Natx storageSize 8nx = [ # __x86_64__
  struct_kevent: @struct_kevent64_s;
  EV_SET: @EV_SET64;
  kevent: @kevent64;
] [] uif
