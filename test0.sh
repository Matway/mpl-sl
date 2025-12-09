set -eu

mplc=$1

rm -r -f out
mkdir out

platform="linux"
if [[ "$(uname)" == "Darwin" ]]; then
  platform="macos"
fi

$mplc .github/workflows/entryPoint.mpl -D DEBUG=TRUE -D PLATFORM_TESTS=\"${platform}/tests\" -I "" -I "${platform}" -I tests -ndebug -o out/entryPoint.ll
clang out/entryPoint.ll -O0 -lm -o out/entryPoint

time out/entryPoint
