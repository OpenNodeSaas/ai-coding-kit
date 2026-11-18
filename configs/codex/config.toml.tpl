# 默认走聚合商 B（OpenAI）
model_provider = "aggregator"
model = "__CODEX_MODEL__"

# 省 Token 核心参数
model_reasoning_effort = "medium"
plan_mode_reasoning_effort = "medium"
model_reasoning_summary = "none"
model_verbosity = "low"
personality = "pragmatic"
project_doc_max_bytes = 12000
tool_output_token_limit = 8000
web_search = "disabled"

developer_instructions = """
Be concise. Lead with code or direct answer. No filler. Inspect only relevant lines.
"""

# 渠道 1：聚合商 B（OpenAI）
[model_providers.aggregator]
name = "Aggregator OpenAI"
base_url = "__CODEX_AGGREGATOR_URL__"
env_key = "CODEX_AGGREGATOR_API_KEY"
requires_openai_auth = false
wire_api = "responses"

# 渠道 2：DeepSeek 官方（原生支持 Responses API）
[model_providers.deepseek]
name = "DeepSeek Official"
base_url = "https://api.deepseek.com"
env_key = "DEEPSEEK_API_KEY"
requires_openai_auth = false
wire_api = "responses"
