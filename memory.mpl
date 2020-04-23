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

haveSLMemoryMaxCachedSize: [FALSE];
haveSLMemoryMaxCachedSize: [SL_MEMORY_MAX_CACHED_SIZE TRUE] [TRUE] pfunc;
haveSLMemoryMaxCachedSize ~ [
  SL_MEMORY_MAX_CACHED_SIZE: [0x40000nx];
] [] uif

localStorage: SL_MEMORY_MAX_CACHED_SIZE 1nx + Natx storageSize * malloc;
localStorage 0nx = ["memory.mpl, error while initializing allocator: malloc returned 0" failProc] when

SL_MEMORY_MAX_CACHED_SIZE 1nx + Natx storageSize * 0 localStorage memset drop

atLocalStorage: [Natx storageSize * localStorage + Natx addressToReference];

{size: Natx;} Natx {} [
  copy size:;
  size 0nx = [
    0nx
  ] [
    size Natx storageSize max copy !size
    node: IntrusiveListNode Ref;
    size SL_MEMORY_MAX_CACHED_SIZE > [size atLocalStorage 0nx =] || [
      size malloc IntrusiveListNode addressToReference !node
    ] [
      size atLocalStorage IntrusiveListNode addressToReference !node
      @node.nextAddress size atLocalStorage set
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
      size atLocalStorage @node.@nextAddress set
      @node storageAddress size atLocalStorage set
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
      oldSizeIndex: oldSize Natx storageSize max;
      oldSizeIndex atLocalStorage @node.@nextAddress set
      @node storageAddress oldSizeIndex atLocalStorage set
    ] when

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
  memoryCurrentAllocationCount: 0n64;
  memoryTotalAllocationCount: 0n64;
  memoryCurrentAllocationSize: 0n64;
  memoryTotalAllocationSize: 0n64;
  memoryMaxAllocationSize: 0n64;
  memoryChecksum: 0nx;

  {size: Natx;} Natx {} [
    size:;
    result: size fastAllocate;
    memoryCurrentAllocationCount 1n64 + !memoryCurrentAllocationCount
    memoryTotalAllocationCount 1n64 + !memoryTotalAllocationCount
    memoryCurrentAllocationSize size Nat64 cast + !memoryCurrentAllocationSize
    memoryTotalAllocationSize size Nat64 cast + !memoryTotalAllocationSize
    memoryMaxAllocationSize memoryCurrentAllocationSize max copy !memoryMaxAllocationSize
    memoryChecksum result xor !memoryChecksum
    result
  ] "mplMalloc" exportFunction

  {ptr: Natx; oldSize: Natx; newSize: Natx;} Natx {} [
    newSize: oldSize: data:;;;
    data 0nx = [
      newSize mplMalloc
    ] [
      result: newSize oldSize data fastReallocate;
      memoryCurrentAllocationSize newSize Nat64 cast + oldSize Nat64 cast - !memoryCurrentAllocationSize
      result data = [
        memoryMaxAllocationSize memoryCurrentAllocationSize max copy !memoryMaxAllocationSize
      ] [
        memoryTotalAllocationCount 1n64 + !memoryTotalAllocationCount
        memoryTotalAllocationSize newSize Nat64 cast + !memoryTotalAllocationSize
        memoryMaxAllocationSize memoryCurrentAllocationSize oldSize Nat64 cast + max copy !memoryMaxAllocationSize
        memoryChecksum result xor data xor !memoryChecksum
      ] if

      result
    ] if
  ] "mplRealloc" exportFunction

  {ptr: Natx; size: Natx;} {} {} [
    size: data:;;
    data 0nx = ~ [
      size data fastDeallocate
      memoryCurrentAllocationCount 1n64 - !memoryCurrentAllocationCount
      memoryCurrentAllocationSize size Nat64 cast - !memoryCurrentAllocationSize
      memoryChecksum data xor !memoryChecksum
    ] when
  ] "mplFree" exportFunction
] [
  mplMalloc: [fastAllocate];
  mplRealloc: [fastReallocate];
  mplFree: [fastDeallocate];
] uif
