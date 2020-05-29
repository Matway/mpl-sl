"Array.makeArrayRange" use
"Array.makeSubRange" use
"control.!" use
"control.&&" use
"control.@" use
"control.Int32" use
"control.Nat32" use
"control.Nat64" use
"control.Nat8" use
"control.Natx" use
"control.drop" use
"control.min" use
"control.times" use
"control.when" use
"control.while" use
"memory.memcpy" use
"memory.memset" use

Sha1Internal: {
  rol: [
    value:count:;;
    value count lshift
    value 32n32 count - rshift
    or
  ];

  f1: [
    x:y:z:;;;
    y z xor x and z xor 0x5A827999n32 +
  ];

  f2: [
    x:y:z:;;;
    x y xor z xor 0x6ED9EBA1n32 +
  ];

  f3: [
    x:y:z:;;;
    x y and
    x y or z and or 0x8F1BBCDCn32 +
  ];

  f4: [
    x:y:z:;;;
    x y xor z xor 0xCA62C1D6n32 +
  ];

  m: [
    x:i:;;
    b: i 0x0fn32 and Int32 cast @x.at;

    b
    i 2n32 + 0x0fn32 and Int32 cast x.at xor
    i 8n32 + 0x0fn32 and Int32 cast x.at xor
    i 13n32 + 0x0fn32 and Int32 cast x.at xor 1n32 rol @b set
    b copy
  ];

  r: [
    a:b:c:d:e:f:m:;;;;;;;
    a 5n32 rol b c d @f call + m + e + @e set
    b 30n32 rol @b set
  ];

  transform: [
    state:buf:;;
    x: Nat32 16 array makeArrayRange;
    16 [
      i 4 * 0 + buf @ Nat32 cast 24n32 lshift
      i 4 * 1 + buf @ Nat32 cast 16n32 lshift or
      i 4 * 2 + buf @ Nat32 cast  8n32 lshift or
      i 4 * 3 + buf @ Nat32 cast              or
      i @x !
    ] times

    a: 0 state @ copy;
    b: 1 state @ copy;
    c: 2 state @ copy;
    d: 3 state @ copy;
    e: 4 state @ copy;

    a @b c d @e @f1  0 x.at r
    e @a b c @d @f1  1 x.at r
    d @e a b @c @f1  2 x.at r
    c @d e a @b @f1  3 x.at r
    b @c d e @a @f1  4 x.at r
    a @b c d @e @f1  5 x.at r
    e @a b c @d @f1  6 x.at r
    d @e a b @c @f1  7 x.at r
    c @d e a @b @f1  8 x.at r
    b @c d e @a @f1  9 x.at r
    a @b c d @e @f1 10 x.at r
    e @a b c @d @f1 11 x.at r
    d @e a b @c @f1 12 x.at r
    c @d e a @b @f1 13 x.at r
    b @c d e @a @f1 14 x.at r
    a @b c d @e @f1 15 x.at r

    e @a b c @d @f1 @x 16n32 m r
    d @e a b @c @f1 @x 17n32 m r
    c @d e a @b @f1 @x 18n32 m r
    b @c d e @a @f1 @x 19n32 m r
    a @b c d @e @f2 @x 20n32 m r
    e @a b c @d @f2 @x 21n32 m r
    d @e a b @c @f2 @x 22n32 m r
    c @d e a @b @f2 @x 23n32 m r
    b @c d e @a @f2 @x 24n32 m r
    a @b c d @e @f2 @x 25n32 m r
    e @a b c @d @f2 @x 26n32 m r
    d @e a b @c @f2 @x 27n32 m r
    c @d e a @b @f2 @x 28n32 m r
    b @c d e @a @f2 @x 29n32 m r
    a @b c d @e @f2 @x 30n32 m r
    e @a b c @d @f2 @x 31n32 m r
    d @e a b @c @f2 @x 32n32 m r
    c @d e a @b @f2 @x 33n32 m r
    b @c d e @a @f2 @x 34n32 m r
    a @b c d @e @f2 @x 35n32 m r
    e @a b c @d @f2 @x 36n32 m r
    d @e a b @c @f2 @x 37n32 m r
    c @d e a @b @f2 @x 38n32 m r
    b @c d e @a @f2 @x 39n32 m r
    a @b c d @e @f3 @x 40n32 m r
    e @a b c @d @f3 @x 41n32 m r
    d @e a b @c @f3 @x 42n32 m r
    c @d e a @b @f3 @x 43n32 m r
    b @c d e @a @f3 @x 44n32 m r
    a @b c d @e @f3 @x 45n32 m r
    e @a b c @d @f3 @x 46n32 m r
    d @e a b @c @f3 @x 47n32 m r
    c @d e a @b @f3 @x 48n32 m r
    b @c d e @a @f3 @x 49n32 m r
    a @b c d @e @f3 @x 50n32 m r
    e @a b c @d @f3 @x 51n32 m r
    d @e a b @c @f3 @x 52n32 m r
    c @d e a @b @f3 @x 53n32 m r
    b @c d e @a @f3 @x 54n32 m r
    a @b c d @e @f3 @x 55n32 m r
    e @a b c @d @f3 @x 56n32 m r
    d @e a b @c @f3 @x 57n32 m r
    c @d e a @b @f3 @x 58n32 m r
    b @c d e @a @f3 @x 59n32 m r
    a @b c d @e @f4 @x 60n32 m r
    e @a b c @d @f4 @x 61n32 m r
    d @e a b @c @f4 @x 62n32 m r
    c @d e a @b @f4 @x 63n32 m r
    b @c d e @a @f4 @x 64n32 m r
    a @b c d @e @f4 @x 65n32 m r
    e @a b c @d @f4 @x 66n32 m r
    d @e a b @c @f4 @x 67n32 m r
    c @d e a @b @f4 @x 68n32 m r
    b @c d e @a @f4 @x 69n32 m r
    a @b c d @e @f4 @x 70n32 m r
    e @a b c @d @f4 @x 71n32 m r
    d @e a b @c @f4 @x 72n32 m r
    c @d e a @b @f4 @x 73n32 m r
    b @c d e @a @f4 @x 74n32 m r
    a @b c d @e @f4 @x 75n32 m r
    e @a b c @d @f4 @x 76n32 m r
    d @e a b @c @f4 @x 77n32 m r
    c @d e a @b @f4 @x 78n32 m r
    b @c d e @a @f4 @x 79n32 m r
    a 0 state @ + 0 @state !
    b 1 state @ + 1 @state !
    c 2 state @ + 2 @state !
    d 3 state @ + 3 @state !
    e 4 state @ + 4 @state !
  ];
};

