# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.assembleString" use
"String.printList"      use
"control.&&"            use
"control.Intx"          use
"control.Nat32"         use
"control.Real64"        use
"control.Ref"           use
"control.assert"        use
"control.failProc"      use
"control.when"          use

"posix.itimerspec" use

"errno.errno"           use
"linux.EPOLLIN"         use
"linux.EPOLLONESHOT"    use
"linux.EPOLL_CTL_MOD"   use
"linux.epoll_ctl"       use
"linux.epoll_event"     use
"linux.timerfd_settime" use

"TcpAcceptor.makeTcpAcceptor"     use
"TcpConnection.makeTcpConnection" use
"sync/Context.makeContext"        use
"syncPrivate.FiberData"           use
"syncPrivate.FiberPair"           use
"syncPrivate.currentFiber"        use
"syncPrivate.defaultCancelFunc"   use
"syncPrivate.dispatch"            use
"syncPrivate.epoll_fd"            use
"syncPrivate.getTimerFd"          use
"syncPrivate.resumingFibers"      use
"syncPrivate.timers"              use
"runningTime.runningTime"         use

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
  duration:;

  SECONDS_TO_NANOSECONDS_MULTIPLIER: [1000000000.0r64];

  seconds:     duration Intx cast;
  nanoseconds: duration seconds Real64 cast - SECONDS_TO_NANOSECONDS_MULTIPLIER * Intx cast;
  canceled? ~ [
    seconds 0ix = [nanoseconds 0ix =] && [yield] [
      [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert

      expirationTime: itimerspec;
      0ix             @expirationTime.@it_interval.!tv_sec
      0ix             @expirationTime.@it_interval.!tv_nsec
      seconds     new @expirationTime.@it_value   .!tv_sec
      nanoseconds new @expirationTime.@it_value   .!tv_nsec

      timer_fd: getTimerFd;
      itimerspec Ref @expirationTime 0 timer_fd timerfd_settime -1 = [("FATAL: timerfd_settime failed, result=" errno LF) printList "" failProc] when

      fiberPair: FiberPair;
      FiberData Ref @fiberPair.!writeFiber
      @currentFiber @fiberPair.!readFiber

      timerEvent: epoll_event;
      EPOLLIN EPOLLONESHOT or  @timerEvent.!events
      fiberPair storageAddress @timerEvent.ptr set

      @timerEvent timer_fd EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("FATAL: epoll_ctl failed, result=" errno LF) printList "" failProc] when

      context: {
        fiber:    @currentFiber;
        timer_fd: timer_fd new;
      };

      ContextType: @context Ref virtual;
      context storageAddress [
        context: @ContextType addressToReference;

        epoll_event context.timer_fd EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [("FATAL: epoll_ctl failed, result=" errno LF) printList "" failProc] when

        @context.@fiber @resumingFibers.append
      ] @currentFiber.setFunc

      dispatch

      canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
      timer_fd @timers.append
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
