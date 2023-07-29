# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"String.assembleString" use
"control.Ref"           use
"control.assert"        use
"control.dup"           use
"control.nil?"          use
"control.when"          use

"TcpAcceptor.makeTcpAcceptor"     use
"TcpConnection.makeTcpConnection" use
"syncPrivate.TimerData"           use
"sync/Context.makeContext"        use
"syncPrivate.currentFiber"        use
"syncPrivate.defaultCancelFunc"   use
"syncPrivate.dispatch"            use
"syncPrivate.getTimePrivate"      use
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
getTime: [getTimePrivate];

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
  getTime duration + sleepUntil
];

# Schedule current context not earlier than 'time'
# in:
#   time (Real64) - time to wake on
# out:
#   NONE
sleepUntil: [
  time:;
  canceled? ~ [
    [currentFiber.@func @defaultCancelFunc is] "invalid cancelation function" assert
    data: TimerData;
    @currentFiber @data.!fiber
    time new @data.!time

    # TODO: Improve complexity, it is O(n) currently
    prev: TimerData Ref;
    item: @timers.@first;

    [
      item nil? [
        @data @timers.append
        FALSE
      ] [
        item.time data.time > ~ dup [
          @item !prev
          @item.next !item
        ] [
          @item @data.@next.set
          prev nil? [
            @data @timers.!first
          ] [
            @data @prev.@next.set
          ] if
        ] if
      ] if
    ] loop

    data storageAddress [
      data: @data addressToReference;
      # Cancelation is considered a rare operation, so O(n) complexity is not a problem here
      # It is possible that the current fiber was already removed from the linked list by dispatch
      [data is] @timers.cutIf 1 = [@data.@fiber @resumingFibers.append] when
    ] @currentFiber.setFunc

    dispatch
    canceled? ~ [@defaultCancelFunc @currentFiber.!func] when
  ] when
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
