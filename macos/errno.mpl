# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Int32"     use
"control.Ref"       use
"conventions.cdecl" use

errno: [__error];

{} Int32 Ref {convention: cdecl;} "__error" importFunction
