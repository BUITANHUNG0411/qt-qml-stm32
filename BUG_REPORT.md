# Deep Bug Hunt — Qt6/C++ MVVM Automotive Dashboard

## 1. Executive Summary
This report consolidates findings from 10 deep specialist subagents targeting Qt6/C++ memory, concurrency, signals/slots, QML Zero-JS enforcement, UI rendering, MVVM architecture, numerics, serial data protocol, multimedia logic, and static/build configuration.

**Severity Summary:**
- **CRITICAL**: 3
- **HIGH**: 6
- **MEDIUM**: 3
- **LOW**: 3

*(Note: Hardware UART port wiring is explicitly out of scope per user requirements.)*

## 2. Prioritized Fix Order
1. **BUG-C-001 (OOM Risk):** Unbounded serial buffer growth in `SerialService::handleReadyRead`.
2. **BUG-C-002 (Thread Racing):** `MusicPlayerViewModel` destructor lifetime race with `QThread`.
3. **BUG-C-003 (Silent Write Failure):** Reconnect loop opens serial port as `ReadOnly`, dropping all writes silently.
4. **BUG-H-001 (Security/Integrity Bypass):** Serial protocol checksum bypass allowing corrupt frames.
5. **BUG-H-002 (Zero-JS Violations):** Remove imperative JavaScript math and logic from QML files (`NeonTickGauge.qml`, `DashboardScreen.qml`, `MusicPlayer.qml`).

## 3. Findings by Severity

### CRITICAL
- **BUG-C-001**: OOM risk due to unbounded `m_buffer` appends.
- **BUG-C-002**: Thread lifetime race condition causing crashes on exit.
- **BUG-C-003**: Hardware reconnection fails to enable writes.

### HIGH
- **BUG-H-001**: Checksum validation bypass.
- **BUG-H-002**: Zero-JS violation in QML bindings (`Math.round`, `%`).
- **BUG-H-003**: Zero-JS violation in imperative `onClicked` handlers.
- **BUG-H-004**: Arithmetic truncation causing invalid serial checksum calculation.
- **BUG-H-005**: Fabricated telemetry in ViewModel (`calcSpeed`).
- **BUG-H-006**: Missing compiler warnings and sanitizers hiding UB.

### MEDIUM
- **BUG-M-001**: Hardcoded battery, range, and temperature overriding simulator states.
- **BUG-M-002**: Auto-play logic breaking UX during library scan.
- **BUG-M-003**: Duplicate property declarations in QML causing flicker.

### LOW
- **BUG-L-001**: Hardcoded magic numbers for layout positioning.
- **BUG-L-002**: `QMediaPlayer::stop()` mid-playback without user intent.
- **BUG-L-003**: Minimal test coverage (~3%).

## 4. Findings by Domain (10 Specialist Chapters)

### 4.1 Memory & Lifetime (memory-lifetime-agent)
**BUG-C-002: Dtor thread racing with `deleteLater`**
- **Location:** `src/viewmodels/MusicPlayerViewModel.cpp:31-33`
- **Snippet:**
  ```cpp
  m_scanner->deleteLater();
  m_scannerThread.quit();
  m_scannerThread.wait();
  ```
- **Why:** Calling `deleteLater()` on an object living in a thread that is immediately ordered to `quit()` and `wait()` means the event loop may not process the deletion before the thread exits, leading to leaks or dangling references.
- **Repro:** Run simulator, scan music, exit application. Static check: Clang Thread Safety.
- **Fix Direction:** Do not use `deleteLater` here; explicitly delete `m_scanner` in the worker thread context or rely on parent ownership appropriately.

### 4.2 Threading & Concurrency (threading-concurrency-agent)
*(Covered primarily by Memory & Lifetime race condition BUG-C-002)*

