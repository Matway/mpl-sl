# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

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

toSpan: [isCombined] [
  struct:;
  0 dynamic @struct @ struct fieldCount toSpan2 # [dynamic] is used to check for non-homogeneous tuples
] pfunc;

toSpan: ["toSpan" has] [.toSpan] pfunc;

toSpan2: [
  spanData: spanSize:;;
  {
    SCHEMA_NAME: "Span" virtual;

    ASSIGN: [
      other:;
      other.@spanData    !spanData
      other.spanSize new !spanSize
    ];

    DIE: [];

    INIT: [
      @spanData Ref !spanData
      0             !spanSize
    ];

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
      {
        SCHEMA_NAME: "SpanIter" virtual;
        data: @spanData;
        size: spanSize new;

        next: [
          @data
          size 0 = ~ dup [
            @data storageAddress @data storageSize + @data addressToReference !data
            size 1 - !size
          ] when
        ];
      }
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

    size: [
      spanSize new
    ];

    slice: [
      offset: size:;;
      [offset 0 spanSize          between] "Offset is out of bounds" assert
      [size   0 spanSize offset - between] "Size is out of bounds"   assert
      @spanData storageAddress @spanData storageSize offset Natx cast * + @spanData addressToReference size toSpan2
    ];

    toArrayRange: [
      "Array.makeArrayRangeRaw" use
      spanSize @spanData makeArrayRangeRaw
    ];

    toSpan: [
      @spanData spanSize toSpan2
    ];

    toSpanStatic: [
      "SpanStatic.toSpanStatic2" use
      @spanData spanSize toSpanStatic2
    ];

    toStringView: [
      "String.toStringView" use
      (spanData spanSize new) toStringView
    ];

    # Private

    spanData: @spanData;
    spanSize: spanSize new;
  }
];
