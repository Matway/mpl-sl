"String.StringView"              use
"String.makeStringViewByAddress" use
"String.print"                   use
"algorithm.each"                 use
"control.Int32"                  use
"control.Natx"                   use
"control.assert"                 use
"control.keep"                   use
"control.print"                  use
"control.when"                   use

CommandLine: [{
  SCHEMA_NAME: "CommandLine" virtual;

  commandAddress: Natx;
  commandCount:   Int32;

  next: [
    commandValid: size 0 >;
    command:      StringView;

    commandValid [
      0 atUnchecked !command

      commandAddress Natx storageSize + !commandAddress
      commandCount 1 -                  !commandCount
    ] when

    command commandValid
  ];

  atUnchecked: [
    key: Natx cast;
    offset: Natx storageSize key *;
    commandAddress offset + Natx addressToReference makeStringViewByAddress
  ];

  at: [
    key:;
    [key size <] "Key is out of bounds" assert
    key atUnchecked
  ];

  size: [commandCount new];

  debugPrint: [
    "Commands provided: " print
    size print
    self [
      command:;
      LF "  «" & print
      command print
      "»" print
    ] each
  ];

  assign: [
    argv: argc:;;
    argv new !commandAddress
    argc new !commandCount
  ];

  to: [CommandLine [.assign] keep];
}];
