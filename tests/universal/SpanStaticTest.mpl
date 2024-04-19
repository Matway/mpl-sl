# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"          use
"control.Nat8"        use
"control.compilable?" use
"control.ensure"      use
"control.nil?"        use
"control.print"       use
"control.when"        use

"SpanStatic.SpanStatic"    use
"SpanStatic.toSpanStatic"  use
"SpanStatic.toSpanStatic2" use

SpanStaticTest: [];

[
  Object: [{value: 0; CALL: [INVALID];}];
  span:   Object 2 SpanStatic;
  [span.SCHEMA_NAME "SpanStatic<dict.{value:Int32;CALL:;}, 2>" =] "[SpanStatic] produced a wrong [.SCHEMA_NAME]"       ensure
  [span span "SCHEMA_NAME" fieldIndex fieldIsVirtual            ] "[SpanStatic] produced a non-virtual [.SCHEMA_NAME]" ensure
  [span.data Object same                                        ] "[SpanStatic] produced a wrong schema"               ensure
  [@span.data isConst ~                                         ] "[SpanStatic] lost mutability"                       ensure
  [span.data nil?                                               ] "[SpanStatic] did not erase reference"               ensure
  [span.size 2 =                                                ] "[SpanStatic] produced a wrong size"                 ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  span0:  Object 2 SpanStatic;
  span1:  @span0 toSpanStatic;
  [@span1 isConst ~] "[toSpanStatic] lost mutability"             ensure
  [span1 span0 is ~] "[toSpanStatic] passed a SpanStatic through" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  span0:  Object 2 SpanStatic;
  object: {spanStatic: [@span0];};
  span1:  object toSpanStatic;
  [@span1 isConst ~] "[toSpanStatic] lost mutability"                        ensure
  [span1 span0 is  ] "[toSpanStatic] did not call [.toSpanStatic] correctly" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpanStatic;
  [@span.data isConst ~] "[toSpanStatic] lost mutability"            ensure
  [span.data dict.@a is] "[toSpanStatic] produced a wrong reference" ensure
  [span.size 2 =       ] "[toSpanStatic] produced a wrong size"      ensure
] call

[
  text: "test";
  span: text toSpanStatic;
  [@span.data isConst                                      ] "[toSpanStatic] acquired mutability"        ensure
  [span.data text storageAddress Nat8 addressToReference is] "[toSpanStatic] produced a wrong reference" ensure
  [span.size 4 =                                           ] "[toSpanStatic] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict.@a 2 toSpanStatic2;
  [@span.data isConst ~] "[toSpanStatic2] lost mutability"            ensure
  [span.data dict.@a is] "[toSpanStatic2] produced a wrong reference" ensure
  [span.size 2 =       ] "[toSpanStatic2] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span0:  @dict toSpanStatic;
  span1:  dict  toSpanStatic;
  span2:  span1 new;
  span3:  dict.@a 2 SpanStatic;
  span4:  dict.@a 1 SpanStatic;
  #[[span0 new] compilable? ~       ] "Mutable SpanStatic can be copied"                 ensure # Ignore until the compiler supports the feature
  [span2.data dict.@a is           ] "[SpanStatic.ASSIGN] produced a wrong reference"   ensure
  [span2.size 2 =                  ] "[SpanStatic.ASSIGN] changed size"                 ensure
  [[span3 @span1 set] compilable?  ] "SpanStatic of the same size cannot be assigned"   ensure
  [[span4 @span1 set] compilable? ~] "SpanStatic of the different size can be assigned" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   dict toSpanStatic;
  span manuallyInitVariable
  [span.data nil? ~] "[SpanStatic.INIT] erased reference" ensure
  [span.size 2 =   ] "[SpanStatic.INIT] changed size"     ensure
] call

