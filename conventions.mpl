0nx storageSize 8nx = [
  cdecl:   { CALL: [""]; };
  stdcall: { CALL: [""]; };
] [
  cdecl:   { CALL: ["ccc"]; };
  stdcall: { CALL: ["x86_stdcallcc"]; };
] uif

copyOld:    [copy   ];
isMovedOld: [isMoved];
moveOld:    [move   ];
moveIfOld:  [moveIf ];
setOld:     [set    ];
