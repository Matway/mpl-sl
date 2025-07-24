"String"    use
"control"   use
"memory"    use

{} Int32 {} [
  a: ("T" "h" "i" "s" " " "i" "s" " " "t" "h" "e" " " "t" "e" "x" "t" "." " ");
  b: ("D" "a" "s" "s" " " "i" "s" "t" " " "d" "e" "r" " " "T" "e" "x" "t" ".");

  18nx 8nx * b storageAddress a storageAddress memmove drop

  a assembleString print

  0
] "main" exportFunction
