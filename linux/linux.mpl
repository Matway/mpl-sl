"control.Cref"      use
"control.Int32"     use
"control.Nat32"     use
"control.Nat64"     use
"control.Natx"      use
"control.Ref"       use
"control.swap"      use
"control.when"      use
"conventions.cdecl" use

"posix.itimerspec" use

# epoll

EPOLL_CTL_ADD: [1];
EPOLL_CTL_DEL: [2];
EPOLL_CTL_MOD: [3];

EPOLLIN:      [0x001n32];
EPOLLONESHOT: [1n32 30n32 lshift];
EPOLLOUT:     [0x004n32];

epoll_event: [{
  events: Nat32;
  private data: Nat32 2 array;

  ptr: [Natx  item];
  fd:  [Int32 item];
  u32: [Nat32 item];
  u64: [Nat64 item];

  private item: [
    data storageAddress swap addressToReference @self isConst [const] when
  ];
}];

{
  flags: Int32;
} Int32 {convention: cdecl;} "epoll_create1" importFunction

{
  epfd:  Int32;
  op:    Int32;
  fd:    Int32;
  event: epoll_event Ref;
} Int32 {convention: cdecl;} "epoll_ctl" importFunction

{
  epfd:      Int32;
  events:    Natx;
  maxevents: Int32;
  timeout:   Int32;
} Int32 {convention: cdecl;} "epoll_wait" importFunction

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
