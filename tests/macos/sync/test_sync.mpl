"String"    use
"algorithm" use
"control"   use
"sync/sync" use

[
  tStart: getTime;
  1 sleepFor
  tEnd: getTime;

  tDelta: tEnd tStart -;

  [tDelta 1.0r64 >] ["slept less then a second"] assert
  [tDelta 1.1r64 <] ["slept more than 1.1 seconds"] assert
] call

[
  s: String;

  func: [
    s:;
    "a" @s.cat
    1 sleepFor
    "b" @s.cat
  ];

  (
    (@s) [unwrap func] bind () spawn
    (@s) [unwrap func] bind () spawn
    (@s) [unwrap func] bind () spawn
    (@s) [unwrap func] bind () spawn
    (@s) [unwrap func] bind () spawn
  ) [
    .wait
  ] each

  [s "aaaaabbbbb" =] ["Invalid result"] assert
] call

{} Int32 {} [
  0
] "main" exportFunction
