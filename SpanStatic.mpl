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

SpanStatic: [
  data: size:;;
  @data Ref size toSpanStatic2
];

toSpanStatic: [Text same] [
  text:;
  text storageAddress Nat8 Cref addressToReference text textSize Int32 cast toSpanStatic2
] pfunc;

toSpanStatic: [isCombined] [
  struct:;
  0 dynamic @struct @ struct fieldCount toSpanStatic2 # [dynamic] is used to check for non-homogeneous tuples
] pfunc;

toSpanStatic: ["toSpanStatic" has] [.toSpanStatic] pfunc;

toSpanStatic2: [
  spanData: spanSize:;;
  {
    SCHEMA_NAME: "SpanStatic" virtual;

    ASSIGN: [
      other:;
      other.@spanData !spanData
    ];

    DIE: [];

    INIT: [
      @spanData Ref !spanData
    ];

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
      {
        SCHEMA_NAME: "SpanStaticIter" virtual;
        data: @spanData;
        size: spanSize;

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

    toSpan: [
      "Span.toSpan2" use
      @spanData spanSize toSpan2
    ];

    toSpanStatic: [
      @spanData spanSize toSpanStatic2
    ];

    toStringView: [
      "String.toStringView" use
      (spanData spanSize) toStringView
    ];

    # Private

    spanData: @spanData;
    spanSize: spanSize new virtual;
  }
];
