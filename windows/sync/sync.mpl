"String.assembleString" use
"control.when" use

"Context.makeContext" use
"TcpAcceptor.makeTcpAcceptor" use
"TcpConnection.makeTcpConnection" use
"syncPrivate.currentFiber" use
"syncPrivate.dispatch" use
"syncPrivate.resumingFibers" use

canceled?: [
  currentFiber.canceled?
];

ipv4ToString: [
  address:;
  (address 24n32 rshift "." address 16n32 rshift 255n32 and "." address 8n32 rshift 255n32 and "." address 255n32 and) assembleString
];

# Connect
# in:
#   address (Nat32) - destination IPv4 address
#   port (Nat16) - destination port
# out:
#   connection (TcpConnection) - connection
#   result (String) - empty on success, error message on failure
connectTcp: [makeTcpConnection];

# Listen for incoming connections
# in:
#   address (Nat32) - IPv4 address to listen on
#   port (Nat16) - port to listen on
# out:
#   acceptor (TcpAcceptor) - listening acceptor
#   result (String) - empty on success, error message on failure
listenTcp: [makeTcpAcceptor];

# Create and schedule a new context
# in:
#   in (Callable) - callable object to be executed in the new context
#   out (Object) - schema of the output
# out:
#   context (Context) - scheduled context
spawn: [makeContext];

yield: [
  resumingFibers.empty? ~ [
    @currentFiber @resumingFibers.append
    dispatch
  ] when
];
