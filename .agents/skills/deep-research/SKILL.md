---
name: deep-research
description: "Run autonomous research tasks specifically tailored for the Qt6/QML Automotive UI and STM32 integration project."
risk: safe
source: "customized from original deep-research skill"
date_added: "2026-07-17"
---

# Qt+STM Automotive Deep Research Skill

Run autonomous research tasks that plan, search, read, and synthesize information into comprehensive reports, **with implicit context about the Qt6 / STM32 Automotive Simulator project**.

## When to Use This Skill

Use this skill when:
- Researching C++ and QML architectural patterns (e.g., MVVM, `QStateMachine`).
- Finding best practices for serial communication (UART) between PC (Qt6) and STM32F103C8T6.
- Looking up fluid animation techniques and performance optimizations in QML.
- Investigating ways to maintain strict 100% C++ and QML separation (Zero JavaScript logic in QML).
- Performing deep technical research on embedded systems or automotive UI constraints.
- Need detailed, cited research reports in Markdown format saved directly to the `docs/` directory.

## Requirements

- Python 3.8+
- httpx: `pip install -r requirements.txt`
- GEMINI_API_KEY environment variable

## Setup

1. Get a Gemini API key from [Google AI Studio](https://aistudio.google.com/)
2. Set the environment variable:
   ```bash
   export GEMINI_API_KEY=your-api-key-here
   ```

## Usage

When running this research tool, always inject project context to get highly relevant results.

### Start a research task (Project Context Injected)
```bash
python3 scripts/research.py --query "Research QML StateMachine best practices for Automotive UIs. Context: Strict 100% C++ and QML separation, MVVM architecture, simulating STM32 telemetry data via UART."
```

### With structured output format (Markdown)
```bash
python3 scripts/research.py --query "Compare Q_PROPERTY vs Q_INVOKABLE for passing UART data" \
  --format "1. Executive Summary\n2. Comparison Table\n3. Recommendations for our Architecture" \
  > docs/research_qproperty_vs_qinvokable.md
```

### Stream progress in real-time
```bash
python3 scripts/research.py --query "Analyze Qt6 QSerialPort performance" --stream
```

### Continue from previous research
```bash
python3 scripts/research.py --query "Elaborate on point 2" --continue <interaction_id>
```

## Output Formats

- **Default**: Human-readable markdown report (Strongly recommended to output to `docs/` directory)
- **JSON** (`--json`): Structured data for programmatic use
- **Raw** (`--raw`): Unprocessed API response

## Project-Specific Constraints to Include in Queries
When formulating `--query` strings, always remember to append these constraints if relevant to the search context:
1. **Frontend**: "Zero JavaScript logic in QML", "Automotive Dashboard UI", "Minimalist Neon aesthetic"
2. **Backend**: "C++ backend with MVVM pattern", "Q_PROPERTY bindings"
3. **Hardware**: "STM32F103C8T6 UART integration via USB"

## Limitations
- Use this skill only when the task clearly matches the scope described above.
- Do not treat the output as a substitute for environment-specific validation, testing, or expert review.
- Stop and ask for clarification if required inputs, permissions, safety boundaries, or success criteria are missing.
