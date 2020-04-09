"control" includeModule
"String" includeModule

{file: Natx;} Int32                                                {convention: cdecl;} "fclose"   importFunction
{file: Natx;} Int32                                                {convention: cdecl;} "ferror"   importFunction
{file: Natx;} Int32                                                {convention: cdecl;} "fflush"   importFunction
{filename: Natx; mode: Natx;} Natx                                 {convention: cdecl;} "fopen"    importFunction
{streamptr: Natx Ref; filename: Natx; mode: Natx;} Int32           {convention: cdecl;} "fopen_s"  importFunction
{buffer: Natx; sizeOfElement: Natx; count: Natx; file: Natx;} Natx {convention: cdecl;} "fread"    importFunction
{file: Natx; offset: Int32; origin: Int32;} Int32                  {convention: cdecl;} "fseek"    importFunction
{file: Natx;} Natx                                                 {convention: cdecl;} "ftell"    importFunction
{buffer: Natx; sizeOfElement: Natx; count: Natx; file: Natx;} Natx {convention: cdecl;} "fwrite"   importFunction
{errnum: Int32;} Natx                                              {convention: cdecl;} "strerror" importFunction

SEEK_SET: [0i32];
SEEK_CUR: [1i32];
SEEK_END: [2i32];

getErrnoText: [
  strerror makeStringViewByAddress
];

loadFile: [
  name:;
  result: {
    result: String;
    data: Nat8 Array;
  };

  file: Natx;
  error: Int32;
  () (
    [
      drop
      "rb" stringMemory name stringMemory @file fopen_s !error error 0 = ~
    ] [("fopen failed, " error getErrnoText) assembleString @result.!result]
    [
      drop
      SEEK_END 0 file fseek drop
      size: file ftell;
      size Int32 cast @result.@data.resize
      SEEK_SET 0 file fseek drop
      file size 1nx result.data.getBufferBegin fread size = ~
    ] [("fread failed, " file ferror getErrnoText) assembleString @result.!result]
    [
      file fclose drop
    ]
  ) cond

  result
];

saveFile: [
  data: name:;;
  file: Natx;
  error: Int32;
  () (
    [
      drop
      "wb" stringMemory name stringMemory @file fopen_s !error error 0 = ~
    ] [("fopen failed, " error getErrnoText) assembleString]
    [
      drop
      size: data.getSize Natx cast;
      file size 1nx data.getBufferBegin fwrite size = ~
    ] [("fwrite failed, " file ferror getErrnoText) assembleString]
    [
      file fclose drop
      "" toString
    ]
  ) cond
];

loadString: [
  fileName: toString;
  result: {
    success: TRUE;
    data: String;
  };

  size: 0nx dynamic;
  f: "rb" storageAddress fileName stringMemory fopen;
  f 0nx = not [
    SEEK_END 0 f fseek 0 =
    [f ftell @size set
      SEEK_SET 0 f fseek 0 =] &&
    [size 0ix cast 0 cast @result.@data.@chars.resize
      f size 1nx @result.@data stringMemory fread size =] &&
    [0n8 @result.@data.@chars.pushBack TRUE] &&
    f fclose 0 = and
  ] &&
  @result.@success set

  result
];

saveString: [
  stringView: makeStringView;
  fileName: toString;

  size: stringView textSize;

  f: "wb" storageAddress fileName stringMemory fopen;
  f 0nx = not
  [
    size 0nx = [f size 1nx stringView stringMemory fwrite size =] ||
    f fflush 0 = and
    f fclose 0 = and
  ] &&
];

appendString: [
  stringView: makeStringView;
  fileName: toString;

  size: stringView textSize;

  f: "ab" storageAddress fileName stringMemory fopen;
  f 0nx = not
  [
    size 0nx = [f size 1nx stringView stringMemory fwrite size =] ||
    f fflush 0 = and
    f fclose 0 = and
  ] &&
];
