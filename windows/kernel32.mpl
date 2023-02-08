# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"kernel32Private" use

kernel32: {
  FARPROC: @FARPROC;

  LPFIBER_START_ROUTINE:  @LPFIBER_START_ROUTINE;
  LPTHREAD_START_ROUTINE: @LPTHREAD_START_ROUTINE;

  CREATE_NEW:        [1];
  CREATE_ALWAYS:     [2];
  OPEN_EXISTING:     [3];
  OPEN_ALWAYS:       [4];
  TRUNCATE_EXISTING: [5];

  ERROR_FILE_NOT_FOUND:    [2n32];
  ERROR_PATH_NOT_FOUND:    [3n32];
  ERROR_ALREADY_EXISTS:    [183n32];
  ERROR_OPERATION_ABORTED: [995n32];
  ERROR_NOT_FOUND:         [1168n32];

  FILE_SHARE_READ:   [0x00000001];
  FILE_SHARE_WRITE:  [0x00000002];
  FILE_SHARE_DELETE: [0x00000004];

  GENERIC_READ:    [0x80000000n32];
  GENERIC_WRITE:   [0x40000000n32];
  GENERIC_EXECUTE: [0x20000000n32];
  GENERIC_ALL:     [0x10000000n32];

  INFINITE: [0xFFFFFFFFn32];

  INVALID_FILE_SIZE:        [0xFFFFFFFFn32];
  INVALID_SET_FILE_POINTER: [0n32 1n32 -];
  INVALID_FILE_ATTRIBUTES:  [0n32 1n32 -];
  INVALID_HANDLE_VALUE:     [0nx 1nx -];

  WAIT_OBJECT_0: [0n32];
  WAIT_TIMEOUT:  [258n32];

  CRITICAL_SECTION: @CRITICAL_SECTION;

  HINSTANCE: @HINSTANCE;
  HMODULE:   @HMODULE;

  LARGE_INTEGER: @LARGE_INTEGER;

  OVERLAPPED:       @OVERLAPPED;
  OVERLAPPED_ENTRY: @OVERLAPPED_ENTRY;

  SECURITY_ATTRIBUTES: @SECURITY_ATTRIBUTES;

  # kernel32.Lib should be included for these functions
  CancelIoEx:                            @CancelIoEx                            virtual;
  CloseHandle:                           @CloseHandle                           virtual;
  ConvertThreadToFiber:                  @ConvertThreadToFiber                  virtual;
  CreateDirectoryW:                      @CreateDirectoryW                      virtual;
  CreateFiber:                           @CreateFiber                           virtual;
  CreateFileW:                           @CreateFileW                           virtual;
  CreateIoCompletionPort:                @CreateIoCompletionPort                virtual;
  CreateThread:                          @CreateThread                          virtual;
  DeleteFileW:                           @DeleteFileW                           virtual;
  EnterCriticalSection:                  @EnterCriticalSection                  virtual;
  GetExitCodeThread:                     @GetExitCodeThread                     virtual;
  GetFileAttributesW:                    @GetFileAttributesW                    virtual;
  GetFileSizeEx:                         @GetFileSizeEx                         virtual;
  GetLastError:                          @GetLastError                          virtual;
  GetModuleHandleW:                      @GetModuleHandleW                      virtual;
  GetOverlappedResult:                   @GetOverlappedResult                   virtual;
  GetProcAddress:                        @GetProcAddress                        virtual;
  GetQueuedCompletionStatus:             @GetQueuedCompletionStatus             virtual;
  GetQueuedCompletionStatusEx:           @GetQueuedCompletionStatusEx           virtual;
  GetTickCount64:                        @GetTickCount64                        virtual;
  InitializeCriticalSectionAndSpinCount: @InitializeCriticalSectionAndSpinCount virtual;
  LeaveCriticalSection:                  @LeaveCriticalSection                  virtual;
  MultiByteToWideChar:                   @MultiByteToWideChar                   virtual;
  PostQueuedCompletionStatus:            @PostQueuedCompletionStatus            virtual;
  QueryPerformanceCounter:               @QueryPerformanceCounter               virtual;
  QueryPerformanceFrequency:             @QueryPerformanceFrequency             virtual;
  ReadFile:                              @ReadFile                              virtual;
  Sleep:                                 @Sleep                                 virtual;
  SwitchToFiber:                         @SwitchToFiber                         virtual;
  WaitForSingleObject:                   @WaitForSingleObject                   virtual;
  WriteFile:                             @WriteFile                             virtual;
};
