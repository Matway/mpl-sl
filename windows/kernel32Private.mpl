"kernel32Private" module
"control" useModule

FARPROC: [{
} Intx {convention: stdcall;} codeRef] func;

LPTHREAD_START_ROUTINE: [{
  lpThreadParameter: Natx;
} Nat32 {convention: stdcall;} codeRef] func;

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
} Int32 {convention: stdcall;} "CancelIoEx" importFunction

{
  hObject: Natx;
} Int32 {convention: stdcall;} "CloseHandle" importFunction

{
  FileHandle: Natx;
  ExistingCompletionPort: Natx;
  CompletionKey: Natx;
  NumberOfConcurrentThreads: Nat32;
} Natx {convention: stdcall;} "CreateIoCompletionPort" importFunction

{
  lpThreadAttributes: SECURITY_ATTRIBUTES Ref;
  dwStackSize: Natx;
  lpStartAddress: LPTHREAD_START_ROUTINE;
  lpParameter: Natx;
  dwCreationFlags: Nat32;
  lpThreadId: Nat32 Ref;
} Natx {convention: stdcall;} "CreateThread" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
} {} {convention: stdcall;} "EnterCriticalSection" importFunction

{
  hThread: Natx;
  lpExitCode: Nat32 Ref;
} Int32 {convention: stdcall;} "GetExitCodeThread" importFunction

{
} Nat32 {convention: stdcall;} "GetLastError" importFunction

{
  lpModuleName: Natx;
} HMODULE {convention: stdcall;} "GetModuleHandleW" importFunction

{
  hFile: Natx;
  lpOverlapped: OVERLAPPED Ref;
  lpNumberOfBytesTransferred: Nat32 Ref;
  bWait: Int32;
} Int32 {convention: stdcall;} "GetOverlappedResult" importFunction

{
  hModule: HMODULE;
  lpProcName: Natx;
} FARPROC {convention: stdcall;} "GetProcAddress" importFunction

{
  CompletionPort: Natx;
  lpNumberOfBytesTransferred: Nat32 Ref;
  lpCompletionKey: Natx Ref;
  lpOverlapped: (OVERLAPPED Ref) Ref;
  dwMilliseconds: Nat32;
} Int32 {convention: stdcall;} "GetQueuedCompletionStatus" importFunction

{
  CompletionPort: Natx;
  lpCompletionPortEntries: OVERLAPPED_ENTRY Ref;
  ulCount: Nat32;
  ulNumEntriesRemoved: Nat32 Ref;
  dwMilliseconds: Nat32;
  fAlertable: Int32;
} Int32 {convention: stdcall;} "GetQueuedCompletionStatusEx" importFunction

{
} Nat32 {convention: stdcall;} "GetTickCount64" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
  dwSpinCount: Nat32;
} Int32 {convention: stdcall;} "InitializeCriticalSectionAndSpinCount" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
} {} {convention: stdcall;} "LeaveCriticalSection" importFunction

{
  CodePage: Nat32;
  dwFlags: Nat32;
  lpMultiByteStr: Natx;
  cbMultiByte: Int32;
  lpWideCharStr: Natx;
  cchWideChar: Int32;
} Int32 {convention: stdcall;} "MultiByteToWideChar" importFunction

{
  CompletionPort: Natx;
  dwNumberOfBytesTransferred: Nat32;
  dwCompletionKey: Natx;
  lpOverlapped: OVERLAPPED Ref;
} Int32 {convention: stdcall;} "PostQueuedCompletionStatus" importFunction

{
  lpPerformanceCount: Int64 Ref;
} Int32 {convention: stdcall;} "QueryPerformanceCounter" importFunction

{
  lpFrequency: Int64 Ref;
} Int32 {convention: stdcall;} "QueryPerformanceFrequency" importFunction

{
  dwMilliseconds: Nat32;
} {} {convention: stdcall;} "Sleep" importFunction

{
  hHandle: Natx;
  dwMilliseconds: Nat32;
} Nat32 {convention: stdcall;} "WaitForSingleObject" importFunction
