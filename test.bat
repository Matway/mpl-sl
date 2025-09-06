@ECHO OFF

RMDIR /S /Q out 2>NUL
MD          out 2>NUL
CHCP 65001

REM TODO: Do the first two tasks in parallel
"%1" .github/workflows/test.mpl -D DEBUG=TRUE -D MPLC=\"%1\" -D PLATFORM=\"windows\" -I "" -I windows -ndebug -o out/test.ll && clang -O0 -o out/test.exe atomic.ll out/test.ll^
  && "%1" .github/workflows/sequentialTasks.mpl -D DEBUG=TRUE -I "" -I windows -ndebug -o out/sequentialTasks.ll && clang -O0 -o out/sequentialTasks.exe atomic.ll out/sequentialTasks.ll^
  && "out/test"
