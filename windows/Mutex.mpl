# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"kernel32.AcquireSRWLockExclusive"    use
"kernel32.AcquireSRWLockShared"       use
"kernel32.ReleaseSRWLockExclusive"    use
"kernel32.ReleaseSRWLockShared"       use
"kernel32.SRWLOCK"                    use
"kernel32.TryAcquireSRWLockExclusive" use
"kernel32.TryAcquireSRWLockShared"    use

Mutex: [{
  SCHEMA_NAME: "Mutex" virtual;

  DIE: [
  ];

  INIT: [
    0nx @srwLock.!Ptr
  ];

  lock: [
    @srwLock AcquireSRWLockExclusive
  ];

  lockShared: [
    @srwLock AcquireSRWLockShared
  ];

  tryLock: [
    @srwLock TryAcquireSRWLockExclusive
  ];

  tryLockShared: [
    @srwLock TryAcquireSRWLockShared
  ];

  unlock: [
    @srwLock ReleaseSRWLockExclusive
  ];

  unlockShared: [
    @srwLock ReleaseSRWLockShared
  ];

  # Private

  srwLock: SRWLOCK;
}];
