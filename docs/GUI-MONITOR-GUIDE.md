# macOS & Windows 下使用 Herdr GUI 监控多台 VPS 手册

## 核心架构
- **VPS 端（3~4 台）**：只运行 `herdr-core`（命令为 `hc`），无图形界面。
- **电脑端（Mac / Windows）**：运行原生 **Herdr 桌面 GUI（`herdr-app`）**，通过 Tailscale SSH 直连每台 VPS 的 `herdr-core`。
- ⚠️ **重要提醒**：请勿在桌面端安装旧版终端版 `Herdr TUI` 来连 `hc`，`Herdr App (GUI)` 必须配对 VPS 上的 `herdr-core (hc)`。

## 一、macOS 安装（Apple Silicon）
```bash
brew install --cask herdr-app
# 或官方脚本：curl -fsSL https://releases.herdr.dev/app/install.sh | sh
```

## 二、Windows 安装（x86_64，Win10 1803+）
在 PowerShell 运行：
```powershell
powershell -c "irm https://releases.herdr.dev/app/install.ps1 | iex"
```
> Windows 暂不支持 ARM64；如用 ARM64 本，请在 WSL2 内安装 Herdr。

## 三、打通免密 SSH（基于你已配好的 Tailscale）
- 如用 Tailscale SSH，请确保 Tailscale 后台 ACL 规则为 `"action": "accept"`（不要用 `"check"`，否则弹浏览器验证会导致 GUI 卡住）。
- 如用普通公钥免密：在 Mac 用 `ssh-copy-id user@vps`；在 Windows PowerShell 用：
  `type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh user@vps "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`
- 在 Mac `~/.ssh/config` 或 Windows `C:\Users\<用户名>\.ssh\config` 写好 `Host vps1` / `vps2` / `vps3` 短别名，测试 `ssh vps1 "hc --version"` 能无密码直接输出版本号即可。

## 四、在 Herdr GUI 添加与监控 VPS
1. 打开 **Herdr** 桌面应用，点左下角/侧边栏 **`+ Add machine`**（或 `Settings -> Machines`）。
2. 选择 `~/.ssh/config` 里的 `vps1`、`vps2`、`vps3` 依次添加。
3. 在 GUI 内为每台 VPS 新建 **Space** 与标签页，启动 `claude`、`codex` 或 `cxds`。
4. 侧边栏会按 **`Blocked（等你确认）→ Done（刚完成）→ Working（运行中）→ Idle`** 自动聚合所有 VPS 上的 Agent 状态；关闭电脑或休眠后，VPS 上的任务依然继续执行。
GUIDE_EOF

chmod +x "$PROJECT/install.sh"

# 打包 zip
if command -v zip >/dev/null 2>&1; then
  zip -r "${PROJECT}.zip" "$PROJECT" >/dev/null
  echo "✅ 已生成 GitHub 项目 ./$PROJECT 和压缩包 ./${PROJECT}.zip"
else
  tar -czf "${PROJECT}.tar.gz" "$PROJECT"
  echo "✅ 未找到 zip，已生成 ./$PROJECT 和 ./${PROJECT}.tar.gz"
