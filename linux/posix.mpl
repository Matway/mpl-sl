# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32"     use
"control.Intx"      use
"control.Ref"       use
"conventions.cdecl" use

# time

CLOCK_MONOTONIC: [1];

time_t: [Intx];

clockid_t: [Int32];

timespec: [{
  tv_sec:  time_t;
  tv_nsec: Intx;
}];

{
  clk_id: clockid_t;
  tp:     timespec Ref;
} Int32 {convention: cdecl;} "clock_gettime" importFunction
