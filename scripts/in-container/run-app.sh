#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-/workspace}"
BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
APP_PATH="${APP_PATH:-$BUILD_DIR/appqtdemo}"

if [[ ! -x "$APP_PATH" ]]; then
  echo "App binary not found or not executable at: $APP_PATH" >&2
  echo "Run scripts/in-container/configure-build.sh first." >&2
  exit 1
fi

if [[ -z "${DISPLAY:-}" ]]; then
  echo "DISPLAY is not set inside container." >&2
  echo "Enter via scripts/container-enter.sh from host (it sets X11 permissions)." >&2
  exit 1
fi

export LIBGL_DRI3_DISABLE="${LIBGL_DRI3_DISABLE:-1}"

if [[ "${USE_SOFTWARE_RENDERING:-0}" == "1" ]]; then
  export LIBGL_ALWAYS_SOFTWARE=1
  export QT_QUICK_BACKEND=software
  export QSG_RHI_BACKEND=software
fi

exec "$APP_PATH"
