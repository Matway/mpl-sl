@ECHO OFF

RMDIR /S /Q out 2>NUL
MD          out 2>NUL
CHCP 65001

REM TODO: Do the first two tasks in parallel
"%1" .github/workflows/processTests.mpl -D DEBUG=TRUE -D MPLC=\"%1\" -D PLATFORM=\"windows\" -I "" -I windows -ndebug -o out/processTests.ll && clang -O0 -o out/processTests.exe atomic.ll out/processTests.ll^
  && "%1" .github/workflows/sequentialTasks.mpl -D DEBUG=TRUE -D MPLC=\"%1\" -D PLATFORM=\"windows\" -I "" -I windows -ndebug -o out/sequentialTasks.ll && clang -O0 -o out/sequentialTasks.exe atomic.ll out/sequentialTasks.ll^
  && "out/processTests"
