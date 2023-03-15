# Copyright (C) 2023 Matway Burkow
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

"Span.Span"    use
"Span.toSpan"  use
"Span.toSpan2" use

SpanTest: [];

[
  Object: [{value: 0; CALL: [INVALID];}];
  span:   Object Span;
  [span.SCHEMA_NAME "Span" =                        ] "[Span] produced a wrong [.SCHEMA_NAME]"       ensure
  [span span "SCHEMA_NAME" fieldIndex fieldIsVirtual] "[Span] produced a non-virtual [.SCHEMA_NAME]" ensure
  [span.data Object same                            ] "[Span] produced a wrong schema"               ensure
  [@span.data isConst ~                             ] "[Span] lost mutability"                       ensure
  [span.data nil?                                   ] "[Span] did not erase reference"               ensure
  [span.size 0 =                                    ] "[Span] produced a wrong size"                 ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  span0:  Object Span;
  span1:  @span0 toSpan;
  [@span1 isConst ~] "[toSpan] lost mutability"       ensure
  [span1 span0 is ~] "[toSpan] passed a Span through" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  span0:  Object Span;
  object: {span: [@span0];};
  span1:  object toSpan;
  [@span1 isConst ~] "[toSpan] lost mutability"                  ensure
  [span1 span0 is  ] "[toSpan] did not call [.toSpan] correctly" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpan;
  [@span.data isConst ~] "[toSpan] lost mutability"            ensure
  [span.data dict.@a is] "[toSpan] produced a wrong reference" ensure
  [span.size 2 =       ] "[toSpan] produced a wrong size"      ensure
] call

[
  text: "test";
  span: text toSpan;
  [@span.data isConst                                      ] "[toSpan] acquired mutability"        ensure
  [span.data text storageAddress Nat8 addressToReference is] "[toSpan] produced a wrong reference" ensure
  [span.size 4 =                                           ] "[toSpan] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict.@a 2 toSpan2;
  [@span.data isConst ~] "[toSpan2] lost mutability"            ensure
  [span.data dict.@a is] "[toSpan2] produced a wrong reference" ensure
  [span.size 2 =       ] "[toSpan2] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span0:  @dict toSpan;
  span1:  dict  toSpan;
  span2:  span1 new;
  [[span0 new] compilable? ~] "Mutable Span can be copied"               ensure
  [span2.data dict.@a is    ] "[Span.ASSIGN] produced a wrong reference" ensure
  [span2.size 2 =           ] "[Span.ASSIGN] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   dict toSpan;
  span manuallyInitVariable
  [span.data nil?] "[Span.INIT] did not erase reference" ensure
  [span.size 0 = ] "[Span.INIT] did not zero out size"   ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  object: {objectData: @dict.@a; data: [@objectData]; size: [2];};
  span:   Object Span;
  @object @span.assign
  [span.data dict.@a is] "[Span.assign] produced a wrong reference" ensure
  [span.size 2 =       ] "[Span.assign] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpan;
  [0 @span.at isConst ~] "[Span.at] lost mutability"            ensure
  [0 span.at dict.@a is] "[Span.at] produced a wrong reference" ensure
  [1 span.at dict.@b is] "[Span.at] produced a wrong reference" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  iter:   @dict toSpan.iter;
  [iter.SCHEMA_NAME "SpanIter" =                    ] "[Span.iter] produced a wrong [.SCHEMA_NAME]"       ensure
  [iter iter "SCHEMA_NAME" fieldIndex fieldIsVirtual] "[Span.iter] produced a non-virtual [.SCHEMA_NAME]" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanIter.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanIter.next] lost mutability"            ensure
  [@item dict.@a is] "[SpanIter.next] produced a wrong reference" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanIter.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanIter.next] lost mutability"            ensure
  [@item dict.@b is] "[SpanIter.next] produced a wrong reference" ensure
  item: cond: iter.next;;
  [cond FALSE =] "[SpanIter.next] returned a wrong condition" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  iter:   @dict toSpan.iterReverse;
  [iter.SCHEMA_NAME "SpanIterReverse" =             ] "[Span.iterReverse] produced a wrong [.SCHEMA_NAME]"       ensure
  [iter iter "SCHEMA_NAME" fieldIndex fieldIsVirtual] "[Span.iterReverse] produced a non-virtual [.SCHEMA_NAME]" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanIterReverse.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanIterReverse.next] lost mutability"            ensure
  [@item dict.@b is] "[SpanIterReverse.next] produced a wrong reference" ensure
  item: cond: @iter.next;;
  [cond TRUE =     ] "[SpanIterReverse.next] returned a wrong condition" ensure
  [@item isConst ~ ] "[SpanIterReverse.next] lost mutability"            ensure
  [@item dict.@a is] "[SpanIterReverse.next] produced a wrong reference" ensure
  item: cond: iter.next;;
  [cond FALSE =] "[SpanIterReverse.next] returned a wrong condition" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  span:   Object Span;
  [span.size span.size is ~] "[Span.size] did not create a new value" ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object; c: Object; d: Object; e: Object;};
  span:   1 3 @dict toSpan.slice;
  [span.SCHEMA_NAME "Span" =] "[Span.slice] produced a wrong object"    ensure
  [@span.data isConst ~     ] "[Span.slice] lost mutability"            ensure
  [span.data dict.@b is     ] "[Span.slice] produced a wrong reference" ensure
  [span.size 3 =            ] "[Span.slice] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpan.span;
  [span.SCHEMA_NAME "Span" =] "[Span.span] produced a wrong object"    ensure
  [@span.data isConst ~     ] "[Span.span] lost mutability"            ensure
  [span.data dict.@a is     ] "[Span.span] produced a wrong reference" ensure
  [span.size 2 =            ] "[Span.span] produced a wrong size"      ensure
] call

[
  Object: [{value: 0; CALL: [INVALID];}];
  dict:   {a: Object; b: Object;};
  span:   @dict toSpan.toSpanStatic;
  [span.SCHEMA_NAME "SpanStatic" =] "[Span.toSpanStatic] produced a wrong object"    ensure
  [@span.data isConst ~           ] "[Span.toSpanStatic] lost mutability"            ensure
  [span.data dict.@a is           ] "[Span.toSpanStatic] produced a wrong reference" ensure
  [span.size 2 =                  ] "[Span.toSpanStatic] produced a wrong size"      ensure
] call

[
  text: "test";
  stringView: text toSpan.toStringView;
  [stringView.SCHEMA_NAME "StringView" =                         ] "[Span.toStringView] produced a wrong object"    ensure
  [stringView.data text storageAddress Nat8 addressToReference is] "[Span.toStringView] produced a wrong reference" ensure
  [stringView.size 4 =                                           ] "[Span.toStringView] produced a wrong size"      ensure
] call

[TESTS_SILENT] compilable? [TESTS_SILENT] && ~ ["SpanTest passed\n" print] when
