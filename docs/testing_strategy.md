# 🧪 Testing Strategy

> **AI Context**: Automated testing rules for AI agents using Test-Driven Development (TDD).

## 1. Testing Philosophy (TDD First)
Before implementing a new C++ ViewModel or Service feature, you MUST write a failing test first. Code without tests is considered invalid.

## 2. Backend Testing (QtTest / GoogleTest)
- **Scope**: ViewModels, Data Parsers, Serial Services.
- **Mandate**: Every `Q_PROPERTY` must have a test validating its `READ` accessor, `WRITE` mutator (if any), and emission of the `NOTIFY` signal.

## 3. Hardware Simulation Tests
- The `SerialService` parsing logic MUST be unit-tested against edge cases:
  - Corrupted UART frames.
  - Incomplete byte streams (partial packets).
  - Invalid checksums.

## 4. AI Vibe Coding Test Loop
> [!TIP]
> Follow this exact sequence when building features:
1. **Red**: Write a test for the target behavior in `tests/`.
2. **Green**: Implement C++ logic until `ctest` passes.
3. **Refactor**: Clean up the code.
4. **Bind**: Expose to QML.
