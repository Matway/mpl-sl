"control.Cref" use
"control.Int32" use
"control.Int64" use
"control.Intx" use
"control.Nat32" use
"control.Nat64" use
"control.Natx" use
"control.Ref" use
"conventions.stdcall" use

FARPROC: [{
} Intx {convention: stdcall;} codeRef];

LPTHREAD_START_ROUTINE: [{
  lpThreadParameter: Natx;
} Nat32 {convention: stdcall;} codeRef];

CRITICAL_SECTION: [{
  DebugInfo: Natx;
  LockCount: Int32;
  RecursionCount: Int32;
  OwningThread: Natx;
  LockSemaphore: Natx;
  SpinCount: Natx;
}];

HINSTANCE: [{
  virtual INSTANCE: {};
  unused: Int32;
} Cref];

HMODULE: [HINSTANCE];

LARGE_INTEGER: [{
  LowPart: Nat32;
  HighPart: Int32;
}];

OVERLAPPED: [{
  Internal: Natx;
  InternalHigh: Natx;
  DUMMYUNIONNAME: Nat64;
  hEvent: Natx;
}];

OVERLAPPED_ENTRY: [{
  lpCompletionKey: Natx;
  lpOverlapped: OVERLAPPED Ref;
  Internal: Natx;
  dwNumberOfBytesTransferred: Nat32;
}];

SECURITY_ATTRIBUTES: [{
  nLength: Nat32;
  lpSecurityDescriptor: Natx;
  bInheritHandle: Int32;
}];

{
  hFile: Natx;
  lpOverlapped: OVERLAPPED Ref;
} Int32 {convention: stdcall;} "CancelIoEx" importFunction

{
  hObject: Natx;
} Int32 {convention: stdcall;} "CloseHandle" importFunction

{
  lpPathName: Natx;
  lpSecurityAttributes: SECURITY_ATTRIBUTES Ref;
} Int32 {convention: stdcall;} "CreateDirectoryW" importFunction

{
  lpFileName: Natx;
  dwDesiredAccess: Nat32;
  dwShareMode: Nat32;
  lpSecurityAttributes: SECURITY_ATTRIBUTES Ref;
  dwCreationDisposition: Nat32;
  dwFlagsAndAttributes: Nat32;
  hTemplateFile: Natx;
} Natx {convention: stdcall;} "CreateFileW" importFunction

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
  lpFileName: Natx;
} Int32 {convention: stdcall;} "DeleteFileW" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
} {} {convention: stdcall;} "EnterCriticalSection" importFunction

{
  hThread: Natx;
  lpExitCode: Nat32 Ref;
} Int32 {convention: stdcall;} "GetExitCodeThread" importFunction

{
  lpFileName: Natx;
} Nat32 {convention: stdcall;} "GetFileAttributesW" importFunction

{
  hFile: Natx;
  lpFileSize: LARGE_INTEGER Ref;
} Int32 {convention: stdcall;} "GetFileSizeEx" importFunction

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
  hFile: Natx;
  lpBuffer: Natx;
  nNumberOfBytesToRead: Nat32;
  lpNumberOfBytesRead: Nat32 Ref;
  lpOverlapped: OVERLAPPED Ref;
} Int32 {convention: stdcall;} "ReadFile" importFunction

{
  dwMilliseconds: Nat32;
} {} {convention: stdcall;} "Sleep" importFunction

{
  hHandle: Natx;
  dwMilliseconds: Nat32;
} Nat32 {convention: stdcall;} "WaitForSingleObject" importFunction

{
  hFile: Natx;
  lpBuffer: Natx;
  nNumberOfBytesToWrite: Nat32;
  lpNumberOfBytesWritten: Nat32 Ref;
  lpOverlapped: OVERLAPPED Ref;
} Int32 {convention: stdcall;} "WriteFile" importFunction
