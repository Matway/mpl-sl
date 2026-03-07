# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"algorithm.="      use
"control.Ref"      use
"control.sequence" use
"control.when"     use

"posix.read" use

"errno.errno"         use
"linux.EPOLLIN"       use
"linux.EPOLLONESHOT"  use
"linux.EPOLL_CTL_ADD" use
"linux.EPOLL_CTL_MOD" use
"linux.epoll_ctl"     use
"linux.epoll_event"   use

"sync/syncPrivate.FiberPair"         use
"sync/syncPrivate.canceled?"         use
"sync/syncPrivate.currentFiber"      use
"sync/syncPrivate.defaultCancelFunc" use
"sync/syncPrivate.dispatch"          use
"sync/syncPrivate.epoll_fd"          use
"sync/syncPrivate.resumingFibers"    use

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
