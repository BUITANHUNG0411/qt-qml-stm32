# 📋 Tasks Board (Vibe Coding Progress)

> **AI Context**: The source of truth for current project status. Mark tasks as `[x]` when verified.

## Phase 0: Project Scaffold (CMake & Arch)
- [x] CMakeLists.txt standardized to Qt 6.8+ (`qt_standard_project_setup`).
- [x] Directory structure established.
- [x] Documentation perfectly formatted for AI parsing.

## Phase 1: MVVM Core & Testing
- [x] Set up `tests/` directory and QtTest framework.
- [x] Implement `VehicleStatusViewModel` with TDD (tests first).
- [x] Ensure `main.cpp` uses `engine.loadFromModule()`.

## Phase 2: QML Shell & UI Guidelines
- [x] Define `Theme.qml` singleton with Cyberpunk design tokens.
- [x] Build QML Main Shell using pure property bindings (Zero JS).
- [x] Run `qt-qml-review` to verify compliance.

## Phase 3: Hardware Simulation (C++)
- [x] Build `SimulatorService` with `QTimer` telemetry generation.
- [x] Wire `SimulatorService` to `VehicleStatusViewModel`.

## Phase 4: STM32 Integration
- [x] Build `SerialService` parsing logic.
- [x] Ensure seamless swap with `SimulatorService` in C++.
- [x] Document final architecture layout.

## Phase 5: Holographic Dashboard (Neon Cyberpunk 3-Panel)
- [x] Update C++ `VehicleStatusViewModel` (Battery, Range, Temp).
- [x] Update `SimulatorService` to generate mock data.
- [x] Implement `CircularGauge.qml` using `QtQuick.Shapes` (Approach A).
- [x] Implement `GlassPanel.qml` and `DashboardScreen.qml`.
- [x] Integrate into `Main.qml`.

## Phase 6: Advanced Mock Engine (Physics & Scenarios)
- [x] Create `MockScenarioEngine` class.
- [x] Implement realistic kinematics (Drag Race, Battery Drain).
- [x] Refactor `SimulatorService` to use `MockScenarioEngine`.
- [x] Update `CMakeLists.txt` and verify build.

## Phase 7: Dynamic Hardware Fallback
- [x] Expose `connectionStatusChanged` from `SerialService`.
- [x] Remove static `#define USE_SIMULATOR`.
- [x] Implement runtime switching logic in `main.cpp`.
