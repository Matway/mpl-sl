# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"            use
"control.Int32"         use
"control.Nat64"         use
"control.Natx"          use
"control.assert"        use
"control.drop"          use
"control.max"           use
"control.min"           use
"control.pfunc"         use
"control.when"          use
"control.||"            use
"conventions.cdecl"     use

SYNCHRONIZED: [FALSE];
SYNCHRONIZED: [SL_MEMORY_SYNCHRONIZED TRUE] [
  SL_MEMORY_SYNCHRONIZED {} same [SL_MEMORY_SYNCHRONIZED] ||
] pfunc;

SYNCHRONIZED [
  "atomic.MONOTONIC"      use
  "atomic.atomicExchange" use
  "atomic.atomicStore"    use
] [] uif

{size: Natx;} Natx            {convention: cdecl;} "malloc"  importFunction
{ptr: Natx; size: Natx;} Natx {convention: cdecl;} "realloc" importFunction
{ptr: Natx;} ()               {convention: cdecl;} "free"    importFunction

{dst: Natx; src: Natx; num: Natx;} Natx          {convention: cdecl;} "memcpy"  importFunction
{dst: Natx; src: Natx; num: Natx;} Natx          {convention: cdecl;} "memmove" importFunction
{memptr1: Natx; memptr2: Natx; num: Natx;} Int32 {convention: cdecl;} "memcmp"  importFunction
{dst: Natx; value: Int32; num: Natx;} Natx       {convention: cdecl;} "memset"  importFunction

haveSLMemoryMaxCachedSize: [FALSE];
haveSLMemoryMaxCachedSize: [SL_MEMORY_MAX_CACHED_SIZE TRUE] [TRUE] pfunc;
haveSLMemoryMaxCachedSize ~ [
  SL_MEMORY_MAX_CACHED_SIZE: [0x40000nx];
] [] uif

memoryQueues: Natx storageSize SL_MEMORY_MAX_CACHED_SIZE 1nx + * malloc;

Natx storageSize SL_MEMORY_MAX_CACHED_SIZE 1nx + * 0 memoryQueues memset drop

fastAllocate: [
  size:;
  [size 0nx = ~] "Invalid allocation size" assert
  size SL_MEMORY_MAX_CACHED_SIZE > [size malloc] [
    size: size Natx storageSize max new;
    memoryQueue: memoryQueues Natx storageSize size * + Natx addressToReference;
    head: Natx;
    SYNCHRONIZED ~ [memoryQueue new !head] [
      [
        1nx @memoryQueue MONOTONIC atomicExchange !head
        head 1nx =
      ] loop
    ] if

    head 0nx = [
      0nx @memoryQueue SYNCHRONIZED [MONOTONIC atomicStore] [set] if
      size malloc
    ] [
      head Natx addressToReference @memoryQueue SYNCHRONIZED [MONOTONIC atomicStore] [set] if
      head new
    ] if
  ] if
];

fastDeallocate: [
  size: ref:;;
  [size 0nx = ~] "Invalid allocation size" assert
  size SL_MEMORY_MAX_CACHED_SIZE > [ref free] [
    size: size Natx storageSize max new;
    memoryQueue: memoryQueues Natx storageSize size * + Natx addressToReference;
    head: Natx;
    SYNCHRONIZED ~ [memoryQueue new !head] [
      [
        1nx @memoryQueue MONOTONIC atomicExchange !head
        head 1nx =
      ] loop
    ] if

    head ref Natx addressToReference set
    ref @memoryQueue SYNCHRONIZED [MONOTONIC atomicStore] [set] if
  ] if
];

fastReallocate: [
  newSize: oldSize: ref:;;;
  [oldSize 0nx = ~] "Invalid allocation size" assert
  [newSize 0nx = ~] "Invalid allocation size" assert
  newRef: newSize fastAllocate;
  oldSize newSize min ref newRef memcpy drop
  oldSize ref fastDeallocate
  newRef
];

getHeapUsedSize: [arg:; 0nx];

getHeapUsedSize: [isCombined] [
  arg:;
  i: 0;
  result: 0nx;
  [
    i @arg fieldCount < [
      @arg i fieldIsRef ~ [
        result i @arg @ getHeapUsedSize + @result set
      ] when

      i 1 + @i set TRUE
    ] &&
  ] loop
  result
] pfunc;

debugMemory: [FALSE];
debugMemory: [DEBUG_MEMORY][TRUE] pfunc;

debugMemory [
  memoryMetrics: {
    memoryCurrentAllocationCount: 0n64;
    memoryTotalAllocationCount: 0n64;
    memoryCurrentAllocationSize: 0n64;
    memoryTotalAllocationSize: 0n64;
    memoryMaxAllocationSize: 0n64;
    memoryChecksum: 0nx;
  };

  {size: Natx;} Natx {} [
    size:;
    result: size fastAllocate;
    memoryMetrics.memoryCurrentAllocationCount 1n64 + @memoryMetrics.!memoryCurrentAllocationCount
    memoryMetrics.memoryTotalAllocationCount 1n64 + @memoryMetrics.!memoryTotalAllocationCount
    memoryMetrics.memoryCurrentAllocationSize size Nat64 cast + @memoryMetrics.!memoryCurrentAllocationSize
    memoryMetrics.memoryTotalAllocationSize size Nat64 cast + @memoryMetrics.!memoryTotalAllocationSize
    memoryMetrics.memoryMaxAllocationSize memoryMetrics.memoryCurrentAllocationSize max new @memoryMetrics.!memoryMaxAllocationSize
    memoryMetrics.memoryChecksum result xor @memoryMetrics.!memoryChecksum
    result
  ] "mplMalloc" exportFunction

  {ptr: Natx; oldSize: Natx; newSize: Natx;} Natx {} [
    newSize: oldSize: data:;;;
    data 0nx = [
      newSize mplMalloc
    ] [
      result: newSize oldSize data fastReallocate;
      memoryMetrics.memoryCurrentAllocationSize newSize Nat64 cast + oldSize Nat64 cast - @memoryMetrics.!memoryCurrentAllocationSize
      result data = [
        memoryMetrics.memoryMaxAllocationSize memoryMetrics.memoryCurrentAllocationSize max new @memoryMetrics.!memoryMaxAllocationSize
      ] [
        memoryMetrics.memoryTotalAllocationCount 1n64 + @memoryMetrics.!memoryTotalAllocationCount
        memoryMetrics.memoryTotalAllocationSize newSize Nat64 cast + @memoryMetrics.!memoryTotalAllocationSize
        memoryMetrics.memoryMaxAllocationSize memoryMetrics.memoryCurrentAllocationSize oldSize Nat64 cast + max new @memoryMetrics.!memoryMaxAllocationSize
        memoryMetrics.memoryChecksum result xor data xor @memoryMetrics.!memoryChecksum
      ] if

      result
    ] if
  ] "mplRealloc" exportFunction

  {ptr: Natx; size: Natx;} {} {} [
    size: data:;;
    data 0nx = ~ [
      size data fastDeallocate
      memoryMetrics.memoryCurrentAllocationCount 1n64 - @memoryMetrics.!memoryCurrentAllocationCount
      memoryMetrics.memoryCurrentAllocationSize size Nat64 cast - @memoryMetrics.!memoryCurrentAllocationSize
      memoryMetrics.memoryChecksum data xor @memoryMetrics.!memoryChecksum
    ] when
  ] "mplFree" exportFunction

  getMemoryMetrics: [memoryMetrics];
] [
  mplMalloc: [fastAllocate];
  mplRealloc: [fastReallocate];
  mplFree: [fastDeallocate];
] uif
