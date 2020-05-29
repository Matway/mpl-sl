lowerBound: [
  value: range:;;
  low: 0;
  high: range fieldCount;
  [low high = ~] [
    current: high low - 2 / low +;
    current range @ value < [
      current 1 + !low
    ] [
      current copy !high
    ] if
  ] while

  low
];

upperBound: [
  value: range:;;
  low: 0;
  high: range fieldCount;
  [low high = ~] [
    current: high low - 2 / low +;
    value current range @ < [
      current copy !high
    ] [
      current 1 + !low
    ] if
  ] while

  low
];

binarySearch: [
  value: range:;;
  low: value range lowerBound;
  low range fieldCount = ~ [value low range @ <] &&
];
