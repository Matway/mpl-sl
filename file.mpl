# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array.Array"                    use
"String.String"                  use
"String.addTerminator"           use
"String.assembleString"          use
"String.makeStringView"          use
"String.makeStringViewByAddress" use
"String.toString"                use
"algorithm.cond"                 use
"control.&&"                     use
"control.Int32"                  use
"control.Nat8"                   use
"control.Natx"                   use
"control.Ref"                    use
"control.Text"                   use
"control.drop"                   use
"control.nil?"                   use
"control.||"                     use
"conventions.cdecl"              use

"errno.errno" use

{stream: Natx;} Int32                                       {convention: cdecl;} "fclose"   importFunction
{stream: Natx;} Int32                                       {convention: cdecl;} "ferror"   importFunction
{stream: Natx;} Int32                                       {convention: cdecl;} "fflush"   importFunction
{filename: Text; mode: Text;} Natx                          {convention: cdecl;} "fopen"    importFunction
{buffer: Natx; size: Natx; count: Natx; stream: Natx;} Natx {convention: cdecl;} "fread"    importFunction
{stream: Natx; offset: Int32; origin: Int32;} Int32         {convention: cdecl;} "fseek"    importFunction
{stream: Natx;} Int32                                       {convention: cdecl;} "ftell"    importFunction
{buffer: Natx; size: Natx; count: Natx; stream: Natx;} Natx {convention: cdecl;} "fwrite"   importFunction
{errnum: Int32;} Natx                                       {convention: cdecl;} "strerror" importFunction

SEEK_SET: [0i32];
SEEK_CUR: [1i32];
SEEK_END: [2i32];

getErrnoText: [
  strerror makeStringViewByAddress
];

loadFile: [
  name: addTerminator makeStringView;
  result: {
    result: String;
    data: Nat8 Array;
  };

  file: Natx;
  () (
    [
      drop
      "rb\00" name.data storageAddress Text addressToReference fopen @file set
      file Natx addressToReference nil?
    ] [("fopen failed, " errno new getErrnoText) assembleString @result.!result]
    [
      drop
      SEEK_END 0 file fseek drop
      size: file ftell Natx cast;
      size Int32 cast @result.@data.resize
      SEEK_SET 0 file fseek drop
      file size 1nx result.data.data storageAddress fread size = ~
    ] [("fread failed, " file ferror getErrnoText) assembleString @result.!result]
    [
      file fclose drop
    ]
  ) cond

  result
];

saveFile: [
  data: name: addTerminator makeStringView;;
  file: Natx;
  () (
    [
      drop
      "wb\00" name.data storageAddress Text addressToReference fopen @file set
      file Natx addressToReference nil?
    ] [("fopen failed, " errno new getErrnoText) assembleString]
    [
      drop
      size: data.size Natx cast;
      file size 1nx data.data storageAddress fwrite size = ~
    ] [("fwrite failed, " file ferror getErrnoText) assembleString]
    [
      file fclose drop
      "" toString
    ]
  ) cond
];

loadString: [
  name: addTerminator makeStringView;
  result: {
    success: TRUE;
    data: String;
  };

  size: 0nx dynamic;
  f: "rb\00" name.data storageAddress Text addressToReference fopen;
  f 0nx = ~ [
    SEEK_END 0 f fseek 0 =
    [f ftell Natx cast @size set
      SEEK_SET 0 f fseek 0 =] &&
    [size 0ix cast 0 cast @result.@data.@chars.resize
      f size 1nx @result.@data.data storageAddress fread size =] &&
    [0n8 @result.@data.@chars.append TRUE] &&
    f fclose 0 = and
  ] &&

  @result.@success set
  result
];

saveString: [
  stringView: makeStringView;
  name: addTerminator makeStringView;
  size: stringView.size;
  f: "wb\00" name.data storageAddress Text addressToReference fopen;
  f 0nx = ~
  [
    size 0 = [f size Natx cast 1nx stringView.data storageAddress fwrite size Natx cast =] ||
    f fflush 0 = and
    f fclose 0 = and
  ] &&
];

appendString: [
  stringView: makeStringView;
  name: addTerminator makeStringView;
  size: stringView.size;
  f: "ab\00" name.data storageAddress Text addressToReference fopen;
  f 0nx = ~
  [
    size 0 = [f size Natx cast 1nx stringView.data storageAddress fwrite size Natx cast =] ||
    f fflush 0 = and
    f fclose 0 = and
  ] &&
];
