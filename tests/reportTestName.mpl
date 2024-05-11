# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"          use
"control.compilable?" use
"control.print"       use
"control.when"        use

reportTestName: [
  name:;
  [TESTS_SILENT] compilable? [TESTS_SILENT] && ~ [name " passed\n" & print] when
];