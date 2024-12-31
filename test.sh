rm -r -f out
mkdir out

buildTaskProcessor0() {
  set -eu
  mplc .github/workflows/processTests.mpl -D PLATFORM=\"linux\" -I "" -I linux -ndebug -o out/processTests.ll
  clang out/processTests.ll -O0 -o out/processTests
}

buildTaskProcessor1() {
  set -eu
  mplc .github/workflows/sequentialTasks.mpl -I "" -I linux -ndebug -o out/sequentialTasks.ll
  clang out/sequentialTasks.ll -O0 -lm -o out/sequentialTasks
}

buildTaskProcessor0 &
pid0=$!

buildTaskProcessor1 &
pid1=$!

wait $pid0
status0=$?
wait $pid1
status1=$?

if [ $status0 -ne 0 ] || [ $status1 -ne 0 ]; then
  echo "Failed to build Test system"
  exit 1
fi

time out/processTests
