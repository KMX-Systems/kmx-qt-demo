#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

resolve_compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD=(docker compose)
    return
  fi

  cat >&2 <<'EOF'
Error: Docker Compose v2 is required on this machine.

Install Docker Compose plugin and re-run this script:
  sudo apt-get install -y docker-compose-plugin

Then verify with:
  docker compose version
EOF
  exit 1
}

resolve_compose_cmd

# Allow container root to connect to host X server for GUI output.
xhost +si:localuser:root >/dev/null
cleanup() {
  xhost -si:localuser:root >/dev/null
}
trap cleanup EXIT

"${COMPOSE_CMD[@]}" up -d qt-dev >/dev/null

if [[ "${USE_SOFTWARE_RENDERING:-0}" == "1" ]]; then
  "${COMPOSE_CMD[@]}" exec qt-dev bash -lc 'export LIBGL_DRI3_DISABLE=${LIBGL_DRI3_DISABLE:-1} LIBGL_ALWAYS_SOFTWARE=1 QT_QUICK_BACKEND=software QSG_RHI_BACKEND=software; /workspace/build/appqtdemo'
else
  "${COMPOSE_CMD[@]}" exec qt-dev bash -lc 'export LIBGL_DRI3_DISABLE=${LIBGL_DRI3_DISABLE:-1}; /workspace/build/appqtdemo'
fi
