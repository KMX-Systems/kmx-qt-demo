#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-/workspace}"
BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
GENERATOR="${GENERATOR:-Ninja}"

cd "$PROJECT_ROOT"

cmake -S "$PROJECT_ROOT" -B "$BUILD_DIR" -G "$GENERATOR"
cmake --build "$BUILD_DIR" -j"$(nproc)"

echo "Build complete: $BUILD_DIR/appqtdemo"
