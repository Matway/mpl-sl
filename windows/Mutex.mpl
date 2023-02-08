# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"kernel32.kernel32" use

Mutex: [{
  SCHEMA_NAME: "Mutex" virtual;

  DIE: [
  ];

  INIT: [
    0nx @srwLock.!Ptr
  ];

  lock: [
    @srwLock kernel32.AcquireSRWLockExclusive
  ];

  lockShared: [
    @srwLock kernel32.AcquireSRWLockShared
  ];

  tryLock: [
    @srwLock kernel32.TryAcquireSRWLockExclusive
  ];

  tryLockShared: [
    @srwLock kernel32.TryAcquireSRWLockShared
  ];

  unlock: [
    @srwLock kernel32.ReleaseSRWLockExclusive
  ];

  unlockShared: [
    @srwLock kernel32.ReleaseSRWLockShared
  ];

  # Private

  srwLock: kernel32.SRWLOCK;
}];
