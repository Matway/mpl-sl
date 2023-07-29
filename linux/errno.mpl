"control.Int32"     use
"control.Ref"       use
"conventions.cdecl" use

errno: [__errno_location];

{} Int32 Ref {convention: cdecl;} "__errno_location" importFunction # Link with libpthread.a
