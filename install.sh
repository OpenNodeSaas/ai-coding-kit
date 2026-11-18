#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

log()  { printf "\n\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[警告]\033[0m %s\n" "$1"; }

# 1. 加载 .env
if [ ! -f "$ROOT_DIR/.env" ]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  warn "未检测到 .env，已从 .env.example 生成。"
  warn "请先编辑 $ROOT_DIR/.env 填入你的 3 组 Key 和模型 ID，再重新运行 ./install.sh"
  exit 1
fi

set -a
# shellcheck disable=SC1091
source "$ROOT_DIR/.env"
set +a

# 2. 检查基础依赖
for cmd in curl git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ 缺少必要工具: $cmd，请先安装。"
    exit 1
  fi
done

if ! command -v node >/dev/null 2>&1; then
  warn "未检测到 Node.js：Ponytail 的 Hook 与 Codex npm 安装依赖 Node.js，建议先装 Node 22+。"
fi

# 3. 写入 Shell 环境变量（仅追加到交互式尾部；非交互 SSH 不打印任何输出，保证 Herdr 稳定连接）
write_shell_env() {
  local rc_file="$1"
  [ -f "$rc_file" ] || touch "$rc_file"
  if grep -q "# >>> ai-coding-kit >>>" "$rc_file"; then
    awk '
      /# >>> ai-coding-kit >>>/ { skip=1; next }
      /# <<< ai-coding-kit <<</ { skip=0; next }
      !skip { print }
    ' "$rc_file" > "${rc_file}.tmp" && mv "${rc_file}.tmp" "$rc_file"
  fi

  cat << EOF >> "$rc_file"
# >>> ai-coding-kit >>>
export PATH="\$HOME/.local/bin:\$PATH"
export ANTHROPIC_AUTH_TOKEN="${CLAUDE_AGGREGATOR_API_KEY}"
export ANTHROPIC_API_KEY=""
export CODEX_AGGREGATOR_API_KEY="${CODEX_AGGREGATOR_API_KEY}"
export DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY}"
export PONYTAIL_DEFAULT_MODE="${PONYTAIL_DEFAULT_MODE:-full}"
alias cxds="codex --profile ds"
alias pstack-on="claude plugin enable pstack@cursor-plugins"
alias pstack-off="claude plugin disable pstack@cursor-plugins"
# <<< ai-coding-kit <<<
EOF
  log "已更新环境变量与快捷别名到 $rc_file"
}

if [ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ]; then
  write_shell_env "$HOME/.zshrc"
fi
if [ -f "$HOME/.bashrc" ] || [ ! -f "$HOME/.zshrc" ]; then
  write_shell_env "$HOME/.bashrc"
fi

# 4. 安装 3 大核心组件（Claude Code + Codex CLI + 纯无头 herdr-core）
log "1/5 安装或检查 Claude Code CLI..."
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "✓ Claude Code 已安装: $(claude --version 2>/dev/null || echo 'ok')"
fi

log "2/5 安装或检查 Codex CLI..."
if ! command -v codex >/dev/null 2>&1; then
  if ! curl -fsSL https://chatgpt.com/codex/install.sh | sh; then
    if command -v npm >/dev/null 2>&1; then
      npm install -g @openai/codex
    else
      warn "Codex 原生脚本失败且无 npm，请手动安装 @openai/codex。"
    fi
  fi
else
  echo "✓ Codex CLI 已安装: $(codex --version 2>/dev/null || echo 'ok')"
fi

log "3/5 安装或检查纯无头运行时 herdr-core (hc)（不含 GUI 监控端）..."
if ! command -v hc >/dev/null 2>&1; then
  curl -fsSL https://releases.herdr.dev/core/install.sh | sh
else
  echo "✓ herdr-core (hc) 已安装: $(hc --version 2>/dev/null || echo 'ok')"
fi

# 如果没有全局软链，尽量提醒/建立（方便非交互 SSH 直接找到 hc）
if [ -x "$HOME/.local/bin/hc" ] && [ -w /usr/local/bin ]; then
  ln -sf "$HOME/.local/bin/hc" /usr/local/bin/hc || true
fi

# 5. 部署配置文件与轻量 Skills
log "4/5 渲染并部署配置文件 & 轻量 Skills ($spec, hc)..."
mkdir -p \
  "$HOME/.claude/skills/spec" \
  "$HOME/.claude/skills/hc" \
  "$HOME/.codex/skills/spec" \
  "$HOME/.codex/skills/hc"

