# Copyright (C) Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&"      use
"control.Cref"    use
"control.Int32"   use
"control.Nat8"    use
"control.Natx"    use
"control.Ref"     use
"control.Text"    use
"control.assert"  use
"control.between" use
"control.dup"     use
"control.pfunc"   use
"control.when"    use
"control.within"  use

Span: [
  data:;
  @data Ref 0 toSpan2
];

toSpan: [Text same] [
  text:;
  text storageAddress Nat8 Cref addressToReference text textSize Int32 cast toSpan2
] pfunc;

toSpan: [object:; @object isCombined [@object 0 fieldIsRef ~] &&] [
  struct:;
  0 dynamic @struct @ struct fieldCount toSpan2 # [dynamic] is used to check for non-homogeneous tuples
] pfunc;

toSpan: ["span" has] [.span] pfunc;

toSpan2: [
  spanData: spanSize:;;
  {
    SCHEMA_NAME: "Span<" @spanData schemaName & ">" & virtual;

    assign: [
      other:;
      @other.data !spanData
      other.size  !spanSize
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
        SCHEMA_NAME: "SpanIterReverse" virtual;
        data: @spanData storageAddress @spanData storageSize spanSize Natx cast * + @spanData storageSize - @spanData addressToReference;
        size: spanSize new;

        next: [
          @data
          size 0 = ~ dup [
            @data storageAddress @data storageSize - @data addressToReference !data
            size 1 - !size
          ] when
        ];
      }
    ];

    next: [
      @spanData
      spanSize 0 = ~ dup [
        @spanData storageAddress @spanData storageSize + @spanData addressToReference !spanData
        spanSize 1 - !spanSize
      ] when
    ];

    size: [
      spanSize new
    ];

    slice: [
      offset: size:;;
      [offset 0 spanSize          between] "Offset is out of bounds" assert
      [size   0 spanSize offset - between] "Size is out of bounds"   assert
      @spanData storageAddress @spanData storageSize offset Natx cast * + @spanData addressToReference size toSpan2
    ];

    span: [
      @spanData spanSize toSpan2
    ];

    spanStatic: [
      "SpanStatic.toSpanStatic2" use
      @spanData spanSize toSpanStatic2
    ];

    stringView: [
      "String.toStringView" use
      (spanData spanSize new) toStringView
    ];

    private spanData: @spanData;
    private spanSize: spanSize new;
  }
];
