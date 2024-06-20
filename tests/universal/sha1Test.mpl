# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"         use
"Span.toSpan"         use
"algorithm.="         use
"algorithm.each"      use
"algorithm.map"       use
"control.&&"          use
"control.Nat8"        use
"control.compilable?" use
"control.dup"         use
"control.ensure"      use
"control.keep"        use
"control.print"       use
"control.swap"        use
"control.when"        use

"sha1" use

sha1Test: [];

# sha1, ShaCounter
[
  check: [
    value0: value1: [Nat8 cast] [Nat8] map; toSpan dynamic;
    counter: ShaCounter;
    [value0 [(new) @counter.append] each @counter.finish value1 =] "[ShaCounter] produced wrong result" ensure
    [value0 ShaCounter [.append] keep            .finish value1 =] "[ShaCounter] produced wrong result" ensure
    [value0 sha1                                         value1 =]       "[sha1] produced wrong result" ensure
  ];

  # https://www.nist.gov/itl/ssd/software-quality-group/nsrl-test-data
  ""                                                                                                                 (0xDA 0x39 0xA3 0xEE 0x5E 0x6B 0x4B 0x0D 0x32 0x55 0xBF 0xEF 0x95 0x60 0x18 0x90 0xAF 0xD8 0x07 0x09) check
  "abc"                                                                                                              (0xA9 0x99 0x3E 0x36 0x47 0x06 0x81 0x6A 0xBA 0x3E 0x25 0x71 0x78 0x50 0xC2 0x6C 0x9C 0xD0 0xD8 0x9D) check
  "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"                                                         (0x84 0x98 0x3E 0x44 0x1C 0x3B 0xD2 0x6E 0xBA 0xAE 0x4A 0xA1 0xF9 0x51 0x29 0xE5 0xE5 0x46 0x70 0xF1) check
  "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu" (0xA4 0x9B 0x24 0x46 0xA0 0x2C 0x64 0x5B 0xF4 0x19 0xF9 0x95 0xB6 0x70 0x91 0x25 0x3A 0x04 0xA2 0x59) check
  1000000 Nat8 Array [.enlarge] keep dup [0x61n8 swap set] each                                                      (0x34 0xAA 0x97 0x3C 0xD4 0xC4 0xDA 0xA4 0xF6 0x1E 0xEB 0x2B 0xDB 0xAD 0x27 0x31 0x65 0x34 0x01 0x6F) check
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["sha1Test passed\n" print] when
