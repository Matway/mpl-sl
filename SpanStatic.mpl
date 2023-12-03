# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"                     use
"control.Cref"                   use
"control.Int32"                  use
"control.Nat8"                   use
"control.Natx"                   use
"control.Ref"                    use
"control.Text"                   use
"control.assert"                 use
"control.between"                use
"control.dup"                    use
"control.getUnchecked"           use
"control.pfunc"                  use
"control.when"                   use
"control.within"                 use
"objectTools.formatObjectStatic" use

SpanStatic: [
  data: size:;;
  @data Ref size toSpanStatic2
];

toSpanStatic: [Text same] [
  text:;
  text storageAddress Nat8 Cref addressToReference text textSize Int32 cast toSpanStatic2
] pfunc;

toSpanStatic: [object:; @object isCombined [@object 0 fieldIsRef ~] &&] [
  struct:;
  0 dynamic @struct getUnchecked struct fieldCount toSpanStatic2 # [dynamic] is used to check for non-homogeneous tuples
] pfunc;

toSpanStatic: ["spanStatic" has] [.spanStatic] pfunc;

toSpanStatic2: [
  spanData: spanSize:;;
  {
    SCHEMA_NAME: "SpanStatic<" @spanData schemaName & ", " & spanSize {} formatObjectStatic & ">" & virtual;

    assign: [
      other:;
      [other.size spanSize =] "Inconsistent sizes" assert
      @other.data !spanData
    ];

    at: [
      key:;
      [key 0 spanSize within] "Key is out of bounds" assert
      @spanData storageAddress @spanData storageSize key Natx cast * + @spanData addressToReference
    ];

    data: [
      @spanData
    ];

    iter: [
      span
    ];

    iterReverse: [
      {
        SCHEMA_NAME: "SpanStaticIterReverse" virtual;
        data: @spanData storageAddress @spanData storageSize spanSize Natx cast * + @spanData storageSize - @spanData addressToReference;
        size: spanSize;

        next: [
          @data
          size 0 = ~ dup [
            @data storageAddress @data storageSize - @data addressToReference !data
            size 1 - !size
          ] when
        ];
      }
    ];

    size: [
      spanSize
    ];

    slice: [
      offset: size:;;
      [offset 0 spanSize          between] "Offset is out of bounds" assert
      [size   0 spanSize offset - between] "Size is out of bounds"   assert
      @spanData storageAddress @spanData storageSize offset Natx cast * + @spanData addressToReference size toSpanStatic2
    ];

    span: [
      "Span.toSpan2" use
      @spanData spanSize toSpan2
    ];

    spanStatic: [
      @spanData spanSize toSpanStatic2
    ];

    stringView: [
      "String.toStringView" use
      (spanData spanSize) toStringView
    ];

    private spanData: @spanData;
    private spanSize: spanSize new virtual;
  }
];
