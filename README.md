# TempeHS C++ DevContainer

A ready-to-go GitHub Codespace / Dev Container for writing **desktop C++ applications** and
compiling them for **Linux**, **Windows** and **macOS** from a single environment.

| Target  | How it is built                                           | How you test it                                   |
| ------- | --------------------------------------------------------- | ------------------------------------------------- |
| Linux   | Natively with GCC/Clang                                   | Run it in the terminal or the virtual desktop     |
| Windows | Cross-compiled with **MinGW-w64** (static `.exe`)         | Run it with **Wine** inside the virtual desktop   |
| macOS   | Natively on a Mac, or automatically by **GitHub Actions** | Download the artifact from the Actions run        |

The container also ships a **virtual desktop** (noVNC in your browser) so you can see windowed
applications – including Windows `.exe` files running under Wine – without leaving the Codespace.

---

## Contents

1. [Quick start](#1-quick-start)
2. [What's installed](#2-whats-installed)
3. [Project layout](#3-project-layout)
4. [Building](#4-building)
   - [Linux](#41-linux)
   - [Windows (cross-compile)](#42-windows-cross-compile)
   - [macOS](#43-macos)
5. [Testing in the virtual desktop (virtual window)](#5-testing-in-the-virtual-desktop-virtual-window)
6. [Debugging](#6-debugging)
7. [Using this template for your own project](#7-using-this-template-for-your-own-project)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Quick start

1. Click **Code ▸ Codespaces ▸ Create codespace on main** (or open the folder in VS Code and
   choose **Reopen in Container**).
2. Wait for the container to build. The first build takes a few minutes while
   [`.devcontainer/setup.sh`](.devcontainer/setup.sh) installs the toolchains.
3. Open a terminal (`` Ctrl+` ``) and build + run the sample for every target you can build here:

   ```bash
   # Linux
   cmake --preset linux-debug && cmake --build --preset linux-debug
   ./build/linux-debug/hello

   # Windows (cross-compiled, then run with Wine)
   cmake --preset windows-release && cmake --build --preset windows-release
   wine ./build/windows-release/hello.exe
   ```

   Expected output:

   ```text
   Hello, World!
   Built for: Linux        (or "Windows" for the .exe)
   Compiler:  GCC 13.3
   ```

4. Press **F5** to build and debug the Linux version with breakpoints.

---

## 2. What's installed

Everything below is installed automatically by the devcontainer:

| Tool                                                   | Purpose                                           |
| ------------------------------------------------------ | ------------------------------------------------- |
| GCC 13, Clang, GDB, CMake 3.28, Ninja                  | Native Linux build + debug                        |
| `clangd`, `clang-format`                               | IntelliSense, diagnostics and auto-formatting     |
| `mingw-w64` (`x86_64-w64-mingw32-g++`, POSIX threads)  | Cross-compile 64-bit Windows executables          |
| Wine (64-bit)                                          | Run the Windows `.exe` inside the container       |
| Qt 6, GTK 3, wxWidgets 3.2, SDL2, Mesa/OpenGL          | Linux GUI frameworks for desktop apps             |
| `desktop-lite` feature (Fluxbox + TigerVNC + noVNC)    | The browser-based **virtual desktop**             |
| `xterm`                                                | Terminal window inside the virtual desktop        |

**VS Code extensions** (see [`.vscode/extensions.json`](.vscode/extensions.json)):
C/C++ Extension Pack, CMake Tools, clangd, Clang-Format, CodeLLDB, GitLens, GitHub Pull Requests,
GitHub Actions.

---

## 3. Project layout

```text
.
├── .devcontainer/
│   ├── devcontainer.json       # Container image, features, ports, extensions, settings
│   └── setup.sh                # Installs toolchains, GUI libs, MinGW-w64 and Wine
├── .github/workflows/build.yml # CI: builds Linux + Windows on Ubuntu and macOS on a Mac runner
├── .vscode/
│   ├── extensions.json         # Recommended extensions
│   ├── settings.json           # clangd / CMake Tools / formatting settings
│   ├── tasks.json              # Build & run tasks (Ctrl+Shift+B)
│   └── launch.json             # GDB debug configurations (F5)
├── cmake/
│   └── toolchain-mingw-w64.cmake  # CMake toolchain for Windows cross-compiling
├── src/
│   └── main.cpp                # Hello World sample
├── CMakeLists.txt              # Project definition
├── CMakePresets.json           # linux-*, windows-*, macos-* presets
└── .clang-format               # Code style
```

Build output always goes to `build/<preset-name>/`, e.g. `build/windows-release/hello.exe`.

---

## 4. Building

All builds are driven by [`CMakePresets.json`](CMakePresets.json). You can use them from:

- **The terminal** – `cmake --preset <name> && cmake --build --preset <name>`
- **VS Code tasks** – `Ctrl+Shift+B` (or *Terminal ▸ Run Task…*) and pick a `Build:` task
- **CMake Tools** – click the preset name in the status bar to switch target, then click **Build**

| Preset            | Output                             | Notes                                   |
| ----------------- | ---------------------------------- | --------------------------------------- |
| `linux-debug`     | `build/linux-debug/hello`          | Default. Used by F5 debugging & clangd  |
| `linux-release`   | `build/linux-release/hello`        | Optimised                               |
| `windows-release` | `build/windows-release/hello.exe`  | Static 64-bit `.exe`, no DLLs required  |
| `windows-debug`   | `build/windows-debug/hello.exe`    | Debug build of the above                |
| `macos-release`   | `build/macos-release/hello`        | **Only on a Mac / GitHub Actions**      |

Build **Linux and Windows in one go**:

```bash
cmake --workflow --preset linux-release && cmake --workflow --preset windows-release
```

### 4.1 Linux

```bash
cmake --preset linux-debug
cmake --build --preset linux-debug
./build/linux-debug/hello
```

### 4.2 Windows (cross-compile)

```bash
cmake --preset windows-release
cmake --build --preset windows-release
file build/windows-release/hello.exe     # → PE32+ executable (console) x86-64, for MS Windows
wine build/windows-release/hello.exe     # run it right here
```

The toolchain file [`cmake/toolchain-mingw-w64.cmake`](cmake/toolchain-mingw-w64.cmake) statically
links `libstdc++`, `libgcc` and `libwinpthread`, so the resulting `.exe` runs on a clean Windows PC
without any extra DLLs. Download it from the Explorer (right-click ▸ *Download*) and double-click it
on Windows to verify.

> **Windows GUI apps:** add `WIN32` to `add_executable(...)` (or set `WIN32_EXECUTABLE` on the
> target) to hide the console window. For Qt/wxWidgets/SDL Windows builds you will need the
> MinGW-built versions of those libraries (e.g. via [vcpkg](https://vcpkg.io) or
> [MXE](https://mxe.cc)); the Linux `-dev` packages installed here cannot be linked into a `.exe`.

### 4.3 macOS

Apple's SDK licence does not allow it to be redistributed, so macOS binaries **cannot be built
inside this Linux container**. Two supported options:

1. **GitHub Actions (recommended).** [`.github/workflows/build.yml`](.github/workflows/build.yml)
   builds a universal (`arm64` + `x86_64`) binary on a `macos-latest` runner on every push to `main`
   and on pull requests. Open the **Actions** tab ▸ latest run ▸ **Artifacts** ▸
   `hello-macos-universal`. You can also trigger it manually with **Run workflow**.
2. **On a Mac.** Clone the repository, install Xcode Command Line Tools, CMake and Ninja
   (`brew install cmake ninja`), then:

   ```bash
   cmake --preset macos-release
   cmake --build --preset macos-release
   ./build/macos-release/hello
   ```

---

## 5. Testing in the virtual desktop (virtual window)

Codespaces have no screen, so the container runs a lightweight X11 desktop (Fluxbox) behind a VNC
server and exposes it in your browser via noVNC. Any program that opens a window – a Linux GTK/Qt
app, or a Windows `.exe` running under Wine – appears there.

### 5.1 Open the virtual desktop

1. Open the **Ports** panel in VS Code (*View ▸ Ports* or the Ports tab next to the terminal).
2. Find port **6080 – Virtual Desktop (noVNC)** and click the 🌐 globe icon
   (it may also open automatically when the Codespace starts).
3. Click **Connect** in the noVNC page and enter the password **`vscode`**.

You now have a full desktop in a browser tab. Right-click the desktop background for the Fluxbox
menu (it includes a terminal).

> Tip: drag the browser tab to a second monitor, or use VS Code's **Simple Browser**
> (`Ctrl+Shift+P` ▸ *Simple Browser: Show* ▸ `http://localhost:6080`) to see it side-by-side
> with your code.

### 5.2 Run your Linux app in the virtual desktop

The VS Code terminal already has `DISPLAY=:1`, so a GUI app launched from the terminal just appears
in the desktop:

```bash
./build/linux-debug/my-gui-app
```

For a **console** program such as the sample, open it inside an xterm window so you can see the
output on the desktop:

```bash
xterm -hold -e ./build/linux-debug/hello &
```

(or run the task **Run: Linux build in virtual desktop (xterm)**).

### 5.3 Run your Windows `.exe` in the virtual desktop

Wine translates Windows API calls to Linux and renders Windows windows onto the X11 desktop:

```bash
# Console apps – output appears in the VS Code terminal
wine ./build/windows-release/hello.exe

# Same, but inside a window on the virtual desktop
xterm -hold -e wine ./build/windows-release/hello.exe &

# A Windows GUI app simply appears on the desktop
wine ./build/windows-release/my-gui-app.exe
```

(or run the task **Run: Windows build in virtual desktop (Wine + xterm)**).

The first Wine launch after a rebuild may take ~10 s while it refreshes its prefix. Wine is a
good smoke test but not a substitute for a real Windows machine – always do a final check on
Windows before shipping.

### 5.4 Change the desktop resolution

The desktop defaults to 1440×768. To change it, set `VNC_RESOLUTION` before the desktop starts,
e.g. add to `containerEnv` in [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json):

```json
"VNC_RESOLUTION": "1920x1080x24"
```

then **Rebuild Container**.

---

## 6. Debugging

- Press **F5** (*Debug Linux build (gdb)*). It builds `linux-debug` first, then launches the
  program under GDB with breakpoints, watch and call stack support.
- Use **Debug Linux build (CMake Tools target)** if you have several executables and want to debug
  whichever target is selected in the CMake Tools status bar.
- GUI apps launched from the debugger also appear in the virtual desktop (`DISPLAY=:1` is set in
  [`.vscode/launch.json`](.vscode/launch.json)).

Windows builds cannot be source-debugged here; debug the Linux build (same code) instead, and use
Wine only to confirm the `.exe` runs.

---

## 7. Using this template for your own project

1. Click **Use this template** on GitHub, or copy `.devcontainer/`, `.vscode/`, `cmake/`,
   `CMakeLists.txt`, `CMakePresets.json` and `.clang-format` into your repo.
2. Edit [`CMakeLists.txt`](CMakeLists.txt): rename `project(...)`, replace `src/main.cpp` with your
   sources, and `target_link_libraries(...)` any frameworks you use, e.g.

   ```cmake
   find_package(Qt6 REQUIRED COMPONENTS Widgets)
   add_executable(myapp WIN32 MACOSX_BUNDLE src/main.cpp)
   target_link_libraries(myapp PRIVATE Qt6::Widgets)
   ```

3. Update the executable name in [`.vscode/tasks.json`](.vscode/tasks.json),
   [`.vscode/launch.json`](.vscode/launch.json) and
   [`.github/workflows/build.yml`](.github/workflows/build.yml) (search for `hello`).

---

## 8. Troubleshooting

| Problem                                                     | Fix                                                                                                                              |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| noVNC page shows "Failed to connect"                        | The desktop takes ~20 s to start after the container boots. Refresh. Still broken? Run `/usr/local/share/desktop-init.sh`.       |
| `cannot open display` / app window never appears            | Run `export DISPLAY=:1` in that terminal, or open a new VS Code terminal.                                                        |
| `wine: command not found` or `x86_64-w64-mingw32-g++` missing | `setup.sh` did not finish. Run `bash .devcontainer/setup.sh` manually and check for errors.                                   |
| `.exe` complains about missing `libstdc++-6.dll` on Windows | You built without the toolchain file. Use `cmake --preset windows-release`.                                                     |
| clangd shows errors for every header                        | Build `linux-debug` once so `build/linux-debug/compile_commands.json` exists, then *clangd: Restart language server*.            |
| `std::thread` fails to link in the Windows build            | The POSIX MinGW variant must be selected – `setup.sh` does this; re-run it if needed.                                           |
| Codespace is slow                                           | Machine type must be ≥ 4 cores / 8 GB (set in `hostRequirements`). Change it under *Codespaces ▸ … ▸ Change machine type*.      |
