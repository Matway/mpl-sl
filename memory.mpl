"memory" module
"control" includeModule

{size: Natx;} Natx            {convention: cdecl;} "malloc"  importFunction
{ptr: Natx; size: Natx;} Natx {convention: cdecl;} "realloc" importFunction
{ptr: Natx;} ()               {convention: cdecl;} "free"    importFunction

{dst: Natx; src: Natx; num: Natx;} Natx          {convention: cdecl;} "memcpy"  importFunction
{dst: Natx; src: Natx; num: Natx;} Natx          {convention: cdecl;} "memmove" importFunction
{memptr1: Natx; memptr2: Natx; num: Natx;} Int32 {convention: cdecl;} "memcmp"  importFunction
{dst: Natx; value: Int32; num: Natx;} Natx       {convention: cdecl;} "memset"  importFunction

getHeapUsedSize: [arg:; 0nx];
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

new: [
  elementIsMoved: isMoved;
  element:;
  result: element storageSize mplMalloc @element addressToReference;
  @result manuallyInitVariable
  @element elementIsMoved moveIf @result set
  @result
];

delete: [
  element:;
  @element manuallyDestroyVariable
  @element storageAddress mplFree
];

deleteWith: [
  destructor:;
  element:;
  @element @destructor call
  @element storageAddress mplFree
];

debugMemory: [FALSE];
debugMemory: [DEBUG_MEMORY][TRUE] pfunc;

debugMemory [
  memoryCounterMalloc: 0 dynamic;
  memoryCounterFree: 0 dynamic;
  memoryUsed: 0nx dynamic;
  memoryXor: 0nx dynamic;

  mplMalloc:  [
    copy size:;
    memoryCounterMalloc 1 + @memoryCounterMalloc set

    result: size 8nx + malloc;
    size result Natx addressToReference set

    memoryUsed size + @memoryUsed set
    memoryXor result xor @memoryXor set
    result 8nx +
  ];

  mplRealloc: [
    copy ptr:;
    copy size:;

    oldSize: ptr 0nx = [
      0nx
    ] [
      ptr 8nx - @ptr set
      ptr Natx addressToReference copy
    ] if;

    memoryXor ptr xor @memoryXor set
    ptr 0nx = [
      memoryCounterMalloc 1 + @memoryCounterMalloc set
    ] when

    result: size 8nx + ptr realloc;
    size result Natx addressToReference set

    memoryUsed oldSize - size + @memoryUsed set
    memoryXor result xor @memoryXor set
    result 8nx +
  ];

  mplFree: [
    copy ptr:;
    oldSize: ptr 0nx = [
      0nx
    ] [
      ptr 8nx - @ptr set
      ptr Natx addressToReference copy
    ] if;

    ptr 0nx = not [
      memoryCounterFree 1 + @memoryCounterFree set
    ] when

    memoryUsed oldSize - @memoryUsed set
    memoryXor ptr xor @memoryXor set
    ptr free
  ];
] [
  mplMalloc: [malloc];
  mplRealloc: [realloc];
  mplFree: [free];
] uif
