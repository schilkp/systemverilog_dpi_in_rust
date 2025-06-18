#!/bin/bash
set -e

# Move to location of this script
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

VERILATOR_ROOT=$(realpath "$SCRIPT_DIR/deps/verilator")
VERILATOR="$VERILATOR_ROOT/bin/verilator"

if [ ! -f "$VERILATOR_ROOT/bin/verilator_bin" ]; then
    echo ""
    echo "Building verilator ..."
    cd deps && ./build_deps.bash && cd ..
else
    echo ""
    echo "Verilator already built."
fi

echo ""
echo "Verilating ..."
VERILATOR_ROOT="$VERILATOR_ROOT" \
    "$VERILATOR" \
    --cc \
    --build \
    -j 0 \
    -Wall -Wno-fatal -Wno-lint \
    -Werror-IMPLICIT \
    --assert \
    --trace-fst \
    --trace-structs \
    --threads 1 \
    ./test.sv \
    --top-module top

echo ""
echo "Building rust lib ..."
cd ./rusty_foo/ && RUST_FOO_SVDPI_INCLUDE="$VERILATOR_ROOT/include/vltstd" cargo build --release && cd ..

echo ""
echo "Building + linking..."
g++ \
    -I"$VERILATOR_ROOT"/include \
    -I"$VERILATOR_ROOT"/include/vltstd \
    -I./obj_dir \
    -I./c_foo/ \
    -o top \
    -g \
    -DDUMPFILE="\"dump.fst\"" \
    top.cc \
    ./c_foo/dpi.c \
    -Wall -Wextra -Wpedantic -Wno-sign-compare -Wno-unused-parameter -Wno-format \
    -fcoroutines \
    ./obj_dir/Vtop__ALL.a \
    ./rusty_foo/target/release/librusty_foo.a \
    "$VERILATOR_ROOT"/include/verilated.cpp \
    "$VERILATOR_ROOT"/include/verilated_timing.cpp \
    "$VERILATOR_ROOT"/include/verilated_dpi.cpp \
    "$VERILATOR_ROOT"/include/verilated_fst_c.cpp \
    "$VERILATOR_ROOT"/include/verilated_threads.cpp \
    -lz

echo ""
echo "Running ..."
./top
