# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

lockGuard: [{
  object:;

  DIE: [
    @object.unlock
  ];

  @object.lock
}];

lockSharedGuard: [{
  object:;

  DIE: [
    @object.unlockShared
  ];

  @object.lockShared
}];

unlockGuard: [{
  object:;

  DIE: [
    @object.lock
  ];

  @object.unlock
}];

unlockSharedGuard: [{
  object:;

  DIE: [
    @object.lockShared
  ];

  @object.unlockShared
}];
