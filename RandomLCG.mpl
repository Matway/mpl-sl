"RandomLCG" module
"control" includeModule

RandomLCG: [{
  seed: 0n32;
  nextSeed: [seed 0x8088405n32 * 1n32 + @seed set seed copy] func;
  getr32: [nextSeed 0.0r32 cast 1.0r32 65536.0r32 / 65536.0r32 / * ] func;
  getn32: [0n64 cast nextSeed 0n64 cast * 32n64 rshift 0n32 cast] func;
  geti32: [0n64 cast nextSeed 0n64 cast * 32n64 rshift 0i32 cast] func;
}] func;
