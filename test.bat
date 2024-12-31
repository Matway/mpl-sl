@ECHO OFF

RMDIR /S /Q out 2>NUL
MD          out 2>NUL
CHCP 65001

"%1" .github/workflows/test.mpl -D DEBUG=TRUE -D MPLC=\"%1\" -D SL_MEMORY_MAX_CACHED_SIZE=0nx -I "" -I windows -ndebug -o out/test.ll && clang -O0 -o out/test.exe atomic.ll out/test.ll && "out/test"
