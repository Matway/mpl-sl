# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.Natx"           use
"control.Ref"            use
"control.assert"         use
"control.between"        use
"control.dup"            use
"control.isBuiltinTuple" use
"control.pfunc"          use
"control.when"           use
"control.within"         use

StaticSpan: [
  data: size:;;
  @data Ref size toStaticSpan2
];

toStaticSpan: [isBuiltinTuple] [
  tuple:;
  0 dynamic @tuple @ @tuple fieldCount toStaticSpan2 # [dynamic] is used to check for non-homogeneous tuples
] pfunc;

toStaticSpan2: [
  data: size:;;
  {
    SCHEMA_NAME: "StaticSpan" virtual;
    data: @data;
    size: size new virtual;

    assign: [
      span:;
      [span.size size =] "span sizes are inconsistent" assert
      @span.@data !data
    ];

    at: [
      key:;
      [key 0 size within] "key is out of bounds" assert
      @data storageAddress @data storageSize key Natx cast * + @data addressToReference
    ];

    iter: [
      {
        SCHEMA_NAME: "StaticSpanIter" virtual;
        data: @data;
        size: size;

        next: [
          @data
          size 0 = ~ dup [
            @data storageAddress @data storageSize + @data addressToReference !data
            size 1 - !size
          ] when
        ];
      }
    ];

    reverseIter: [
      {
        SCHEMA_NAME: "StaticSpanReverseIter" virtual;
        data: @data storageAddress @data storageSize size Natx cast * + @data storageSize - @data addressToReference;
        size: size;

        next: [
          @data
          size 0 = ~ dup [
            @data storageAddress @data storageSize - @data addressToReference !data
            size 1 - !size
          ] when
        ];
      }
    ];

    slice: [
      offset: sliceSize:;;
      [offset 0 size between] "offset is out of bounds" assert
      [sliceSize 0 size offset - between] "size is out of bounds" assert
      @data storageAddress @data storageSize offset Natx cast * + @data addressToReference sliceSize toStaticSpan2
    ];

    toSpan: [
      "Span.toSpan2" use
      @data size toSpan2
    ];
  }
];