### 4.3 Qt Signals & Slots (qt-signalslot-agent)
**BUG-L-002: Music scanner stops active playback**
- **Location:** `src/viewmodels/MusicPlayerViewModel.cpp:153`
- **Snippet:** `m_player->stop();`
- **Why:** `scanLibrary()` forcefully stops the current playing track instead of enqueueing or updating the library in the background.
- **Repro:** Play a song, click 'Scan'. Playback halts abruptly.
- **Fix Direction:** Separate the active playback queue from the background scanner model.

### 4.4 QML Zero-JS Compliance (qml-zerojs-agent)
**BUG-H-002: Mathematical JS in bindings**
- **Location:** `qml/screens/DashboardScreen.qml:59`
- **Snippet:** `text: Math.round(vm.speed).toString()`
- **Why:** Violates the strict Zero-JS policy; view should just display pre-calculated strings.
- **Repro:** Code review `qml/**/*.qml` for `Math.*`.
- **Fix Direction:** Move `round()` logic to C++ and expose as a formatted `QString` property `displaySpeed`.

**BUG-H-003: Imperative JS blocks in QML**
- **Location:** `qml/components/MusicPlayer.qml:97-100`
- **Snippet:**
  ```qml
  onClicked: {
      pathView.currentIndex = index
      MusicViewModel.setCurrentIndex(index)
  }
  ```
- **Why:** Logic execution inside QML instead of routing purely to C++.
- **Repro:** `qmllint` or `grep "{"` within `onClicked`.
- **Fix Direction:** C++ should manage the current index completely and expose a single `Q_INVOKABLE selectTrack(int)` command.

### 4.5 QML Layout & Rendering (qml-layout-rendering-agent)
**BUG-M-003: Duplicate property declarations**
- **Location:** `qml/components/NeonTickGauge.qml:71-74` and `95-98`
- **Snippet:**
  `property real tickValue: (index / root.tickCount) * root.maxValue`
- **Why:** Declaring identical heavy mathematical properties twice inside the repeater causes duplicated evaluations and visual flicker during animations.
- **Repro:** Run cluster and observe gauge tick updates.
- **Fix Direction:** Lift the property declarations into the parent `Item` of the repeater delegate and bind both the `Rectangle` and `Text` to them.

**BUG-L-001: Absolute positioning numbers**
- **Location:** `qml/screens/DashboardScreen.qml:40`
- **Snippet:** `x: 260 - width / 2`
- **Why:** Magic constants break responsiveness if the screen resolution or frame SVGs change.
- **Repro:** Change window size.
- **Fix Direction:** Use anchor layout or bind to the cluster frame SVG paths directly.

### 4.6 MVVM Architecture (mvvm-protocol-agent)
**BUG-H-005: Fabricated telemetry**
- **Location:** `src/viewmodels/VehicleStatusViewModel.cpp:121`
- **Snippet:** `double calcSpeed = static_cast<double>(rpm) * 0.03;`
- **Why:** A ViewModel should format/expose data, not fabricate critical physical simulations (like converting RPM to speed).
- **Repro:** Send RPM via serial; observe Speed changing artificially.
- **Fix Direction:** Hardware or Simulator Service should send actual speed telemetry.

**BUG-M-001: Hardcoded fallback properties**
- **Location:** `src/viewmodels/VehicleStatusViewModel.cpp:136-138`
- **Snippet:**
  ```cpp
  setBattery(100);
  setRange(325);
  setTemperature(57);
  ```
- **Why:** Overriding these values on every serial tick defeats simulator manipulation.
- **Repro:** Send valid serial frame; battery resets to 100%.
- **Fix Direction:** Omit setting these unless the hardware frame explicitly provides them.

### 4.7 Numerics (numerics-agent)
**BUG-H-004: Checksum Arithmetic Truncation**
- **Location:** `src/services/SerialService.cpp:109`
- **Snippet:** `int expectedChecksum = (rpm + static_cast<int>(vbat) + error) % 256;`
- **Why:** Casting float to int directly truncates precision, and modulo in C++ can yield negative numbers if inputs wrap negatively, causing invalid checksums.
- **Repro:** Send `vbat=12.9`. Sender calculates with 12.9, receiver calculates with 12.
- **Fix Direction:** Standardize byte packing for checksum instead of lossy float casting, use unsigned arithmetic `& 0xFF`.