ShaCounter: [{
  state: (0x67452301n32 0xEFCDAB89n32 0x98BADCFEn32 0x10325476n32 0xC3D2E1F0n32);
  internalBuffer: Nat8 64 array;
  internalBufferProcessed: 0;
  bitSize: Nat64;

  appendData: [
    source: makeArrayRange;
    source.getSize Nat64 cast 8n64 * bitSize + !bitSize
    [
      sz: 64 internalBufferProcessed - source.getSize min;
      sz Natx cast
      source.getBufferBegin
      internalBuffer storageAddress internalBufferProcessed Natx cast + memcpy drop
      sz source.getSize source makeSubRange !source
      internalBufferProcessed sz + !internalBufferProcessed

      internalBufferProcessed 64 = [
        @state internalBuffer Sha1Internal.transform
        0 !internalBufferProcessed
        TRUE
      ] &&
    ] loop
  ];

  finish: [
    count: internalBufferProcessed copy;

    0x80n8 count @internalBuffer @ set
    count 1 + !count
    count 56 > [
      64 count - Natx cast
      0
      internalBuffer storageAddress count Natx cast + memset drop
      @state internalBuffer Sha1Internal.transform
      0 !count
    ] when

    56 count - Natx cast
    0
    internalBuffer storageAddress count Natx cast + memset drop

    bitSize 56n32 rshift Nat8 cast 56 @internalBuffer !
    bitSize 48n32 rshift Nat8 cast 57 @internalBuffer !
    bitSize 40n32 rshift Nat8 cast 58 @internalBuffer !
    bitSize 32n32 rshift Nat8 cast 59 @internalBuffer !
    bitSize 24n32 rshift Nat8 cast 60 @internalBuffer !
    bitSize 16n32 rshift Nat8 cast 61 @internalBuffer !
    bitSize  8n32 rshift Nat8 cast 62 @internalBuffer !
    bitSize              Nat8 cast 63 @internalBuffer !

    @state internalBuffer Sha1Internal.transform

    result: 0n8 20 array;
    5 [
      i state @ 24n32 rshift Nat8 cast i 4 * 0 + @result !
      i state @ 16n32 rshift Nat8 cast i 4 * 1 + @result !
      i state @  8n32 rshift Nat8 cast i 4 * 2 + @result !
      i state @              Nat8 cast i 4 * 3 + @result !
    ] times

    @result
  ];
}];

sha1: [
  source: makeArrayRange;
  state: (0x67452301n32 0xEFCDAB89n32 0x98BADCFEn32 0x10325476n32 0xC3D2E1F0n32);
  bitSize: source.getSize Nat64 cast 3n32 lshift;
  [source.getSize 64 < ~] [
    @state source Sha1Internal.transform
    64 source.getSize source makeSubRange !source
  ] while

  buf: Nat8 64 array makeArrayRange;
  count: source.getSize;

  count Natx cast
  source.getBufferBegin
  buf.getBufferBegin memcpy drop

  0x80n8 count @buf.at set
  count 1 + !count
  count 56 > [
    64 count - Natx cast
    0
    buf.getBufferBegin count Natx cast + memset drop
    @state buf Sha1Internal.transform
    0 !count
  ] when

  56 count - Natx cast
  0
  buf.getBufferBegin count Natx cast + memset drop

  bitSize 56n32 rshift Nat8 cast 56 @buf.at set
  bitSize 48n32 rshift Nat8 cast 57 @buf.at set
  bitSize 40n32 rshift Nat8 cast 58 @buf.at set
  bitSize 32n32 rshift Nat8 cast 59 @buf.at set
  bitSize 24n32 rshift Nat8 cast 60 @buf.at set
  bitSize 16n32 rshift Nat8 cast 61 @buf.at set
  bitSize  8n32 rshift Nat8 cast 62 @buf.at set
  bitSize              Nat8 cast 63 @buf.at set

  @state buf Sha1Internal.transform

  result: 0n8 20 array;
  5 [
    i state @ 24n32 rshift Nat8 cast i 4 * 0 + @result !
    i state @ 16n32 rshift Nat8 cast i 4 * 1 + @result !
    i state @  8n32 rshift Nat8 cast i 4 * 2 + @result !
    i state @              Nat8 cast i 4 * 3 + @result !
  ] times

  @result
];
