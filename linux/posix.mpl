# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32" use
"control.Intx"  use
"control.Natx"  use

CLOCK_MONOTONIC: [1];

EAGAIN:      [11];
EINPROGRESS: [115];
EINTR:       [4];
EWOULDBLOCK: [EAGAIN];

FD_CLOEXEC: [1];

F_SETFD: [2];

WNOHANG: [1];

O_NONBLOCK: [2048];

_SIGSET_NWORDS: [1024 Natx storageSize Int32 cast 8 * /];
sigset_t:       [Natx _SIGSET_NWORDS array];
