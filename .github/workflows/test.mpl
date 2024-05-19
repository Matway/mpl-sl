"Array"          use
"AvlMap"         use
"CommandLine"    use
"Deque"          use
"Function"       use
"HashTable"      use
"IntrusiveDeque" use
"IntrusiveQueue" use
"IntrusiveStack" use
"Json"           use
"Mref"           use
"Owner"          use
"Pool"           use
"Pose"           use
"PriorityQueue"  use
"Quaternion"     use
"RandomLCG"      use
"Span"           use
"SpanStatic"     use
"Spinlock"       use
"String"         use
"Union"          use
"Variant"        use
"Xml"            use
"algebra"        use
"algorithm"      use
"ascii"          use
"atomic"         use
"control"        use
"conventions"    use
"file"           use
"interface"      use
"lockGuard"      use
"memory"         use
"murmurHash"     use
"objectTools"    use
"sha1"           use

"sync/Context"      use
"sync/ContextGroup" use
"sync/Event"        use
"sync/Signal"       use

"windows/ConditionVariable"   use
"windows/Mutex"               use
"windows/Process"             use
"windows/TcpAcceptor"         use
"windows/TcpConnection"       use
"windows/Thread"              use
"windows/dispatcher"          use
"windows/errno"               use
"windows/gdi32"               use
"windows/hardwareConcurrency" use
"windows/kernel32"            use
"windows/ole32"               use
"windows/opengl32"            use
"windows/runningTime"         use
"windows/shell32"             use
"windows/unicode"             use
"windows/user32"              use
"windows/winmm"               use
"windows/ws2_32"              use

"windows/sync/TcpAcceptor"   use
"windows/sync/TcpConnection" use
"windows/sync/sync"          use
"windows/sync/syncPrivate"   use

"tests/universal/CommandLineTest"  use
"tests/universal/ContextGroupTest" use
"tests/universal/ContextTest"      use
"tests/universal/EventTest"        use
"tests/universal/FunctionTest"     use
"tests/universal/PoseTest"         use
"tests/universal/QuaternionTest"   use
"tests/universal/SignalTest"       use
"tests/universal/SpanStaticTest"   use
"tests/universal/SpanTest"         use
"tests/universal/algorithmTest"    use
"tests/universal/controlTest"      use
"tests/universal/objectToolsTest"  use
"tests/universal/objectTraitTest"  use
"tests/universal/syncTest"         use

{} 0i32 {} [
  "\nAll tests passed\n" print

  0
] "main" exportFunction
