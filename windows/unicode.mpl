# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"     use
"String.toString" use
"control.Nat16"   use
"control.assert"  use

"kernel32.CP_UTF8"              use
"kernel32.MB_ERR_INVALID_CHARS" use
"kernel32.MultiByteToWideChar"  use

utf16: [
  source: toString;
  destSize:
    0
    0nx
    source.size
    source.data storageAddress
    MB_ERR_INVALID_CHARS
    CP_UTF8 MultiByteToWideChar
  ;

  [destSize 0 = ~] "MultiByteToWideChar failed" assert

  result: Nat16 Array;
  destSize @result.resize

  writtenWChars:
    destSize
    result.data storageAddress
    source.size
    source.data storageAddress
    MB_ERR_INVALID_CHARS
    CP_UTF8 MultiByteToWideChar
  ;

  [writtenWChars destSize =] "MultiByteToWideChar failed" assert

  0n16 @result.append

  result
];
