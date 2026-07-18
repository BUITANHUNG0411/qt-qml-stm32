# Music Player UI Design Specification

## Understanding Summary
- **What is being built:** A Music Player UI component (`MusicPlayer.qml`) for the QtStmAutomotiveSimulator.
- **Why it exists:** To provide multimedia playback visualization inside the automotive dashboard.
- **Who it is for:** The driver/user interacting with the digital instrument cluster.
- **Key constraints:** Strict adherence to the "Neon Cyberpunk" aesthetic, zero JavaScript logic in QML, pure declarative bindings.
- **Explicit non-goals:** Backend C++ audio logic is out of scope for this phase. This is purely UI visualization.

## Assumptions
- **Performance:** 3D Cover Flow animation relies on QML `PathView` with property bindings (`scale`, `z`, `opacity`) to ensure 60 FPS on embedded targets without the overhead of a true 3D engine.
- **Resource Loading:** Cover images are loaded asynchronously (`asynchronous: true`) to avoid UI stuttering.

## Decision Log
- **Layout Approach:** Decided to use `PathView` for a 3D Cover Flow instead of hardcoded explicit States.
  - *Alternatives considered:* Hardcoded 3-Item Layout using QML States.
  - *Why chosen:* Provides a native, fluid carousel animation, is scalable if more items are added, and completely avoids complex JS or State transition logic.
- **Control Panel Integration:** Separated into a distinct Glassmorphism panel below the cover art.
  - *Alternatives considered:* Controls floating directly over the cover art.
  - *Why chosen:* Better UX for automotive environments, allowing a wider progress bar and larger touch targets.
- **Neon Aesthetic:** Decided to use static Cyberpunk theme colors (`Theme.primaryColor` / `Theme.accentColor`).
  - *Alternatives considered:* Dynamic colors extracting dominant colors from the current cover art.
  - *Why chosen:* Maintains absolute consistency with the existing dashboard gauges (e.g., NeonTickGauge).

## Final Design Breakdown
### 1. Cover Flow Area (Top 70%)
- **Component:** `PathView` with a custom `Path`.
- **Delegate:** Rounded `Image` (via `OpacityMask`) with a static Neon glow shadow.
- **Animation:** `PathAttribute` drives `scale` (1.0 at center, 0.7 at sides), `opacity` (1.0 at center, 0.5 at sides), and `z` index for the 3D depth illusion.

### 2. Navigation Control Panel (Bottom 30%)
- **Container:** Glassmorphism `Rectangle` with translucent background and subtle borders.
- **Track Info:** Two `Text` elements (Title and Artist) bound to the active item in the `PathView`.
- **Progress Bar:** Thin neon line with a glowing thumb.
- **Media Controls:** `RowLayout` centering Previous, Play/Pause, and Next vector icons with scale-down and neon-flare effects on press.
