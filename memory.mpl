# Copyright (C) 2022 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&" use
"control.Int32" use
"control.Nat64" use
"control.Natx" use
"control.Ref" use
"control.drop" use
"control.max" use
"control.min" use
"control.pfunc" use
"control.when" use
"control.||" use
"conventions.cdecl" use
"conventions.stdcall" use

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
  size: new;
  size 0nx = [
    0nx
  ] [
    size Natx storageSize max new !size
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
  ptr: new;
  size: new;
  ptr 0nx = ~ [
    size SL_MEMORY_MAX_CACHED_SIZE > [
      ptr free
    ] [
      size new Natx storageSize max new !size
      node: ptr IntrusiveListNode addressToReference;
      size atLocalStorage @node.@nextAddress set
      @node storageAddress size atLocalStorage set
    ] if
  ] when
] "fastDeallocate" exportFunction

{ptr: Natx; oldSize: Natx; newSize: Natx;} Natx {} [
  ptr: new;
  oldSize: new;
  newSize: new;

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
      num: newSize oldSize min new;
      num ptr dest memcpy drop
      node: ptr IntrusiveListNode addressToReference;
      oldSizeIndex: oldSize Natx storageSize max;
      oldSizeIndex atLocalStorage @node.@nextAddress set
      @node storageAddress oldSizeIndex atLocalStorage set
    ] when

    dest
  ] if
] "fastReallocate" exportFunction

fieldIsRef: [index: struct: ;; FALSE];
fieldIsRef: [index: struct: newVarOfTheSameType ;; index @struct @ Ref index @struct ! TRUE] [index: struct: ;; TRUE] pfunc;
fieldIsRef: [index: struct: newVarOfTheSameType ;; index @struct @ Cref index @struct ! TRUE] [index: struct: ;; TRUE] pfunc;

getHeapUsedSize: [arg:; 0nx];

getHeapUsedSize: [isCombined] [
  arg:;
  i: 0;
  result: 0nx;
  [
    i @arg fieldCount < [
      i @arg fieldIsRef ~ [
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
