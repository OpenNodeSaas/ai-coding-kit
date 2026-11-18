# ai-coding-kit

专为多台 VPS + 桌面 Herdr GUI 集中监控设计的极简低成本 AI 编码套件：
- **VPS / 干活机（本仓库部署）**：
  - `Claude Code CLI`：聚合商 A + 全局 `Ponytail` + 预装但**默认禁用** `Pstack`（`pstack-on` / `pstack-off` 随用随开）
  - `Codex CLI`：默认聚合商 B（OpenAI），`cxds` 秒切 DeepSeek 官方（`deepseek-flash`）；全局 `Ponytail`，**不装 Pstack**；原生 `/goal` + 轻量 `$spec`
  - `herdr-core (hc)`：纯无头后台终端引擎（无监控端界面）
- **你的电脑端（macOS / Windows）**：安装 **Herdr GUI (`herdr-app`)**，通过 Tailscale SSH 统一监控所有 VPS。详见 [docs/GUI-MONITOR-GUIDE.md](./docs/GUI-MONITOR-GUIDE.md)。

## VPS 一键部署

```bash
cp .env.example .env
# 填写你的 3 组 Key 和模型 ID
./install.sh
source ~/.zshrc   # 或 ~/.bashrc
# ai-coding-kit
