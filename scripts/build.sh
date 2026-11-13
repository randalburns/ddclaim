#!/bin/sh
# Build the command (bin/ddclaim), the benchmark and checker (bin/bench), the batch-size
# measurement (bin/batch_sizes) and the thread check (bin/threads). (build/ is for generated data: the tables and cached
# reference answers.)
#
# Needs an x86-64 CPU with AVX-512 and BMI2 (the build uses -march=native). Set CXX to change
# the compiler.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
mkdir -p bin build
if [ -z "${CXX:-}" ]; then
  CXX="clang++"
  # Some machines' clang picks a GCC without C++ headers unless told otherwise.
  [ -d /usr/lib/gcc/x86_64-linux-gnu/13 ] && CXX="clang++ --gcc-install-dir=/usr/lib/gcc/x86_64-linux-gnu/13"
fi
# shellcheck disable=SC2086
FLAGS="-std=c++20 -O3 -DNDEBUG -march=native -Wall -Iinclude"
$CXX $FLAGS -c src/ddclaim.cpp -o bin/ddclaim.o
$CXX $FLAGS tools/ddclaim_cli.cpp bin/ddclaim.o -pthread -o bin/ddclaim
$CXX $FLAGS -Itest test/bench.cpp bin/ddclaim.o -pthread -o bin/bench
$CXX $FLAGS test/batch_sizes.cpp bin/ddclaim.o -pthread -o bin/batch_sizes
$CXX $FLAGS test/threads.cpp bin/ddclaim.o -pthread -o bin/threads
