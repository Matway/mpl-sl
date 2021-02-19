# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Nat32" use
"control.Nat8" use
"control.times" use
"control.when" use

murmur32Scramble: [
  k: 0xCC9E2D51n32 *;
  k 15n32 lshift k 17n32 rshift or 0x1B873593n32 *
];

murmur3_32: [
  key: size: seed:;; copy;
  h: seed copy;
  size Nat32 cast 2n32 rshift [
    h key Nat32 addressToReference murmur32Scramble xor !h
    key 4nx + !key
    h 13n32 lshift h 19n32 rshift or 5n32 * 0xE6546B64n32 + !h
  ] times

  k: 0n32;
  tail: size Nat32 cast 3n32 and;
  tail 0n32 = ~ [
    key Nat8 addressToReference Nat32 cast !k
    tail 1n32 = ~ [
      k key 1nx + Nat8 addressToReference Nat32 cast 8n32 lshift or !k
      tail 2n32 = ~ [
        k key 2nx + Nat8 addressToReference Nat32 cast 16n32 lshift or !k
      ] when
    ] when
  ] when

  h k murmur32Scramble xor size Nat32 cast xor !h
  h h 16n32 rshift xor 0x85EBCA6Bn32 * !h
  h h 13n32 rshift xor 0xC2B2AE35n32 * !h
  h h 16n32 rshift xor
];
