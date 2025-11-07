# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.assembleString" use
"String.printList"      use
"control.&&"            use
"control.Int32"         use
"control.Intx"          use
"control.Nat32"         use
"control.Natx"          use
"control.Real64"        use
"control.Ref"           use
"control.assert"        use
"control.failProc"      use
"control.when"          use
"control.while"         use

"posix/posix.itimerspec" use
"posix/posix.timespec"   use

"errno.errno"         use
"macos.EVFILT_TIMER"  use
"macos.EV_ADD"        use
"macos.EV_ONESHOT"    use
"macos.EV_SET"        use
"macos.NOTE_NSECONDS" use
"macos.kevent"        use
"macos.struct_kevent" use

"TcpAcceptor.makeTcpAcceptor"     use
"TcpConnection.makeTcpConnection" use
"sync/Context.makeContext"        use
"syncPrivate.FiberData"           use
"syncPrivate.FiberPair"           use
"syncPrivate.currentFiber"        use
"syncPrivate.defaultCancelFunc"   use
"syncPrivate.dispatch"            use
"syncPrivate.getTimerFd"          use
"syncPrivate.kqueue_fd"           use
"syncPrivate.resumingFibers"      use
"syncPrivate.timers"              use

# Test if current context was canceled
# in:
#   NONE
# out:
#   canceled (Cond) - TRUE if current context was canceled by calling 'cancel' or by canceling wait on the context
canceled?: [
  currentFiber.canceled?
];

# Connect to the remote peer
# in:
#   address (Nat32) - destination IPv4 address
#   port (Nat16) - destination port
# out:
#   connection (TcpConnection) - connection
#   result (String) - empty on success, error message on failure
connectTcp: [makeTcpConnection];

# Get time passed since sync subsystem was initialized, in seconds
# in:
#   NONE
# out:
#   time (Real64) - time elapsed
getTime: [
  "runningTime.runningTime" use

  runningTime.get
];

# Convert Nat32 representation of IPv4 address to String
# in:
#   address (Nat32) - IPv4 address
# out:
#   addressString (String) - String containing IPv4 address formatted, for example "192.168.100.101"
ipv4ToString: [
  address:;
  (address 24n32 rshift "." address 16n32 rshift 255n32 and "." address 8n32 rshift 255n32 and "." address 255n32 and) assembleString
];

# Listen for incoming connections
# in:
#   address (Nat32) - IPv4 address to listen on
#   port (Nat16) - port to listen on
# out:
#   acceptor (TcpAcceptor) - listening acceptor
#   result (String) - empty on success, error message on failure
listenTcp: [makeTcpAcceptor];

# Schedule current context not earlier than 'duration' seconds later
# in:
#   duration (Real64) - duration to sleep
# out:
#   NONE
sleepFor: [
  duration: Real64 cast;

  SECONDS_TO_NANOSECONDS_MULTIPLIER: [1000000000.0r64];

  canceled? ~ [
    duration 0.0r64 = [yield] [
      [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert

      expirationTime: duration SECONDS_TO_NANOSECONDS_MULTIPLIER * Int32 cast;

      timer_fd: getTimerFd;

      timerEvent: struct_kevent;

      fiberPair: FiberPair;
      FiberData Ref @fiberPair.!writeFiber
      @currentFiber @fiberPair.!readFiber

      @timerEvent timer_fd EVFILT_TIMER EV_ADD EV_ONESHOT or NOTE_NSECONDS expirationTime fiberPair storageAddress 0n64 0n64 EV_SET

      timespec Ref 0n32 0 struct_kevent Ref 1 timerEvent kqueue_fd kevent -1 = [
        ("In [sleepFor]: FATAL: kevent failed, result=" errno LF) printList "" failProc
      ] when

      context: {
        fiber:    @currentFiber;
        pair:     @fiberPair;
        timer_fd: timer_fd new;
        duration: duration new;
      };

      context storageAddress [
        context: @context addressToReference;
        event: struct_kevent;
        EVFILT_TIMER @event.@filter set
        timeout: timespec;
        context.duration Intx cast @timeout.@tv_sec set

        [event.udata Natx cast context.pair storageAddress = ~]
        [
          timeout 0n32 1 @event 1 event kqueue_fd kevent -1 = [("FATAL: [In currentFiber.func] epoll_ctl failed, result=" errno LF) printList "" failProc] when
        ] while

        @context.@fiber @resumingFibers.append
        context.timer_fd @timers.append
      ] @currentFiber.setFunc

      dispatch

      canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
    ] if
  ] when
];

# Schedule current context not earlier than 'time'
# in:
#   time (Real64) - time to wake on
# out:
#   NONE
sleepUntil: [
  time:;
  time getTime - sleepFor
];

# Create and schedule a new context
# in:
#   in (Callable) - callable object to be executed in the new context
#   out (Object) - schema of the output
# out:
#   context (Context) - scheduled context
spawn: [makeContext];

# Allow other scheduled contexts to run
# in:
#   NONE
# out:
#   NONE
yield: [
  @currentFiber @resumingFibers.append
  dispatch
];
