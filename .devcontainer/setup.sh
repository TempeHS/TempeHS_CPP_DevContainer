#!/usr/bin/env bash
# Post-create setup for the C++ Desktop devcontainer.
# Installs Linux GUI development libraries, the MinGW-w64 Windows
# cross-compiler, and Wine so Windows builds can be test-run inside the
# virtual desktop (noVNC).
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Installing build tools, GUI libraries and cross-compilers"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential cmake ninja-build gdb clang clangd clang-format \
  qt6-base-dev qt6-tools-dev libgtk-3-dev libwxgtk3.2-dev libsdl2-dev \
  libgl1-mesa-dev mesa-utils \
  mingw-w64 wine wine64 \
  xterm

echo "==> Selecting POSIX-threads MinGW variant (required for std::thread)"
sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
sudo update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix

echo "==> Initialising 64-bit Wine prefix"
export WINEARCH=win64
export WINEDEBUG=-all
wineboot --init >/dev/null 2>&1 || true

sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo
echo "==> Toolchain summary"
g++ --version | head -n 1
x86_64-w64-mingw32-g++ --version | head -n 1
cmake --version | head -n 1
wine --version
echo
echo "Setup complete. Open the forwarded port 6080 (password: vscode) for the virtual desktop."
