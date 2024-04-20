# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Span.toSpan2"                   use
"String.StringView"              use
"String.makeStringViewByAddress" use
"String.print"                   use
"algorithm.each"                 use
"algorithm.map"                  use
"control.Natx"                   use
"control.print"                  use

CommandLine: [Natx 0 toCommandLine2];

toCommandLine2: [
  argv: argc:;;
  argv Natx addressToReference argc toSpan2 @makeStringViewByAddress @StringView map
];

printCommandLine: [
  commands:;
  "Commands provided: " print
  commands.size print
  commands [
    command:;
    LF "  «" & print
    command print
    "»" print
  ] each
];
