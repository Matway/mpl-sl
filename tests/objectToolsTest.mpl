# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Cref"     use
"control.Int32"    use
"control.REF_SIZE" use
"control.Ref"      use
"control.times"    use
"control.when"     use

"objectTools.cloneDict"          use
"objectTools.formatObjectStatic" use
"objectTools.insertField"        use
"objectTools.removeField"        use
"objectTools.transferField"      use
"objectTools.unwrapField"        use
"objectTools.unwrapFields"       use

TEST_FIELDS: [(
  ("v00" [1])
  ("v01" [1 virtual])
  ("v02" [Int32 Ref])
  ("v03" [Int32 Ref virtual])
  ("v04" [Int32 Cref])
  ("v05" [Int32 Cref virtual])
  ("v10" [[]])
  ("v20" [{} {} {} codeRef])
  ("v21" [{} {} {} codeRef virtual])
  ("v30" [""])
  ("v31" ["" virtual])
  ("v40" [{}])
  ("v50" [{v: 1;}])
  ("v51" [{v: 1;} virtual])
  ("v52" [{v: 1;} Ref])
  ("v53" [{v: 1;} Ref virtual])
  ("v54" [{v: 1;} Cref])
  ("v55" [{v: 1;} Cref virtual])
  ("v60" [{DIE: [];}])
  ("v70" [{DIE: []; v: 1;}])
  ("v71" [{DIE: []; v: 1;} Ref])
  ("v72" [{DIE: []; v: 1;} Ref virtual])
  ("v73" [{DIE: []; v: 1;} Cref])
  ("v74" [{DIE: []; v: 1;} Cref virtual])
)];

TestDict: [
  insertCallable: insertName: insertOrdinal: removeOrdinal:;;;;
  iterate: [
    i insertOrdinal = [@insertCallable ucall insertName def] [] uif
    i TEST_FIELDS fieldCount = [] [
      i removeOrdinal = [] [1 i TEST_FIELDS @ @ ucall 0 i TEST_FIELDS @ @ def] uif
      i 1 + !i
      @iterate ucall
    ] uif
  ];

  i: 0;
  {@iterate ucall}
];

TestTuple: [(
  1
  Int32 Ref
  Int32 Cref
  []
  {} {} {} codeRef
  ""
  {}
  {v: 1;}
  {v: 1;} Ref
  {v: 1;} Cref
  {DIE: [];}
  {DIE: []; v: 1;}
  {DIE: []; v: 1;} Ref
  {DIE: []; v: 1;} Cref
)];

# Test object formatting

testFormatting: [
  object: options: expected:;;;
  result: @object options formatObjectStatic;
  result expected = ~ [
    "Invalid [formatObjectStatic] result: " result & ", expected result: " & expected & raiseStaticError
  ] when
];

