asyncRead: [
  bufLength: buffer: fd:;;;
  readBytes: -1ix;
  error: 0ix;
  (
    [
      error 0ix =
    ] [
      fiberPair: FiberPair;
      @currentFiber @fiberPair.!readFiber

      readEvent: epoll_event;
      EPOLLIN EPOLLONESHOT or @readEvent.!events
      fiberPair storageAddress @readEvent.ptr set
      @readEvent fd EPOLL_CTL_ADD epoll_fd epoll_ctl -1 = [
        -1ix !error
      ] when
    ] [
      context: {
        fiber: @currentFiber;
        error: @error;
        fd: fd new;
      };
      Context: @context Ref virtual;
      context storageAddress [
        context: @Context addressToReference;
        epoll_event context.fd EPOLL_CTL_MOD epoll_fd epoll_ctl -1 = [
          -1ix @context.@error set
        ] when
        @context.@fiber @resumingFibers.append
      ] @currentFiber.setFunc
      dispatch
      canceled? [-1ix !error] when
    ] [
      @defaultCancelFunc @currentFiber.!func
      bufLength buffer fd read !readBytes
      readBytes -1ix = [
        -1ix !error
      ] when
    ]
  ) sequence
  error -1ix = [-1ix !readBytes] when
  @readBytes
];

