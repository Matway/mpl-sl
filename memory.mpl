"memory" module
"control" includeModule

{size: Natx;} Natx {}            "malloc"  importFunction
{ptr: Natx; size: Natx;} Natx {} "realloc" importFunction
{ptr: Natx;} () {}               "free"    importFunction

{dst: Natx; src: Natx; num: Natx;} Natx {} "memcpy" importFunction
{dst: Natx; src: Natx; num: Natx;} Natx {} "memmove" importFunction
{memptr1: Natx; memptr2: Natx; num: Natx;} Int32 {} "memcmp" importFunction

getHeapUsedSize: [arg:; 0nx] func;
getHeapUsedSize: [isCombined] [
  arg:;
  i: 0;
  result: 0nx;
  [
    i arg fieldCount < [
      result i arg @ getHeapUsedSize + @result set
      i 1 + @i set TRUE
    ] &&
  ] loop
  result
] pfunc;

mplMalloc:  [malloc] func;
mplRealloc: [realloc] func;
mplFree: [free] func;

#memoryCounterMalloc: 0 dynamic;
#memoryCounterFree: 0 dynamic;
#memoryUsed: 0nx dynamic;
#memoryXor: 0nx dynamic;

#mplMalloc:  [
#  copy size:;
#  memoryCounterMalloc 1 + @memoryCounterMalloc set

#  result: size 8nx + malloc;
#  size result Natx Ref cast set

#  memoryUsed size + @memoryUsed set
#  memoryXor result xor @memoryXor set
#  result 8nx +
#] func;

#mplRealloc: [
#  copy ptr:;
#  copy size:;

#  oldSize: ptr 0nx = [
#    0nx
#  ] [
#    ptr 8nx - @ptr set
#    ptr Natx Ref cast copy
#  ] if;

#  memoryXor ptr xor @memoryXor set
#  ptr 0nx = [
#    memoryCounterMalloc 1 + @memoryCounterMalloc set
#  ] when

#  result: size 8nx + ptr realloc;
#  size result Natx Ref cast set

#  memoryUsed oldSize - size + @memoryUsed set
#  memoryXor result xor @memoryXor set
#  result 8nx +
#] func;

#mplFree: [
#  copy ptr:;
#  oldSize: ptr 0nx = [
#    0nx
#  ] [
#    ptr 8nx - @ptr set
#    ptr Natx Ref cast copy
#  ] if;

#  ptr 0nx = not [
#    memoryCounterFree 1 + @memoryCounterFree set
#  ] when

#  memoryUsed oldSize - @memoryUsed set
#  memoryXor ptr xor @memoryXor set
#  ptr free
#] func;
