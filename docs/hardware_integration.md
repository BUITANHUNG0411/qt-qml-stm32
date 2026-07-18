# 🔌 Hardware Integration (STM32 & UART)

> **AI Context**: Protocol and architecture for PC-to-STM32 serial communication.

## 1. Hardware Topology
- **Host**: PC running Qt6 Application (`QSerialPort`).
- **MCU**: STM32F103C8T6 (Blue Pill).
- **Actuators/Sensors**: L298N Motor Driver, Encoder feedback.
- **Connection**: USB-TTL UART @ 115200 8N1.

## 2. UART Protocol Specification
Uses line-based ASCII for high observability. Format: `<CMD>,<ARG1>,...;<CHECKSUM>\n`

| Direction | Example Frame | Description |
|---|---|---|
| PC ➔ STM | `SET,120,1;` | Target 120 RPM, Forward |
| PC ➔ STM | `STOP;` | Emergency Halt |
| STM ➔ PC | `TEL,118,11.8,0;` | RPM=118, VBat=11.8V, Error=0 |

## 3. C++ SerialService Requirements
- Use `QByteArray` buffer to read until `\n` to prevent partial frame processing.
- Verify checksum before processing `TEL` frames.
- Run parsing asynchronously (or leverage `readyRead()` slots) so the GUI thread never blocks.

## 4. Fail-Safes
> [!WARNING]
> Hardware can disconnect at any time.
- Implement watchdog timers in C++: If no telemetry is received for 500ms, mark data as "Stale" and alert QML.
- Implement auto-reconnect logic on `QSerialPort::errorOccurred`.
- **Dynamic Fallback:** The application uses dependency injection dynamically in `main.cpp`. If `SerialService` loses connection or watchdog times out, it emits `connectionStatusChanged(false)` and the application instantly spins up `SimulatorService` to keep the UI alive. When valid `TEL` frames are received, it emits `true` and the simulator shuts down.
