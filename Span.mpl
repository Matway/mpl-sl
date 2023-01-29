"control.Natx" use
"control.Ref" use
"control.assert" use
"control.between" use
"control.dup" use
"control.isBuiltinTuple" use
"control.pfunc" use
"control.when" use
"control.within" use

Span: [
  data:;
  @data Ref 0 toSpan2
];

toSpan: [isBuiltinTuple] [
  tuple:;
  0 dynamic @tuple @ @tuple fieldCount toSpan2 # [dynamic] is used to check for non-homogeneous tuples
] pfunc;

toSpan2: [
  data: size:;;
  {
    SCHEMA_NAME: "Span" virtual;
    data: @data;
    size: size new;

    assign: [
      span:;
      @span.@data !data
      span.size @size set # [set] is used to support StaticSpan
    ];

    at: [
      key:;
      [key 0 size within] "key is out of bounds" assert
      @data storageAddress @data storageSize key Natx cast * + @data addressToReference
    ];

    iter: [
      {
        SCHEMA_NAME: "SpanIter" virtual;
        data: @data;
        size: size new;

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
        SCHEMA_NAME: "SpanReverseIter" virtual;
        data: @data storageAddress @data storageSize size Natx cast * + @data storageSize - @data addressToReference;
        size: size new;

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
      @data storageAddress @data storageSize offset Natx cast * + @data addressToReference sliceSize toSpan2
    ];

    toArrayRange: [
      "Array.makeArrayRangeRaw" use
      size data makeArrayRangeRaw
    ];

    toStaticSpan: [
      "StaticSpan.toStaticSpan2" use
      @data size toStaticSpan2
    ];
  }
];
