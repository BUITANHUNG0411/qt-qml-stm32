---
name: qt-cmake-project
description: >-
  Use to generate or update Qt 6 CMake projects or edit CMakeLists.txt, add
  sources/resources or define targets (executable, QML module, library) for
  the Automotive UI Showcase (Qt 6 / QML + STM32). 
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
metadata:
  author: qt-ai-skills
  version: "1.0.1"
  qt-version: "6.x"
  category: conceptual
---

# Qt 6 CMake Project Skill

## Hard Rules (Apply to every output)
1. **Use Qt 6 commands**. `qt_add_executable`, `qt_add_library`, `qt_add_qml_module`. Never use `qt5_*` macros.
2. **Always call `qt_standard_project_setup()`** after `find_package(Qt6)`. Do not manually set `CMAKE_AUTOMOC` or `CMAKE_AUTOUIC` when this is present.
3. **Require an explicit minimum Qt version**. `find_package(Qt6 6.8 REQUIRED COMPONENTS ...)`.
4. **Use `qt_add_qml_module()` for any QML**. Never list `.qml` files inside a raw `qt_add_resources` call or hand-written `.qrc` file.
5. **Use TARGET imports**. Use `TARGET <cmake-target>` versions of `qt_add_qml_module` options (`IMPORTS`, `DEPENDENCIES`) to allow arbitrary directory layouts.
6. **Explicit target visibility**. Use `PRIVATE`, `PUBLIC`, or `INTERFACE` intentionally on `target_link_libraries` and `target_include_directories`.
7. **No qmake leftovers**. Do not emit `QT += quick`, `CONFIG += c++17`, etc.
8. **No hand-written `.qrc` for QML**. `qt_add_qml_module` handles this.
9. **C++ Standard**: Set `CMAKE_CXX_STANDARD` and `CMAKE_CXX_STANDARD_REQUIRED ON` *before* `find_package(Qt6)`.
10. **No generated headers manually**: Do not list `moc_*.cpp`, `ui_*.h` manually in sources.

## Project Custom Rules (Automotive UI Showcase)

### 1. Optimise builds for local Linux Mint dev environment
- **Default to Ninja generator**.
- **Set a default build type**:
  ```cmake
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
      set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
  endif()
  ```
- **Export compile commands**: `set(CMAKE_EXPORT_COMPILE_COMMANDS ON)`.
- **Find Qt locally**: Rely on `CMAKE_PREFIX_PATH` / `Qt6_DIR`. No hardcoded Windows paths.
- **Link required modules**: `find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick SerialPort)`.
- **Enable GCC/Clang warnings**: Add `$<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra>`.
- **Out-of-source builds**: Assume `build/` directory structure.

### 2. QML via qt_add_qml_module only
Strictly adhere to the Zero-JS / MVVM architecture by ensuring all QML files pass through the QML module system for C++ ViewModel registration.

## Output Style
- One `CMakeLists.txt` per directory.
- Order: `cmake_minimum_required` -> `project()` -> `CMAKE_CXX_STANDARD` -> `find_package` -> `qt_standard_project_setup` -> targets -> properties -> install.
- One argument per line if more than two arguments.