[] {}                               "Code"                    testFormatting
{} {} {} codeRef {}                 "CodeRef"                 testFormatting
FALSE {}                            "FALSE"                   testFormatting
TRUE {}                             "TRUE"                    testFormatting
TRUE dynamic {}                     "Cond"                    testFormatting
-32768i16               {         } "-32768i16"               testFormatting
-32768i16               {base: 16;} "-0x8000i16"              testFormatting
0i16                    {         } "0i16"                    testFormatting
0i16                    {base: 16;} "0x0i16"                  testFormatting
0x7FFFi16               {         } "32767i16"                testFormatting
0x7FFFi16               {base: 16;} "0x7FFFi16"               testFormatting
-2147483648             {         } "-2147483648"             testFormatting
-2147483648             {base: 16;} "-0x80000000"             testFormatting
0                       {         } "0"                       testFormatting
0                       {base: 16;} "0x0"                     testFormatting
0x7FFFFFFF              {         } "2147483647"              testFormatting
0x7FFFFFFF              {base: 16;} "0x7FFFFFFF"              testFormatting
-9223372036854775808i64 {         } "-9223372036854775808i64" testFormatting
-9223372036854775808i64 {base: 16;} "-0x8000000000000000i64"  testFormatting
0i64                    {         } "0i64"                    testFormatting
0i64                    {base: 16;} "0x0i64"                  testFormatting
0x7FFFFFFFFFFFFFFFi64   {         } "9223372036854775807i64"  testFormatting
0x7FFFFFFFFFFFFFFFi64   {base: 16;} "0x7FFFFFFFFFFFFFFFi64"   testFormatting
-128i8                  {         } "-128i8"                  testFormatting
-128i8                  {base: 16;} "-0x80i8"                 testFormatting
0i8                     {         } "0i8"                     testFormatting
0i8                     {base: 16;} "0x0i8"                   testFormatting
0x7Fi8                  {         } "127i8"                   testFormatting
0x7Fi8                  {base: 16;} "0x7Fi8"                  testFormatting
0n16                    {         } "0n16"                    testFormatting
0n16                    {base: 16;} "0x0n16"                  testFormatting
0xFFFFn16               {         } "65535n16"                testFormatting
0xFFFFn16               {base: 16;} "0xFFFFn16"               testFormatting
0n32                    {         } "0n32"                    testFormatting
0n32                    {base: 16;} "0x0n32"                  testFormatting
0xFFFFFFFFn32           {         } "4294967295n32"           testFormatting
0xFFFFFFFFn32           {base: 16;} "0xFFFFFFFFn32"           testFormatting
0n64                    {         } "0n64"                    testFormatting
0n64                    {base: 16;} "0x0n64"                  testFormatting
0xFFFFFFFFFFFFFFFFn64   {         } "18446744073709551615n64" testFormatting
0xFFFFFFFFFFFFFFFFn64   {base: 16;} "0xFFFFFFFFFFFFFFFFn64"   testFormatting
0n8                     {         } "0n8"                     testFormatting
0n8                     {base: 16;} "0x0n8"                   testFormatting
0xFFn8                  {         } "255n8"                   testFormatting
0xFFn8                  {base: 16;} "0xFFn8"                  testFormatting
0i16 dynamic {}                     "Int16"                   testFormatting
0    dynamic {}                     "Int32"                   testFormatting
0i64 dynamic {}                     "Int64"                   testFormatting
0i8  dynamic {}                     "Int8"                    testFormatting
0n16 dynamic {}                     "Nat16"                   testFormatting
0n32 dynamic {}                     "Nat32"                   testFormatting
0n64 dynamic {}                     "Nat64"                   testFormatting
0n8  dynamic {}                     "Nat8"                    testFormatting
0.0r32 {}                           "Real32"                  testFormatting
0.0r64 {}                           "Real64"                  testFormatting
"Test" {}                           "\"Test\""                testFormatting
"Test" dynamic {}                   "Text"                    testFormatting
REF_SIZE 4 = [
  -2147483648ix {         } "-2147483648ix" testFormatting
  -2147483648ix {base: 16;} "-0x80000000ix" testFormatting
  0ix           {         } "0ix"           testFormatting
  0ix           {base: 16;} "0x0ix"         testFormatting
  0x7FFFFFFFix  {         } "2147483647ix"  testFormatting
  0x7FFFFFFFix  {base: 16;} "0x7FFFFFFFix"  testFormatting
  0nx           {         } "0nx"           testFormatting
  0nx           {base: 16;} "0x0nx"         testFormatting
  0xFFFFFFFFnx  {         } "4294967295nx"  testFormatting
  0xFFFFFFFFnx  {base: 16;} "0xFFFFFFFFnx"  testFormatting
  0ix dynamic {}            "Intx"          testFormatting
  0nx dynamic {}            "Natx"          testFormatting
] [
  -9223372036854775808ix {         } "-9223372036854775808ix" testFormatting
  -9223372036854775808ix {base: 16;} "-0x8000000000000000ix"  testFormatting
  0ix                    {         } "0ix"                    testFormatting
  0ix                    {base: 16;} "0x0ix"                  testFormatting
  0x7FFFFFFFFFFFFFFFix   {         } "9223372036854775807ix"  testFormatting
  0x7FFFFFFFFFFFFFFFix   {base: 16;} "0x7FFFFFFFFFFFFFFFix"   testFormatting
  0nx                    {         } "0nx"                    testFormatting
  0nx                    {base: 16;} "0x0nx"                  testFormatting
  0xFFFFFFFFFFFFFFFFnx   {         } "18446744073709551615nx" testFormatting
  0xFFFFFFFFFFFFFFFFnx   {base: 16;} "0xFFFFFFFFFFFFFFFFnx"   testFormatting
  0ix dynamic {}                     "Intx"                   testFormatting
  0nx dynamic {}                     "Natx"                   testFormatting
] if

[] "" -1 -1 TestDict {dictIndent: 2;}
"{\n"
"      v00: 1;\n" &
"      v01: 1 virtual;\n" &
"      v02: Int32 Ref;\n" &
"      v03: Int32 Ref virtual;\n" &
"      v04: Int32 Cref;\n" &
"      v05: Int32 Cref virtual;\n" &
"      v10: Code;\n" &
"      v20: CodeRef;\n" &
"      v21: CodeRef virtual;\n" &
"      v30: \"\";\n" &
"      v31: \"\" virtual;\n" &
"      v40: {};\n" &
"      v50: {\n" &
"        v: 1;\n" &
"      };\n" &
"      v51: {\n" &
"        v: 1;\n" &
"      } virtual;\n" &
"      v52: {\n" &
"        v: Int32;\n" &
"      } Ref;\n" &
"      v53: {\n" &
"        v: Int32;\n" &
"      } Ref virtual;\n" &
"      v54: {\n" &
"        v: Int32;\n" &
"      } Cref;\n" &
"      v55: {\n" &
"        v: Int32;\n" &
"      } Cref virtual;\n" &
"      v60: {\n" &
"        DIE: Code;\n" &
"      };\n" &
"      v70: {\n" &
"        DIE: Code;\n" &
"        v: 1;\n" &
"      };\n" &
"      v71: {\n" &
"        DIE: Code;\n" &
"        v: Int32;\n" &
"      } Ref;\n" &
"      v72: {\n" &
"        DIE: Code;\n" &
"        v: Int32;\n" &
"      } Ref virtual;\n" &
"      v73: {\n" &
"        DIE: Code;\n" &
"        v: Int32;\n" &
"      } Cref;\n" &
"      v74: {\n" &
"        DIE: Code;\n" &
"        v: Int32;\n" &
"      } Cref virtual;\n" &
"    }" & testFormatting