[
  Object:  [{value: 0; CALL: [INVALID];}];
  dict:    {a: Object; b: Object;};
  object0: {objectData: @dict.@a; data: [@objectData]; size: [2];};
  object1: {objectData: @dict.@a; data: [@objectData]; size: [1];};
  span:    Object 2 SpanStatic;
  @object0 @span.assign
  [span.data dict.@a is                 ] "[SpanStatic.assign] produced a wrong reference"                 ensure
  [span.size 2 =                        ] "[SpanStatic.assign] changed size"                               ensure
  [[@object1 @span.assign] compilable? ~] "[SpanStatic.assign] works for SpanStatic of the different size" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpanStatic;
  [0 @span.at isConst ~] "[SpanStatic.at] lost mutability"            ensure
  [0 span.at dict.@a is] "[SpanStatic.at] produced a wrong reference" ensure
  [1 span.at dict.@b is] "[SpanStatic.at] produced a wrong reference" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  iter:   @dict toSpanStatic.iter;
  [iter.SCHEMA_NAME "Span<dict.{value:Int32;CALL:;}>" =] "[SpanStatic.iter] produced a wrong object" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanStaticIter.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanStaticIter.next] lost mutability"            ensure
  [@item dict.@a is] "[SpanStaticIter.next] produced a wrong reference" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanStaticIter.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanStaticIter.next] lost mutability"            ensure
  [@item dict.@b is] "[SpanStaticIter.next] produced a wrong reference" ensure
  item: cond: iter.next;;
  [cond FALSE =] "[SpanStaticIter.next] returned a wrong condition" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  iter:   @dict toSpanStatic.iterReverse;
  [iter.SCHEMA_NAME "SpanStaticIterReverse" =       ] "[SpanStatic.iterReverse] produced a wrong [.SCHEMA_NAME]"       ensure
  [iter iter "SCHEMA_NAME" fieldIndex fieldIsVirtual] "[SpanStatic.iterReverse] produced a non-virtual [.SCHEMA_NAME]" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanStaticIterReverse.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanStaticIterReverse.next] lost mutability"            ensure
  [@item dict.@b is] "[SpanStaticIterReverse.next] produced a wrong reference" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanStaticIterReverse.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanStaticIterReverse.next] lost mutability"            ensure
  [@item dict.@a is] "[SpanStaticIterReverse.next] produced a wrong reference" ensure
  item: cond: iter.next;;
  [cond FALSE =] "[SpanStaticIterReverse.next] returned a wrong condition" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  span:   Object 2 SpanStatic;
  [span.size span.size is ~] "[SpanStatic.size] did not create a new value" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object; c: Object; d: Object; e: Object;};
  span:   1 3 @dict toSpanStatic.slice;
  [span.SCHEMA_NAME "SpanStatic<dict.{value:Int32;CALL:;}, 3>" =] "[SpanStatic.slice] produced a wrong object"    ensure
  [@span.data isConst ~                                         ] "[SpanStatic.slice] lost mutability"            ensure
  [span.data dict.@b is                                         ] "[SpanStatic.slice] produced a wrong reference" ensure
  [span.size 3 =                                                ] "[SpanStatic.slice] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpanStatic.span;
  [span.SCHEMA_NAME "Span<dict.{value:Int32;CALL:;}>" =] "[SpanStatic.span] produced a wrong object"    ensure
  [@span.data isConst ~                                ] "[SpanStatic.span] lost mutability"            ensure
  [span.data dict.@a is                                ] "[SpanStatic.span] produced a wrong reference" ensure
  [span.size 2 =                                       ] "[SpanStatic.span] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpanStatic.spanStatic;
  [span.SCHEMA_NAME "SpanStatic<dict.{value:Int32;CALL:;}, 2>" =] "[SpanStatic.spanStatic] produced a wrong object"    ensure
  [@span.data isConst ~                                         ] "[SpanStatic.spanStatic] lost mutability"            ensure
  [span.data dict.@a is                                         ] "[SpanStatic.spanStatic] produced a wrong reference" ensure
  [span.size 2 =                                                ] "[SpanStatic.spanStatic] produced a wrong size"      ensure
] call

[
  text: "test";
  stringView: text toSpanStatic.stringView;
  [stringView.SCHEMA_NAME "StringView" =                         ] "[SpanStatic.stringView] produced a wrong object"    ensure
  [stringView.data text storageAddress Nat8 addressToReference is] "[SpanStatic.stringView] produced a wrong reference" ensure
  [stringView.size 4 =                                           ] "[SpanStatic.stringView] produced a wrong size"      ensure
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["SpanStaticTest passed\n" print] when
