"String"           use
"control"          use
"sync/syncPrivate" use

f: [n: Int32 addressToReference;
  n [
    i print LF print
  ] times
];

{} Int32 {} [
  5 storageAddress @f spawnFiber
  @currentFiber.cancel
  6 storageAddress @f spawnFiber
  0
] "main" exportFunction
