"kernel32Private" module
"control" useModule

FARPROC: [{
} Intx {} codeRef] func;

LPTHREAD_START_ROUTINE: [{
  lpThreadParameter: Natx;
} Nat32 {} codeRef] func;

HINSTANCE: [{
  virtual INSTANCE: {};
  unused: Int32;
} Cref] func;

HMODULE: [HINSTANCE] func;

CRITICAL_SECTION: [{
  DebugInfo: Natx;
  LockCount: Int32;
  RecursionCount: Int32;
  OwningThread: Natx;
  LockSemaphore: Natx;
  SpinCount: Natx;
}] func;

OVERLAPPED: [{
  Internal: Natx;
  InternalHigh: Natx;
  DUMMYUNIONNAME: Nat64;
  hEvent: Natx;
}] func;

OVERLAPPED_ENTRY: [{
  lpCompletionKey: Natx;
  lpOverlapped: OVERLAPPED Ref;
  Internal: Natx;
  dwNumberOfBytesTransferred: Nat32;
}] func;

SECURITY_ATTRIBUTES: [{
  nLength: Nat32;
  lpSecurityDescriptor: Natx;
  bInheritHandle: Int32;
}] func;

{
  hFile: Natx;
  lpOverlapped: OVERLAPPED Ref;
} Int32 {} "CancelIoEx" importFunction

{
  hObject: Natx;
} Int32 {} "CloseHandle" importFunction

{
  FileHandle: Natx;
  ExistingCompletionPort: Natx;
  CompletionKey: Natx;
  NumberOfConcurrentThreads: Nat32;
} Natx {} "CreateIoCompletionPort" importFunction

{
  lpThreadAttributes: SECURITY_ATTRIBUTES Ref;
  dwStackSize: Natx;
  lpStartAddress: LPTHREAD_START_ROUTINE;
  lpParameter: Natx;
  dwCreationFlags: Nat32;
  lpThreadId: Nat32 Ref;
} Natx {} "CreateThread" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
} {} {} "EnterCriticalSection" importFunction

{
  hThread: Natx;
  lpExitCode: Nat32 Ref;
} Int32 {} "GetExitCodeThread" importFunction

{
} Nat32 {} "GetLastError" importFunction

{
  lpModuleName: Natx;
} HMODULE {} "GetModuleHandleW" importFunction

{
  hFile: Natx;
  lpOverlapped: OVERLAPPED Ref;
  lpNumberOfBytesTransferred: Nat32 Ref;
  bWait: Int32;
} Int32 {} "GetOverlappedResult" importFunction

{
  hModule: HMODULE;
  lpProcName: Natx;
} FARPROC {} "GetProcAddress" importFunction

{
  CompletionPort: Natx;
  lpNumberOfBytesTransferred: Nat32 Ref;
  lpCompletionKey: Natx Ref;
  lpOverlapped: (OVERLAPPED Ref) Ref;
  dwMilliseconds: Nat32;
} Int32 {} "GetQueuedCompletionStatus" importFunction

{
  CompletionPort: Natx;
  lpCompletionPortEntries: OVERLAPPED_ENTRY Ref;
  ulCount: Nat32;
  ulNumEntriesRemoved: Nat32 Ref;
  dwMilliseconds: Nat32;
  fAlertable: Int32;
} Int32 {} "GetQueuedCompletionStatusEx" importFunction

{
} Nat32 {} "GetTickCount64" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
  dwSpinCount: Nat32;
} Int32 {} "InitializeCriticalSectionAndSpinCount" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
} {} {} "LeaveCriticalSection" importFunction

{
  CodePage: Nat32;
  dwFlags: Nat32;
  lpMultiByteStr: Natx;
  cbMultiByte: Int32;
  lpWideCharStr: Natx;
  cchWideChar: Int32;
} Int32 {} "MultiByteToWideChar" importFunction

{
  CompletionPort: Natx;
  dwNumberOfBytesTransferred: Nat32;
  dwCompletionKey: Natx;
  lpOverlapped: OVERLAPPED Ref;
} Int32 {} "PostQueuedCompletionStatus" importFunction

{
  lpPerformanceCount: Int64 Ref;
} Int32 {} "QueryPerformanceCounter" importFunction

{
  lpFrequency: Int64 Ref;
} Int32 {} "QueryPerformanceFrequency" importFunction

{
  dwMilliseconds: Nat32;
} {} {} "Sleep" importFunction

{
  hHandle: Natx;
  dwMilliseconds: Nat32;
} Nat32 {} "WaitForSingleObject" importFunction
