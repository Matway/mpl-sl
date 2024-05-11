# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.ensure" use

testSchemaName: [
  Item: expectedSchemaName:;;
  givenSchemaName: @Item schemaName;
  schemaNameKey:   @Item "SCHEMA_NAME" fieldIndex;
  [@Item schemaNameKey fieldIsVirtual  ] "[.SCHEMA_NAME] is not virtual"                                                            ensure
  [givenSchemaName expectedSchemaName =] "Wrong schema name «" givenSchemaName & "», while expected «" & expectedSchemaName & "»" & ensure
];
