{
  "effortLevel": "medium",
  "env": {
    "ANTHROPIC_BASE_URL": "__CLAUDE_AGGREGATOR_URL__",
    "ANTHROPIC_MODEL": "__CLAUDE_MODEL__",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "__CLAUDE_MODEL__",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "__CLAUDE_OPUS_MODEL__",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "__CLAUDE_FAST_MODEL__",
    "CLAUDE_CODE_SUBAGENT_MODEL": "__CLAUDE_FAST_MODEL__",
    "CLAUDE_CODE_SUBAGENT_MODEL_FORCE": "1",
    "MAX_THINKING_TOKENS": "10000",
    "BASH_MAX_OUTPUT_LENGTH": "8000",
    "MAX_MCP_OUTPUT_TOKENS": "8000",
    "ENABLE_TOOL_SEARCH": "true",
    "DISABLE_NON_ESSENTIAL_MODEL_CALLS": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "permissions": {
    "deny": [
      "Read(./node_modules/**)",
      "Read(./dist/**)",
      "Read(./build/**)",
      "Read(./.next/**)",
      "Read(./target/**)",
      "Read(./*.lock)",
      "Read(./package-lock.json)",
      "Read(./pnpm-lock.yaml)",
      "Read(./yarn.lock)",
      "Read(./**/*.log)"
    ]
  }
}
