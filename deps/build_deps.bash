#!/bin/bash
set -ex

# Move to location of this script
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

cd verilator
unset VERILATOR_ROOT
autoconf
./configure
make -j "$(nproc)"
