"memory" module
"control" includeModule

{size: Natx;} Natx            {convention: cdecl;} "malloc"  importFunction
{ptr: Natx; size: Natx;} Natx {convention: cdecl;} "realloc" importFunction
{ptr: Natx;} ()               {convention: cdecl;} "free"    importFunction

{dst: Natx; src: Natx; num: Natx;} Natx          {convention: cdecl;} "memcpy"  importFunction
{dst: Natx; src: Natx; num: Natx;} Natx          {convention: cdecl;} "memmove" importFunction
{memptr1: Natx; memptr2: Natx; num: Natx;} Int32 {convention: cdecl;} "memcmp"  importFunction
{dst: Natx; value: Int32; num: Natx;} Natx       {convention: cdecl;} "memset"  importFunction


IntrusiveListNode: [{
  nextAddress: 0nx;
}];

SL_MEMORY_MAX_CACHED_SIZE: [0x40000nx];
SL_MEMORY_MAX_CACHED_SIZE: [SL_MEMORY_MAX_CACHED_SIZE_OPTION TRUE] [SL_MEMORY_MAX_CACHED_SIZE_OPTION] pfunc;

localStorage: 0nx SL_MEMORY_MAX_CACHED_SIZE 1nx + Int32 cast array;

{size: Natx;} Natx {} [
  copy size:;
  size 0nx = [
    0nx
  ] [
    size Natx storageSize max copy !size
    node: IntrusiveListNode Ref;
    size SL_MEMORY_MAX_CACHED_SIZE > [size Int32 cast localStorage @ 0nx =] || [
      size malloc IntrusiveListNode addressToReference !node
    ] [
      size Int32 cast @localStorage @ IntrusiveListNode addressToReference !node
      @node.nextAddress size Int32 cast @localStorage @ set
    ] if

    node storageAddress
  ] if
] "fastAllocate" exportFunction

{ptr: Natx; size: Natx;} {} {} [
  copy ptr:;
  copy size:;
  ptr 0nx = ~ [
    size SL_MEMORY_MAX_CACHED_SIZE > [
      ptr free
    ] [
      size copy Natx storageSize max copy !size
      node: ptr IntrusiveListNode addressToReference;
      size Int32 cast localStorage @ @node.@nextAddress set
      @node storageAddress size Int32 cast @localStorage @ set
    ] if
  ] when
] "fastDeallocate" exportFunction

{ptr: Natx; oldSize: Natx; newSize: Natx;} Natx {} [
  copy ptr:;
  copy oldSize:;
  copy newSize:;

  oldSize SL_MEMORY_MAX_CACHED_SIZE > [
    newSize 0nx = ~ [
      newSize ptr realloc
    ] [
      ptr free
      0nx
    ] if
  ] [
    dest: newSize fastAllocate;
    ptr 0nx = [oldSize 0nx =] || ~ [
      num: newSize oldSize min copy;
      num ptr dest memcpy drop
      node: ptr IntrusiveListNode addressToReference;
      oldSizeIndex: oldSize Natx storageSize max Int32 cast;
      oldSizeIndex @localStorage @ @node.@nextAddress set
      @node storageAddress oldSizeIndex @localStorage @ set
    ] if

    dest
  ] if
] "fastReallocate" exportFunction

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
  @element storageSize @element storageAddress mplFree
];

deleteWith: [
  destructor:;
  element:;
  @element @destructor call @element storageAddress mplFree
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
    drop
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
    drop
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
  mplMalloc: [fastAllocate];
  mplRealloc: [fastReallocate];
  mplFree: [fastDeallocate];
] uif
