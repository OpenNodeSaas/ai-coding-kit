---
name: spec
description: Generate a concise SPEC.md (requirements, edge cases, exact file changes, verification commands) before coding. Use only when explicitly invoked with $spec or /spec.
---

When explicitly invoked:
1. Inspect only the directly relevant files. Ask at most 3 critical clarifying questions if requirements are ambiguous.
2. Write a concise `SPEC.md` in the project root containing:
   - Goal & Non-goals (keep scope strict, no speculative over-engineering)
   - Exact files to create/modify and interface/data contracts
   - Verification commands (tests/lint/build) that prove completion
3. STOP and wait for user approval of `SPEC.md` before modifying any source code.
