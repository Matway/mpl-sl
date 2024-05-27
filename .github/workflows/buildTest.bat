@ECHO OFF

MD build 2>NUL

"%1" .github/workflows/test.mpl -D DEBUG=TRUE -D MPLC=\"%1\" -D SL_MEMORY_MAX_CACHED_SIZE=0nx -I "" -I windows -ndebug -o build/test.ll && clang -O0 -o build/test.exe atomic.ll build/test.ll