if [ -f "$HOME/.claude/settings.json" ]; then
  cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak.$(date +%Y%m%d%H%M%S)"
fi
sed \
  -e "s|__CLAUDE_AGGREGATOR_URL__|${CLAUDE_AGGREGATOR_URL}|g" \
  -e "s|__CLAUDE_MODEL__|${CLAUDE_MODEL}|g" \
  -e "s|__CLAUDE_OPUS_MODEL__|${CLAUDE_OPUS_MODEL}|g" \
  -e "s|__CLAUDE_FAST_MODEL__|${CLAUDE_FAST_MODEL}|g" \
  "$ROOT_DIR/configs/claude/settings.json.tpl" > "$HOME/.claude/settings.json"

if [ -f "$HOME/.codex/config.toml" ]; then
  cp "$HOME/.codex/config.toml" "$HOME/.codex/config.toml.bak.$(date +%Y%m%d%H%M%S)"
fi
sed \
  -e "s|__CODEX_AGGREGATOR_URL__|${CODEX_AGGREGATOR_URL}|g" \
  -e "s|__CODEX_MODEL__|${CODEX_MODEL}|g" \
  "$ROOT_DIR/configs/codex/config.toml.tpl" > "$HOME/.codex/config.toml"

sed "s|deepseek-flash|${DEEPSEEK_MODEL:-deepseek-flash}|g" \
  "$ROOT_DIR/configs/codex/ds.config.toml" > "$HOME/.codex/ds.config.toml"

cp "$ROOT_DIR/skills/spec/SKILL.md" "$HOME/.claude/skills/spec/SKILL.md"
cp "$ROOT_DIR/skills/spec/SKILL.md" "$HOME/.codex/skills/spec/SKILL.md"
cp "$ROOT_DIR/skills/hc/SKILL.md"   "$HOME/.claude/skills/hc/SKILL.md"
cp "$ROOT_DIR/skills/hc/SKILL.md"   "$HOME/.codex/skills/hc/SKILL.md"

# 6. 按策略安装插件：
#    - Claude Code：全局装 Ponytail + 装 Pstack（但默认 disable！）
#    - Codex CLI  ：全局只装 Ponytail（不装 Pstack！）
log "5/5 安装插件（Claude: Ponytail + 初始禁用 Pstack；Codex: 仅 Ponytail）..."

if command -v claude >/dev/null 2>&1; then
  claude plugin marketplace add DietrichGebert/ponytail || warn "Claude Ponytail marketplace 添加失败"
  claude plugin install ponytail@ponytail || warn "Claude Ponytail 安装失败"

  claude plugin marketplace add cursor/plugins || warn "Claude cursor/plugins marketplace 添加失败"
  claude plugin install pstack@cursor-plugins || warn "Claude Pstack 安装失败"
  claude plugin disable pstack@cursor-plugins || warn "Claude Pstack 初始禁用失败，请手动执行 pstack-off"
fi

if command -v codex >/dev/null 2>&1; then
  codex plugin marketplace add DietrichGebert/ponytail || warn "Codex Ponytail marketplace 添加失败"
  codex plugin add ponytail@ponytail || warn "Codex Ponytail 安装失败"
  # 严格遵守要求：Codex CLI 内不安装 Pstack
fi

cat << 'DONE_EOF'

✅ VPS 节点全部安装与部署完成！（本机仅含无头 herdr-core，不含监控端）

接下来只需 3 步收尾：
1. 重载环境变量：source ~/.zshrc  （或 source ~/.bashrc）
2. 首次用 Codex 时，在 Codex 里敲一次 /hooks 信任 Ponytail 钩子；
   如果之前登录过 Claude 官方账号，在 Claude 里敲一次 /logout 清旧凭证。
3. 快捷命令速查：
   - claude      -> 聚合商 A（常驻 Ponytail；Pstack 默认禁用，需要时敲 pstack-on 开启）
   - codex       -> 聚合商 B（OpenAI，内置 /plan、/goal、$spec，无 Pstack）
   - cxds        -> DeepSeek 官方（deepseek-flash，配 /goal 跑测试闭环极省钱）
   - pstack-on   -> 临时启用 Claude 的 Pstack；用完敲 pstack-off 关回 0 消耗
DONE_EOF
