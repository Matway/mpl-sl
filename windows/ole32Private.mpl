"control.Int32" use
"control.Natx" use
"conventions.stdcall" use

{
  pvReserved: Natx;
} Int32 {convention: stdcall;} "CoInitialize" importFunction

{
} {} {convention: stdcall;} "CoUninitialize" importFunction
