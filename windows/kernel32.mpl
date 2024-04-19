# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Cond"        use
"control.Cref"        use
"control.Int32"       use
"control.Int64"       use
"control.Intx"        use
"control.Nat16"       use
"control.Nat32"       use
"control.Nat64"       use
"control.Natx"        use
"control.Ref"         use
"conventions.stdcall" use

FARPROC: [{} Intx {convention: stdcall;} codeRef];

LPFIBER_START_ROUTINE: [{
  lpFiberParameter: Natx;
} {} {convention: stdcall;} codeRef];

LPTHREAD_START_ROUTINE: [{
  lpThreadParameter: Natx;
} Nat32 {convention: stdcall;} codeRef];

CREATE_NEW:        [1];
CREATE_ALWAYS:     [2];
OPEN_EXISTING:     [3];
OPEN_ALWAYS:       [4];
TRUNCATE_EXISTING: [5];

CONDITION_VARIABLE_LOCKMODE_SHARED: [0x1n32];

CP_UTF8: [65001n32];

ERROR_ALREADY_EXISTS:    [183n32 ];
ERROR_FILE_NOT_FOUND:    [2n32   ];
ERROR_NOT_FOUND:         [1168n32];
ERROR_OPERATION_ABORTED: [995n32 ];
ERROR_PATH_NOT_FOUND:    [3n32   ];
ERROR_TIMEOUT:           [1460n32];

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

MB_ERR_INVALID_CHARS: [8n32];

STILL_ACTIVE: [259n32];

WAIT_OBJECT_0: [0n32];
WAIT_TIMEOUT:  [258n32];

CONDITION_VARIABLE: [{
  SCHEMA_NAME: "CONDITION_VARIABLE" virtual;
  Ptr:         0nx;
}];

CRITICAL_SECTION: [{
  DebugInfo:      Natx;
  LockCount:      Int32;
  RecursionCount: Int32;
  OwningThread:   Natx;
  LockSemaphore:  Natx;
  SpinCount:      Natx;
}];

HINSTANCE: [{
  virtual INSTANCE: {};
  unused: Int32;
} Cref];

HMODULE: [HINSTANCE];

LARGE_INTEGER: [{
  LowPart:  Nat32;
  HighPart: Int32;
}];

OVERLAPPED: [{
  Internal:       Natx;
  InternalHigh:   Natx;
  DUMMYUNIONNAME: Nat64;
  hEvent:         Natx;
}];

OVERLAPPED_ENTRY: [{
  lpCompletionKey:            Natx;
  lpOverlapped:               OVERLAPPED Ref;
  Internal:                   Natx;
  dwNumberOfBytesTransferred: Nat32;
}];

PROCESS_INFORMATION: [{
  hProcess:    Natx;
  hThread:     Natx;
  dwProcessId: Nat32;
  dwThreadId:  Nat32;
}];

SECURITY_ATTRIBUTES: [{
  nLength:              Nat32;
  lpSecurityDescriptor: Natx;
  bInheritHandle:       Int32;
}];

SRWLOCK: [{
  SCHEMA_NAME: "SRWLOCK" virtual;
  Ptr:         0nx;
}];

STARTUPINFOW: [{
  cb:              Nat32;
  lpReserved:      Natx;
  lpDesktop:       Natx;
  lpTitle:         Natx;
  dwX:             Nat32;
  dwY:             Nat32;
  dwXSize:         Nat32;
  dwYSize:         Nat32;
  dwXCountChars:   Nat32;
  dwYCountChars:   Nat32;
  dwFillAttribute: Nat32;
  dwFlags:         Nat32;
  wShowWindow:     Nat16;
  cbReserved2:     Nat16;
  lpReserved2:     Natx;
  hStdInput:       Natx;
  hStdOutput:      Natx;
  hStdError:       Natx;
}];

SYSTEM_INFO: [{
  wProcessorArchitecture:      Nat16;
  wReserved:                   Nat16;
  dwPageSize:                  Nat32;
  lpMinimumApplicationAddress: Natx;
  lpMaximumApplicationAddress: Natx;
  dwActiveProcessorMask:       Natx;
  dwNumberOfProcessors:        Nat32;
  dwProcessorType:             Nat32;
  dwAllocationGranularity:     Nat32;
  wProcessorLevel:             Nat16;
  wProcessorRevision:          Nat16;
}];

