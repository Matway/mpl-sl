"file" module
"control" includeModule
"String" includeModule

{filename: 0nx; mode: 0nx;} 0nx                               {convention: cdecl;} "fopen" importFunction
{buffer: 0nx; sizeOfElement: 0nx; count: 0nx; file: 0nx;} 0nx {convention: cdecl;} "fread" importFunction
{buffer: 0nx; sizeOfElement: 0nx; count: 0nx; file: 0nx;} 0nx {convention: cdecl;} "fwrite" importFunction
{file: 0nx;} 0                                                {convention: cdecl;} "fflush" importFunction
{file: 0nx;} 0                                                {convention: cdecl;} "fclose" importFunction
{file: 0nx; offset: 0; origin: 0;} 0                          {convention: cdecl;} "fseek" importFunction
{file: 0nx;} 0nx                                              {convention: cdecl;} "ftell" importFunction

SEEK_SET: [0i32] func;
SEEK_CUR: [1i32] func;
SEEK_END: [2i32] func;

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
] func;

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
] func;

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
] func;
