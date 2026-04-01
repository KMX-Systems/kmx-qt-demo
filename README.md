# KMX Qt Demo

This repository contains a Qt Quick + C++ demo app that is built and run inside:

- `dalogik/qt-docker:qt6.11.0-linux64-gcc`

The app uses a **fake/simulated C++ backend engine** for demo behavior (not a real production backend).

## Project structure

- `CMakeLists.txt` - Qt 6.11 CMake project
- `src/main.cpp` - C++ app bootstrap
- `src/Engine.h/.cpp` - fake C++ backend engine exposed to QML
- `qml/Main.qml` - demo UI
- `docker-compose.yml` - dev container service
- `scripts/container-build-run.sh` - one-command build and run helper

## Architecture: QML + fake C++ engine

- `Engine` is injected into QML as context property `engine` in `src/main.cpp`.
- QML reads `Q_PROPERTY` values such as workload, users, alerts, and models.
- QML calls C++ `Q_INVOKABLE` methods such as `postEvent(...)`, `applyConfig(...)`, `runJob(...)`, `resetSystem()`, `weeklyStats()`, and `setLanguage(...)`.

## Prerequisites

- Docker installed and running
- Docker Compose v2 plugin (`docker compose`)
- X11 on Linux for GUI forwarding

## Docker installation under Ubuntu

If you are on Ubuntu 24.04, run the following commands to install Docker Engine and Docker Compose plugin.

1. Remove old/conflicting Docker packages (safe if not installed):

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y "$pkg"
done
```

1. Set up Docker's apt repository:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

1. Install Docker Engine + Compose plugin:

```bash
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

1. Enable and start Docker:

```bash
sudo systemctl enable --now docker
```

1. Allow your user to run Docker without `sudo`:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

1. Verify installation:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

## Build and run (recommended)

```bash
chmod +x scripts/container-build-run.sh
./scripts/container-build-run.sh
```

## Enter container shell

```bash
chmod +x scripts/enter-container.sh
./scripts/enter-container.sh
```

## Reuse container with helper scripts

Use these scripts for a faster reuse workflow:

1. Start container once

```bash
chmod +x scripts/container-start.sh
./scripts/container-start.sh
```

1. Enter shell anytime

```bash
chmod +x scripts/container-enter.sh
./scripts/container-enter.sh
```

1. Run existing app binary without rebuilding

```bash
chmod +x scripts/container-run-only.sh
./scripts/container-run-only.sh
```

Optional software fallback:

```bash
USE_SOFTWARE_RENDERING=1 ./scripts/container-run-only.sh
```

## Scripts to run inside container

After entering the container shell, use:

```bash
cd /workspace
./scripts/in-container/configure-build.sh
./scripts/in-container/run-app.sh
```

Optional software fallback inside container:

```bash
USE_SOFTWARE_RENDERING=1 ./scripts/in-container/run-app.sh
```

Clean build output inside container:

```bash
./scripts/in-container/clean-build.sh
```

This script will:

1. Allow Docker access to your local X server
2. Start the `qt-dev` container
3. Configure and build with CMake + Ninja inside the container
4. Launch the app from inside the container
5. Revoke X server access when you exit

The container is configured for GPU rendering by default via `/dev/dri` passthrough.
If your host GPU stack is unstable, run with software fallback:

```bash
USE_SOFTWARE_RENDERING=1 ./scripts/container-build-run.sh
```

In software fallback mode, the app is forced to `llvmpipe`.
The `WrapVulkanHeaders` message during CMake configure is non-fatal for this demo.

## Manual workflow

```bash
xhost +si:localuser:root
docker compose up -d qt-dev
docker compose exec qt-dev bash -lc 'cmake -S /workspace -B /workspace/build -G Ninja'
docker compose exec qt-dev bash -lc 'cmake --build /workspace/build -j"$(nproc)"'
docker compose exec qt-dev bash -lc '/workspace/build/appqtdemo'
xhost -si:localuser:root
```

## Stop container

```bash
docker compose down
```
