"String"   use
"control"  use
"ucontext" use

{} Int32 {} [
  context: ucontext_t;

  res: @context getcontext;

  "getcontext returned " print res print LF print

  context print

  0
] "main" exportFunction
