"kernel32" module
"control" includeModule
"kernel32Private" useModule

kernel32: {
  LPTHREAD_START_ROUTINE: @LPTHREAD_START_ROUTINE;

  HINSTANCE: @HINSTANCE;
  HMODULE: @HMODULE;

  WAIT_OBJECT_0: [0n32] func;
  WAIT_TIMEOUT: [258n32] func;
  ERROR_OPERATION_ABORTED: [995n32] func;
  ERROR_NOT_FOUND: [1168n32] func;

  INFINITE: [0xFFFFFFFFn32] func;

  INVALID_HANDLE_VALUE: [0nx 1nx -] func;

  CRITICAL_SECTION: @CRITICAL_SECTION;
  OVERLAPPED: @OVERLAPPED;
  OVERLAPPED_ENTRY: @OVERLAPPED_ENTRY;
  SECURITY_ATTRIBUTES: @SECURITY_ATTRIBUTES;

  # kernel32.Lib should be included for these functions
  CancelIoEx: @CancelIoEx;
  CloseHandle: @CloseHandle;
  CreateIoCompletionPort: @CreateIoCompletionPort;
  CreateThread: @CreateThread;
  EnterCriticalSection: @EnterCriticalSection;
  GetExitCodeThread: @GetExitCodeThread;
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
  Sleep: @Sleep;
  WaitForSingleObject: @WaitForSingleObject;
};
