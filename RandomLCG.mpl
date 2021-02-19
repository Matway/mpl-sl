# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

RandomLCG: [{
  seed: 0n32;
  nextSeed: [seed 0x8088405n32 * 1n32 + @seed set seed new];
  getr32: [nextSeed 0.0r32 cast 1.0r32 65536.0r32 / 65536.0r32 / * ];
  getn32: [0n64 cast nextSeed 0n64 cast * 32n64 rshift 0n32 cast];
  geti32: [0n64 cast nextSeed 0n64 cast * 32n64 rshift 0i32 cast];
}];