# kernel32.Lib should be included for these functions

{
  SRWLock: SRWLOCK Ref;
} {} {convention: stdcall;} "AcquireSRWLockExclusive" importFunction

{
  SRWLock: SRWLOCK Ref;
} {} {convention: stdcall;} "AcquireSRWLockShared" importFunction

{
  hFile:        Natx;
  lpOverlapped: OVERLAPPED Ref;
} Int32 {convention: stdcall;} "CancelIoEx" importFunction

{
  hObject: Natx;
} Int32 {convention: stdcall;} "CloseHandle" importFunction

{
  lpParameter: Natx;
} Natx {convention: stdcall;} "ConvertThreadToFiber" importFunction

{
  lpPathName:           Natx;
  lpSecurityAttributes: SECURITY_ATTRIBUTES Ref;
} Int32 {convention: stdcall;} "CreateDirectoryW" importFunction

{
  dwStackSize:    Natx;
  lpStartAddress: LPFIBER_START_ROUTINE;
  lpParameter:    Natx;
} Natx {convention: stdcall;} "CreateFiber" importFunction

{
  lpFileName:            Natx;
  dwDesiredAccess:       Nat32;
  dwShareMode:           Nat32;
  lpSecurityAttributes:  SECURITY_ATTRIBUTES Ref;
  dwCreationDisposition: Nat32;
  dwFlagsAndAttributes:  Nat32;
  hTemplateFile:         Natx;
} Natx {convention: stdcall;} "CreateFileW" importFunction

{
  FileHandle:                Natx;
  ExistingCompletionPort:    Natx;
  CompletionKey:             Natx;
  NumberOfConcurrentThreads: Nat32;
} Natx {convention: stdcall;} "CreateIoCompletionPort" importFunction

{
  lpApplicationName:    Natx;
  lpCommandLine:        Natx;
  lpProcessAttributes:  SECURITY_ATTRIBUTES Cref;
  lpThreadAttributes:   SECURITY_ATTRIBUTES Cref;
  bInheritHandles:      Int32;
  dwCreationFlags:      Nat32;
  lpEnvironment:        Natx;
  lpCurrentDirectory:   Natx;
  lpStartupInfo:        STARTUPINFOW Cref;
  lpProcessInformation: PROCESS_INFORMATION Ref;
} Int32 {convention: stdcall;} "CreateProcessW" importFunction

{
  lpThreadAttributes: SECURITY_ATTRIBUTES Ref;
  dwStackSize:        Natx;
  lpStartAddress:     LPTHREAD_START_ROUTINE;
  lpParameter:        Natx;
  dwCreationFlags:    Nat32;
  lpThreadId:         Nat32 Ref;
} Natx {convention: stdcall;} "CreateThread" importFunction

{
  lpFileName: Natx;
} Int32 {convention: stdcall;} "DeleteFileW" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
} {} {convention: stdcall;} "EnterCriticalSection" importFunction

{
  hProcess:   Natx;
  lpExitCode: Nat32 Ref;
} Int32 {convention: stdcall;} "GetExitCodeProcess" importFunction

{
  hThread:    Natx;
  lpExitCode: Nat32 Ref;
} Int32 {convention: stdcall;} "GetExitCodeThread" importFunction

{
  lpFileName: Natx;
} Nat32 {convention: stdcall;} "GetFileAttributesW" importFunction

{
  hFile:      Natx;
  lpFileSize: LARGE_INTEGER Ref;
} Int32 {convention: stdcall;} "GetFileSizeEx" importFunction

{} Nat32 {convention: stdcall;} "GetLastError" importFunction

{
  lpModuleName: Natx;
} HMODULE {convention: stdcall;} "GetModuleHandleW" importFunction

{
  hFile:                      Natx;
  lpOverlapped:               OVERLAPPED Ref;
  lpNumberOfBytesTransferred: Nat32 Ref;
  bWait:                      Int32;
} Int32 {convention: stdcall;} "GetOverlappedResult" importFunction

{
  hModule:    HMODULE;
  lpProcName: Natx;
} FARPROC {convention: stdcall;} "GetProcAddress" importFunction

{
  CompletionPort:             Natx;
  lpNumberOfBytesTransferred: Nat32 Ref;
  lpCompletionKey:            Natx Ref;
  lpOverlapped:               (OVERLAPPED Ref) Ref;
  dwMilliseconds:             Nat32;
} Int32 {convention: stdcall;} "GetQueuedCompletionStatus" importFunction

