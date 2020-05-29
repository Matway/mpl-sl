"Array.Array" use
"String.String" use
"String.assembleString" use
"String.makeStringView" use
"String.makeStringViewByAddress" use
"String.toString" use
"control.&&" use
"control.Int32" use
"control.Natx" use
"control.Ref" use
"control.Text" use
"control.||" use
"conventions.cdecl" use

{stream: Natx;} Int32                                       {convention: cdecl;} "fclose"   importFunction
{stream: Natx;} Int32                                       {convention: cdecl;} "ferror"   importFunction
{stream: Natx;} Int32                                       {convention: cdecl;} "fflush"   importFunction
{filename: Text; mode: Text;} Natx                          {convention: cdecl;} "fopen"    importFunction
{streamptr: Natx Ref; filename: Text; mode: Text;} Int32    {convention: cdecl;} "fopen_s"  importFunction
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
  name: toString;
  result: {
    result: String;
    data: Nat8 Array;
  };

  file: Natx;
  error: Int32;
  () (
    [
      drop
      "rb\00" name.data Text addressToReference @file fopen_s !error error 0 = ~
    ] [("fopen failed, " error getErrnoText) assembleString @result.!result]
    [
      drop
      SEEK_END 0 file fseek drop
      size: file ftell Natx cast;
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
  data: name: toString;;
  file: Natx;
  error: Int32;
  () (
    [
      drop
      "wb\00" name.data Text addressToReference @file fopen_s !error error 0 = ~
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
  name: toString;
  result: {
    success: TRUE;
    data: String;
  };

  size: 0nx dynamic;
  f: "rb\00" name.data Text addressToReference fopen;
  f 0nx = ~ [
    SEEK_END 0 f fseek 0 =
    [f ftell Natx cast @size set
      SEEK_SET 0 f fseek 0 =] &&
    [size 0ix cast 0 cast @result.@data.@chars.resize
      f size 1nx @result.@data.data fread size =] &&
    [0n8 @result.@data.@chars.pushBack TRUE] &&
    f fclose 0 = and
  ] &&

  @result.@success set
  result
];

saveString: [
  stringView: makeStringView;
  name: toString;

  size: stringView.size;

  f: "wb\00" name.data Text addressToReference fopen;
  f 0nx = ~
  [
    size 0 = [f size Natx cast 1nx stringView.data fwrite size Natx cast =] ||
    f fflush 0 = and
    f fclose 0 = and
  ] &&
];

appendString: [
  stringView: makeStringView;
  name: toString;

  size: stringView.size;

  f: "ab\00" name.data Text addressToReference fopen;
  f 0nx = ~
  [
    size 0 = [f size Natx cast 1nx stringView.data fwrite size Natx cast =] ||
    f fflush 0 = and
    f fclose 0 = and
  ] &&
];
