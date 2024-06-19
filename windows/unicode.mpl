# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"           use
"String.makeStringView" use
"control.Nat16"         use
"control.assert"        use
"control.keep"          use
"control.swap"          use

"kernel32.CP_UTF8"              use
"kernel32.MB_ERR_INVALID_CHARS" use
"kernel32.MultiByteToWideChar"  use

utf16: [
  source: makeStringView;
  targetNat16Count:
    0
    0nx
    source.size
    source.data storageAddress
    MB_ERR_INVALID_CHARS
    CP_UTF8
    MultiByteToWideChar;
  [targetNat16Count 0 = ~] "MultiByteToWideChar failed" assert

  result: targetNat16Count 1 + Nat16 Array [.enlarge] keep;

  writtenNat16Count:
    targetNat16Count new
    result.data storageAddress
    source.size
    source.data storageAddress
    MB_ERR_INVALID_CHARS
    CP_UTF8
    MultiByteToWideChar;
  [writtenNat16Count targetNat16Count =] "MultiByteToWideChar failed" assert

  0n16 @result.last set

  @result
];
