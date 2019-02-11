"kernel32" module
"control" includeModule
"kernel32Private" useModule

kernel32: {
  FARPROC: @FARPROC;

  LPTHREAD_START_ROUTINE: @LPTHREAD_START_ROUTINE;

  CREATE_NEW: [1] func;
  CREATE_ALWAYS: [2] func;
  OPEN_EXISTING: [3] func;
  OPEN_ALWAYS: [4] func;
  TRUNCATE_EXISTING: [5] func;

  ERROR_FILE_NOT_FOUND: [2n32] func;
  ERROR_PATH_NOT_FOUND: [3n32] func;
  ERROR_ALREADY_EXISTS: [183n32] func;
  ERROR_OPERATION_ABORTED: [995n32] func;
  ERROR_NOT_FOUND: [1168n32] func;

  FILE_SHARE_READ: [0x00000001] func;
  FILE_SHARE_WRITE: [0x00000002] func;
  FILE_SHARE_DELETE: [0x00000004] func;

  GENERIC_READ: [0x80000000n32] func;
  GENERIC_WRITE: [0x40000000n32] func;
  GENERIC_EXECUTE: [0x20000000n32] func;
  GENERIC_ALL: [0x10000000n32] func;

  INFINITE: [0xFFFFFFFFn32] func;

  INVALID_FILE_SIZE: [0xFFFFFFFFn32] func;
  INVALID_SET_FILE_POINTER: [0n32 1n32 -] func;
  INVALID_FILE_ATTRIBUTES: [0n32 1n32 -] func;
  INVALID_HANDLE_VALUE: [0nx 1nx -] func;

  WAIT_OBJECT_0: [0n32] func;
  WAIT_TIMEOUT: [258n32] func;

  CRITICAL_SECTION: @CRITICAL_SECTION;

  HINSTANCE: @HINSTANCE;
  HMODULE: @HMODULE;

  LARGE_INTEGER: @LARGE_INTEGER;

  OVERLAPPED: @OVERLAPPED;
  OVERLAPPED_ENTRY: @OVERLAPPED_ENTRY;

  SECURITY_ATTRIBUTES: @SECURITY_ATTRIBUTES;

  # kernel32.Lib should be included for these functions
  CancelIoEx: @CancelIoEx;
  CloseHandle: @CloseHandle;
  CreateDirectoryW: @CreateDirectoryW;
  CreateFileW: @CreateFileW;
  CreateIoCompletionPort: @CreateIoCompletionPort;
  CreateThread: @CreateThread;
  DeleteFileW: @DeleteFileW;
  EnterCriticalSection: @EnterCriticalSection;
  GetExitCodeThread: @GetExitCodeThread;
  GetFileAttributesW: @GetFileAttributesW;
  GetFileSizeEx: @GetFileSizeEx;
  GetLastError: @GetLastError;
  GetModuleHandleW: @GetModuleHandleW;
  GetOverlappedResult: @GetOverlappedResult;
  GetProcAddress: @GetProcAddress;
  GetQueuedCompletionStatus: @GetQueuedCompletionStatus;
  GetQueuedCompletionStatusEx: @GetQueuedCompletionStatusEx;
  GetTickCount64: @GetTickCount64;
  InitializeCriticalSectionAndSpinCount: @InitializeCriticalSectionAndSpinCount;
  LeaveCriticalSection: @LeaveCriticalSection;
  MultiByteToWideChar: @MultiByteToWideChar;
  PostQueuedCompletionStatus: @PostQueuedCompletionStatus;
  QueryPerformanceCounter: @QueryPerformanceCounter;
  QueryPerformanceFrequency: @QueryPerformanceFrequency;
  ReadFile: @ReadFile;
  Sleep: @Sleep;
  WaitForSingleObject: @WaitForSingleObject;
  WriteFile: @WriteFile;
};
