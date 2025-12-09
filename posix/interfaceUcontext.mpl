# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32"     use
"control.Natx"      use
"control.Ref"       use
"conventions.cdecl" use

"ucontext.ucontext_t" use

{
  ucp: ucontext_t Ref;
} Int32 {convention: cdecl;} "getcontext" importFunction

{
  ucp:  ucontext_t Ref;
  func: Natx;
  argc: Int32;
} {} {variadic: TRUE; convention: cdecl;} "makecontext" importFunction

{
  oucp: ucontext_t Ref;
  ucp:  ucontext_t Ref;
} Int32 {convention: cdecl;} "swapcontext" importFunction