{
  CompletionPort:          Natx;
  lpCompletionPortEntries: OVERLAPPED_ENTRY Ref;
  ulCount:                 Nat32;
  ulNumEntriesRemoved:     Nat32 Ref;
  dwMilliseconds:          Nat32;
  fAlertable:              Int32;
} Int32 {convention: stdcall;} "GetQueuedCompletionStatusEx" importFunction


{
  lpSystemInfo: SYSTEM_INFO Ref;
} {} {convention: stdcall;} "GetSystemInfo" importFunction

{} Nat32 {convention: stdcall;} "GetTickCount64" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
  dwSpinCount:       Nat32;
} Int32 {convention: stdcall;} "InitializeCriticalSectionAndSpinCount" importFunction

{
  lpCriticalSection: CRITICAL_SECTION Ref;
} {} {convention: stdcall;} "LeaveCriticalSection" importFunction

{
  CodePage:       Nat32;
  dwFlags:        Nat32;
  lpMultiByteStr: Natx;
  cbMultiByte:    Int32;
  lpWideCharStr:  Natx;
  cchWideChar:    Int32;
} Int32 {convention: stdcall;} "MultiByteToWideChar" importFunction

{
  CompletionPort:             Natx;
  dwNumberOfBytesTransferred: Nat32;
  dwCompletionKey:            Natx;
  lpOverlapped:               OVERLAPPED Ref;
} Int32 {convention: stdcall;} "PostQueuedCompletionStatus" importFunction

{
  lpPerformanceCount: Int64 Ref;
} Int32 {convention: stdcall;} "QueryPerformanceCounter" importFunction

{
  lpFrequency: Int64 Ref;
} Int32 {convention: stdcall;} "QueryPerformanceFrequency" importFunction

{
  hFile:                Natx;
  lpBuffer:             Natx;
  nNumberOfBytesToRead: Nat32;
  lpNumberOfBytesRead:  Nat32 Ref;
  lpOverlapped:         OVERLAPPED Ref;
} Int32 {convention: stdcall;} "ReadFile" importFunction

{
  SRWLock: SRWLOCK Ref;
} {} {convention: stdcall;} "ReleaseSRWLockExclusive" importFunction

{
  SRWLock: SRWLOCK Ref;
} {} {convention: stdcall;} "ReleaseSRWLockShared" importFunction

{
  dwMilliseconds: Nat32;
} {} {convention: stdcall;} "Sleep" importFunction

{
  ConditionVariable: CONDITION_VARIABLE Ref;
  SRWLock:           SRWLOCK Ref;
  dwMilliseconds:    Nat32;
  Flags:             Nat32;
} Int32 {convention: stdcall;} "SleepConditionVariableSRW" importFunction

{
  lpFiber: Natx;
} {} {convention: stdcall;} "SwitchToFiber" importFunction

{
  SRWLock: SRWLOCK Ref;
} Cond {convention: stdcall;} "TryAcquireSRWLockExclusive" importFunction

{
  SRWLock: SRWLOCK Ref;
} Cond {convention: stdcall;} "TryAcquireSRWLockShared" importFunction

{
  hHandle:        Natx;
  dwMilliseconds: Nat32;
} Nat32 {convention: stdcall;} "WaitForSingleObject" importFunction

{
  ConditionVariable: CONDITION_VARIABLE Ref;
} {} {convention: stdcall;} "WakeAllConditionVariable" importFunction

{
  ConditionVariable: CONDITION_VARIABLE Ref;
} {} {convention: stdcall;} "WakeConditionVariable" importFunction

{
  CodePage:          Nat32;
  dwFlags:           Nat32;
  lpWideCharStr:     Natx;
  cchWideChar:       Int32;
  lpMultiByteStr:    Natx;
  cbMultiByte:       Int32;
  lpDefaultChar:     Natx;
  lpUsedDefaultChar: Natx;
} Int32 {convention: stdcall;} "WideCharToMultiByte" importFunction

{
  hFile:                  Natx;
  lpBuffer:               Natx;
  nNumberOfBytesToWrite:  Nat32;
  lpNumberOfBytesWritten: Nat32 Ref;
  lpOverlapped:           OVERLAPPED Ref;
} Int32 {convention: stdcall;} "WriteFile" importFunction
