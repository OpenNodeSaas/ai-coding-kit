---
name: hc
description: Use herdr-core (hc) to spawn background tasks, tests, dev servers, or helper sub-agents in persistent terminals when $HC_TERMINAL_ID is set or background execution is needed.
---

When you need to run a long-lived server, test suite, or spawn a helper agent (e.g. a Codex reviewer) in parallel:
1. First run `hc --skill` once to read the exact `hc` CLI syntax and protocol.
2. Prefer `hc run --bg --name <label> ...` so commands survive disconnects and appear in the user's Herdr GUI sidebar.