### 4.8 Serial Protocol (serial-protocol-agent)
**BUG-C-001: Unbounded buffer (OOM Risk)**
- **Location:** `src/services/SerialService.cpp:77-89`
- **Snippet:** `m_buffer.append(m_serial->readAll());`
- **Why:** If newline `\n` is never received (e.g. noise or bad hardware), the buffer will grow infinitely and crash the application.
- **Repro:** Send continuous bytes without `\n`. Memory usage spikes.
- **Fix Direction:** Implement a maximum buffer size limit (e.g., 1024 bytes) and clear it if exceeded.

**BUG-C-003: ReadOnly reconnect**
- **Location:** `src/services/SerialService.cpp:154`
- **Snippet:** `if (m_serial->open(QIODevice::ReadOnly))`
- **Why:** The initial connection opens `ReadWrite`, but reconnect logic opens `ReadOnly`. Commands like `emergencyStop()` will fail silently after a drop.
- **Repro:** Unplug hardware, plug back in. UI connects, but TX operations fail.
- **Fix Direction:** Change to `QIODevice::ReadWrite`.

**BUG-H-001: Checksum bypass**
- **Location:** `src/services/SerialService.cpp:110`
- **Snippet:** `if (checksumStr.isEmpty() || checksumStr.toInt() == expectedChecksum)`
- **Why:** `isEmpty()` bypasses the check entirely, allowing malformed frames to pollute the UI state.
- **Repro:** Send `TEL,5000,12.5,0;`. UI accepts it despite missing checksum.
- **Fix Direction:** Remove `checksumStr.isEmpty()` allowance.

### 4.9 Multimedia (multimedia-agent)
**BUG-M-002: Auto-play on first song**
- **Location:** `src/viewmodels/MusicPlayerViewModel.cpp:171-178`
- **Snippet:** `if (m_songs.count() == 1) { ... m_player->play(); }`
- **Why:** Automatically playing the very first song discovered during a background library scan is poor UX and startles the user.
- **Repro:** Start app with music in directory. Music blares immediately without interaction.
- **Fix Direction:** Remove auto-play; wait for explicit user intent.

### 4.10 Build & Static Analysis (build-test-static-agent)
**BUG-H-006: Inadequate compiler warnings**
- **Location:** `CMakeLists.txt:10`
- **Snippet:** `add_compile_options(-Wall -Wextra)`
- **Why:** Missing strict checks (`-Wconversion`, `-Wshadow`) which would catch the float-to-int truncations natively. Missing sanitizers (`-fsanitize=address,undefined`).
- **Repro:** Look at CMakeLists.txt.
- **Fix Direction:** Add comprehensive warning flags and static analysis targets.

**BUG-L-003: Missing test coverage**
- **Location:** `tests/CMakeLists.txt`
- **Snippet:** Only tests `VehicleStatusViewModel`.
- **Why:** Approximately 3% code coverage leaves core systems like `SerialService` entirely unverified.
- **Repro:** Run `ctest`.
- **Fix Direction:** Add unit tests for `SerialService::parseTelemetry` and mock the serial port.

## 5. Cross-Cutting Concerns
- **MVVM / Zero-JS Friction**: The strict Zero-JS requirement currently forces math into QML bindings (violating the rule) or forces ViewModels to fabricate data (`calcSpeed`), breaking single responsibility. We must architect pure "Display ViewModels" that pre-format string properties (`QString displaySpeed`) to cleanly resolve this.
- **Safety / Hardiness**: Both serial parsing and music scanning suffer from "happy path" implementations. A corrupted file or serial stream will easily break the simulator's stability.

## 6. Out of Scope
- **Hardware UART Port Wiring**: Excluded per instructions. The hardware layer is simulated/mocked for testing purposes. Physical wiring, TX/RX voltages, and hardware baud rate mismatches are not assessed here.