[] "" -1 -1 TestDict {}
"{"
"v00: 1; " &
"v01: 1 virtual; " &
"v02: Int32 Ref; " &
"v03: Int32 Ref virtual; " &
"v04: Int32 Cref; " &
"v05: Int32 Cref virtual; " &
"v10: Code; " &
"v20: CodeRef; " &
"v21: CodeRef virtual; " &
"v30: \"\"; " &
"v31: \"\" virtual; " &
"v40: {}; " &
"v50: {v: 1;}; " &
"v51: {v: 1;} virtual; " &
"v52: {v: Int32;} Ref; " &
"v53: {v: Int32;} Ref virtual; " &
"v54: {v: Int32;} Cref; " &
"v55: {v: Int32;} Cref virtual; " &
"v60: {DIE: Code;}; " &
"v70: {DIE: Code; v: 1;}; " &
"v71: {DIE: Code; v: Int32;} Ref; " &
"v72: {DIE: Code; v: Int32;} Ref virtual; " &
"v73: {DIE: Code; v: Int32;} Cref; " &
"v74: {DIE: Code; v: Int32;} Cref virtual;" &
"}" & testFormatting

TestTuple {tupleIndent: 2;}
"(\n"
"      1\n" &
"      Int32 Ref\n" &
"      Int32 Cref\n" &
"      Code\n" &
"      CodeRef\n" &
"      \"\"\n" &
"      {}\n" &
"      {v: 1;}\n" &
"      {v: Int32;} Ref\n" &
"      {v: Int32;} Cref\n" &
"      {DIE: Code;}\n" &
"      {DIE: Code; v: 1;}\n" &
"      {DIE: Code; v: Int32;} Ref\n" &
"      {DIE: Code; v: Int32;} Cref\n" &
"    )" & testFormatting

TestTuple {}
"("
"1 " &
"Int32 Ref " &
"Int32 Cref " &
"Code " &
"CodeRef " &
"\"\" " &
"{} " &
"{v: 1;} " &
"{v: Int32;} Ref " &
"{v: Int32;} Cref " &
"{DIE: Code;} " &
"{DIE: Code; v: 1;} " &
"{DIE: Code; v: Int32;} Ref " &
"{DIE: Code; v: Int32;} Cref" &
")" & testFormatting

# Test object manipulation

testManipulation: [
  manipulation: result: expected:;;;
  @result @expected same ~ [
    "Invalid [" manipulation & "] result: " & @result {dictIndent: 0;} formatObjectStatic & ", expected result: " & @expected {dictIndent: 0;} formatObjectStatic & raiseStaticError
  ] when
];

"cloneDict"
[] "" -1 -1 TestDict cloneDict
[] "" -1 -1 TestDict testManipulation

[
  dict: [] "" -1 -1 TestDict;
  @dict fieldCount 1 + [
    j: i;
    TEST_FIELDS fieldCount [
      "insertField"
      @dict {v: 1 i TEST_FIELDS @ @ ucall;} "test" j insertField
      1 i TEST_FIELDS @ @ "test" j -1 TestDict testManipulation
    ] times
  ] times
] call

[
  dict: [] "" -1 -1 TestDict;
  @dict fieldCount [
    "removeField"
    @dict i removeField
    [] "" -1 i TestDict testManipulation
  ] times
] call

[
  dict: [] "" -1 -1 TestDict;
  @dict fieldCount [
    "transferField"
    {@dict i @transferField ucall}
    {1 i TEST_FIELDS @ @ ucall 0 i TEST_FIELDS @ @ def} testManipulation
  ] times
] call

[
  dict: [] "" -1 -1 TestDict;
  @dict fieldCount [
    "unwrapField"
    @dict i unwrapField
    v: 1 i TEST_FIELDS @ @ ucall; @v testManipulation
  ] times
] call

[
  "unwrapFields"
  ([] "" -1 -1 TestDict unwrapFields)
  (TEST_FIELDS fieldCount [
    v: 1 i TEST_FIELDS @ @ ucall; @v
  ] times)

  testManipulation
] call
