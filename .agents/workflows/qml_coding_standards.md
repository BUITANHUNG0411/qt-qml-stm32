---
name: qt-qml
description: >-
  Applies QML best practices when producing or working with QML source code
  for the Automotive UI Showcase (Qt 6 / QML + STM32). Enforces the project's
  absolute "Zero JavaScript in QML" rule.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
metadata:
  author: qt-ai-skills
  version: "1.1"
  qt-version: "6.x"
  category: conceptual
---

# QML Coding Skill (Automotive UI Showcase)

## 1. Absolute ban on JavaScript logic in .qml files (HARD RULE)
- **Forbidden**: `function`, `if`, `for`, `while`, `switch`, `var`, `let`, `const`, or inline JS blocks.
- **Allowed**:
  - Declarative Property Bindings (`prop: expression`).
  - `Q_INVOKABLE` calls to C++ for actions.
  - Declarative `States`, `Transitions`, `Behavior`, and `NumberAnimation`.
- **All logic lives in C++**: ViewModels expose state via `Q_PROPERTY` + `NOTIFY`. Services expose behaviour via `Q_INVOKABLE`.
- **Pre-flight**: Before finishing any QML work, grep for JS keywords and fail if any exist. QML must be a "dumb view".

## 2. QML is a view only
QML renders, animates, and typesets. It must not hold business state, parse serial frames, or perform calculations. The same QML must work unchanged regardless of whether the backend uses `SimulatorService` or `SerialService`.

## 3. General QML Rules
- **main.qml**: Bootstrap file only. No business logic, no deep nested trees.
- **Extract components**: Extract heavily on reuse, responsibility, or depth (>3 levels).
- **Imports (Qt 6)**: Do not use version numbers. Use specific imports (e.g., `QtQuick.Controls.Basic`) ONLY when customizing a control style directly in that file.
- **Loaders**: Use `Loader` for conditional UI. Use `Loader.asynchronous: true` for heavy components.
- **Property bindings**: No circular dependencies. Prefer declarative bindings. Avoid imperative `=` assignment which destroys bindings.
- **Layouts**: Never mix `anchors` and `Layout.*` on the same item. Use `Layout.*` properties for any item inside a Layout.
- **ListView**: Use `required property` for model roles. Keep delegates minimal. No mutable JS variables in delegates.
- **State Management**: Use `states` for discrete configurations, targeting transitions with `from` and `to`.
- **Animations**: Stop animations when off-screen. Avoid animating `width`/`height` on complex subtrees (animate `scale` instead).
- **Images**: Always set `sourceSize`. Use `asynchronous: true` for large files. Prefer SVG for icons.
- **Performance**: Avoid `clip: true` unless strictly necessary. Minimize `MultiEffect` usage by disabling when inactive. Prefer `Item` over a transparent `Rectangle`.