fi
```

### 在 3~4 台 VPS 上的部署步骤
把生成的 `ai-coding-kit` 推到你的私有 GitHub 仓库（或把 `ai-coding-kit.zip` 传到 VPS 解压），在每台 VPS 上只需跑 3 行：
```bash
cp .env.example .env    # 填入 3 组 Key
./install.sh
source ~/.bashrc        # 若用 zsh 则是 ~/.zshrc
```
*(提示：如果想把这 3~4 台 VPS 用同一个 `.env` 快速同步，把填好的 `.env` 用 `scp` 分发过去再跑 `./install.sh` 即可，不用每台手动填一遍。)*

---

## 第二部分：macOS & Windows 下安装 Herdr GUI 监控多台 VPS 手册

> ⚠️ **先厘清一个非常关键的版本对应关系（避免连不上）**：
> Herdr 官方把软件分成了两套体系：
> 1. **`Herdr App`（原生桌面 GUI）** ↔ 对应 VPS 上的 **`herdr-core`（`hc`）**
> 2. **老版 `Herdr TUI`（纯终端界面）** ↔ 对应老版 `herdr server`
>
> **两者不互通！** 上面 `ai-coding-kit` 给你的 VPS 装的是最新的无头引擎 **`herdr-core`（`hc`）**，所以你电脑上装 **官方桌面 GUI（`Herdr App`）** 正好完美匹配！

---

### 一、 macOS 端安装与打通

#### 1. 安装 Herdr GUI 桌面端
* **Apple Silicon（M1 / M2 / M3 / M4，推荐）**：
  任选一种方式安装：
  ```bash
  # 方式 1：Homebrew 一键装（推荐，以后方便更新）
  brew install --cask herdr-app

  # 方式 2：官方终端脚本安装到 ~/Applications/Herdr.app
  curl -fsSL https://releases.herdr.dev/app/install.sh | sh
  ```
* *(如果是 Intel 老款 Mac：官方预编译 GUI 仅提供 Apple Silicon 版，Intel Mac 建议改用 `brew install herdr` 终端版，或在下方“手机端”通过 iPad/iPhone 接入。)*

#### 2. 配置 Mac 到 3~4 台 VPS 的无感免密 SSH（基于你已通的 Tailscale）
1. 查出你几台 VPS 的 Tailscale 域名或 IP：`tailscale status`
2. 如果你还没配公钥免密，在 Mac 终端执行（没有密钥先 `ssh-keygen -t ed25519` 一路回车）：
   ```bash
   ssh-copy-id 用户名@vps1-tailscale名
   ssh-copy-id 用户名@vps2-tailscale名
   ssh-copy-id 用户名@vps3-tailscale名
   ```
3. 写入 Mac 的 `~/.ssh/config`：
   ```sshconfig
   Host vps1
     HostName vps1-tailscale名
     User 你的VPS用户名

   Host vps2
     HostName vps2-tailscale名
     User 你的VPS用户名

   Host vps3
     HostName vps3-tailscale名
     User 你的VPS用户名
   ```

---

### 二、 Windows 端安装与打通

#### 1. 安装 Herdr GUI 桌面端
* **Windows 10（1803+）/ Windows 11（64位 x86_64）**：
  打开 **PowerShell**（普通权限即可），运行：
  ```powershell
  powershell -c "irm https://releases.herdr.dev/app/install.ps1 | iex"
  ```
  安装完成后，**Herdr** 会出现在 Windows 开始菜单中（并把命令行辅助工具加进 PATH，重开一个终端生效）。
* *(注：目前 `herdr-app` 暂不支持 Windows ARM64 设备（如高通芯片笔记本）；如果是 ARM64 Windows，请在 WSL2 Ubuntu 里安装终端版使用。)*

#### 2. 配置 Windows 到几台 VPS 的无感免密 SSH
Windows 自带 OpenSSH 客户端，但没有 `ssh-copy-id` 命令，按下面 3 步操作最稳：
1. 打开 PowerShell，检查或生成 SSH 密钥（已有可跳过）：
   ```powershell
   if (!(Test-Path "$env:USERPROFILE\.ssh\id_ed25519.pub")) { ssh-keygen -t ed25519 }
   ```
2. 把公钥一键追加到每台 VPS（把 `用户名@vps1` 换成你的）：
   ```powershell
   type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh 用户名@vps1-tailscale名 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
   ```
3. 编辑 Windows 的 SSH 配置文件 `notepad $env:USERPROFILE\.ssh\config`，写入同样的别名：
   ```sshconfig
   Host vps1
     HostName vps1-tailscale名
     User 你的VPS用户名

   Host vps2
     HostName vps2-tailscale名
     User 你的VPS用户名
   ```

---

### 三、 必检项：10 秒排除 99% 的连接坑

在打开 GUI 之前，在你的 **Mac 或 Windows PowerShell** 里跑一下这行测试命令：

```bash
ssh vps1 "hc --version"
```
**必须同时满足两个条件**，GUI 才能秒连：
1. **不提示输入密码、不弹浏览器**，直接打印出 `hc` 版本号；
   * *⚠️ Tailscale SSH 避坑*：如果你在 VPS 上开了 `tailscale set --ssh`（Tailscale SSH），请务必去 Tailscale 网页后台 **Access Controls (ACL)** 把 SSH 规则里的 `"action"` 确认设为 **`"accept"`** 而不是默认的 `"check"`——因为 `"check"` 策略会要求弹窗网页二次确认，导致桌面 GUI 在后台连接时卡死。
2. **输出极其干净**：版本号前面不能出现任何 `Welcome to Ubuntu...` 之类的多行文字。

---

### 四、 打开 Herdr GUI，接入并监控这几台 VPS

Mac 和 Windows 端打开 **Herdr** 后的界面和操作完全一致：

#### 1. 添加所有 VPS 机器
1. 启动 **Herdr** 桌面应用。
2. 点击界面 **`Settings → Machines`**，或者直接点击左侧边栏的 **`+ Add machine`**。
3. Herdr 会自动读取你刚才写的 `~/.ssh/config`，直接选中 **`vps1`、`vps2`、`vps3`**（或手动填 `用户名@tailscale域名`）依次添加。
4. 几秒后，每台机器就会出现在侧边栏里——所有终端进程都真正在各自 VPS 的 `herdr-core` 里运行，**你的 Mac / Windows 本机只负责画面渲染与监控**。

#### 2. 为每个项目建 Space（工作区）与多模型分屏
1. 在左侧栏选中某台 VPS（例如 `vps1`），新建一个 **Space**（一个项目一个 Space）。
2. 点顶部标签栏的 **`+`** 或分屏按钮，在一个 Tab 里可以并排开 3 个窗格：
   * 左窗格运行 **`claude`**（聚合商 A + 全局 Ponytail，默认禁用 Pstack）
   * 右上窗格运行 **`codex`**（聚合商 B OpenAI）
   * 右下窗格运行 **`cxds`**（DeepSeek 官方 `deepseek-flash`）

#### 3. 看懂侧边栏集中监控状态（核心价值）
无论你接了 3 台还是 4 台 VPS、上面开了 10 个还是 20 个 Agent，Herdr GUI 的 **Agents 侧边栏**都会把所有机器的 Agent 汇总成一张实时待办清单（通过原生 OSC 7501 状态协议驱动，不靠瞎猜）：
* 🟡 **Blocked（需要你介入）**：比如 `claude` 问你是否允许执行某个危险命令，或者 `$spec` 写完了 `SPEC.md` 等你确认——**永远排在最前面提醒你**。
* 🔵 **Done（刚干完活）**：你切去干别的事时，某台 VPS 上的 `/goal` 或任务刚跑完。
* 🟢 **Working（干活中）**：模型正在写代码或后台跑测试，不用管它。
* ⚪ **Idle（空闲）**：你看过了或者停在待命状态。

点击侧边栏任意一条状态，窗口会瞬间切到对应那台 VPS 的那个真实终端里，你可以直接打字回复、或者按 `Shift+Tab` 切模式、查看代码 diff。

#### 4. 多设备接力与不断线特性
* **下班合盖 / 切换系统**：你在公司用 **Windows** 的 Herdr GUI 给 `vps1` 和 `vps2` 下达了 `/goal` 任务，直接关掉 Windows 电脑回家；晚上在家打开 **Mac** 上的 Herdr GUI，因为双方连的都是 VPS 上同一个 `herdr-core`，**所有工作区、分屏布局、运行中/刚完成的 Agent 会原封不动同步在眼前**。
* **手机随时盯梢（纯附加彩蛋）**：Herdr 官方在 App Store / Google Play 也有同名免费客户端，同样是走你的 Tailscale SSH 直连几台 VPS 的 `herdr-core`（无官方中转服务器、无需注册账号），出门在外手机也能点开 `Blocked` 的终端批复继续跑。

---

### 五、 推荐你的日常多 VPS 极简节奏

1. **新需求起手（省 Token）**：在任意 VPS 窗格用 **`cxds`**（DeepSeek Flash）敲 **`$spec 你的需求`**，几分钱先产出精简的 `SPEC.md`，人工看一眼确认。
2. **核心实现**：
   * 复杂业务：切 **`claude`**（全局 Ponytail 自动压掉 50% 冗余代码）按 `SPEC.md` 写入；真遇到特大重构，敲 **`pstack-on`** 进 `/pstack:poteto-mode`，跑完记得 **`pstack-off`** 省钱。
   * 需要全自动跑通测试闭环：交给 **`cxds`** 敲 **`/goal 严格按 SPEC.md 实现并跑通测试`**，合上电脑走人，等 Herdr GUI 侧边栏变 **`Done`** 再验收。
