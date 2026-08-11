# Skills 部署清单（SKILLS-SETUP）

> 用途：在新设备上快速布置自定义 skills。
> 方式：**AI 根据本清单逐个下载每个 skill 的来源 URL**，配合 `setup.ps1`（Windows）或 `setup.sh`（Linux/macOS）自动布置。
> 更新日期：2026-08-11。

---

## 1. 每个 skill 的独立来源

所有 skill 托管于仓库 **`git@github.com:sphwl/my_skills.git`**（远程分支 `main`，已同步全部 24 个）。
每个 skill 是仓库下的一个子目录，独立来源 URL 如下（AI 按行逐条下载即可）：

| # | Skill 名称 | 独立来源 URL（GitHub 网页） | 仓库内目录 |
|---|-----------|------------------------------|-----------|
| 1 | andrej-karpathy | https://github.com/sphwl/my_skills/tree/main/andrej-karpathy | `andrej-karpathy/` |
| 2 | brainstorming | https://github.com/sphwl/my_skills/tree/main/brainstorming | `brainstorming/` |
| 3 | chinese-code-review | https://github.com/sphwl/my_skills/tree/main/chinese-code-review | `chinese-code-review/` |
| 4 | chinese-commit-conventions | https://github.com/sphwl/my_skills/tree/main/chinese-commit-conventions | `chinese-commit-conventions/` |
| 5 | chinese-documentation | https://github.com/sphwl/my_skills/tree/main/chinese-documentation | `chinese-documentation/` |
| 6 | chinese-git-workflow | https://github.com/sphwl/my_skills/tree/main/chinese-git-workflow | `chinese-git-workflow/` |
| 7 | dispatching-parallel-agents | https://github.com/sphwl/my_skills/tree/main/dispatching-parallel-agents | `dispatching-parallel-agents/` |
| 8 | eds-gsdml-adapter | https://github.com/sphwl/my_skills/tree/main/eds-gsdml-adapter | `eds-gsdml-adapter/` |
| 9 | embedded-c-unity-testgen | https://github.com/sphwl/my_skills/tree/main/embedded-c-unity-testgen | `embedded-c-unity-testgen/` |
| 10 | executing-plans | https://github.com/sphwl/my_skills/tree/main/executing-plans | `executing-plans/` |
| 11 | finishing-a-development-branch | https://github.com/sphwl/my_skills/tree/main/finishing-a-development-branch | `finishing-a-development-branch/` |
| 12 | gb2312-encoding | https://github.com/sphwl/my_skills/tree/main/gb2312-encoding | `gb2312-encoding/` |
| 13 | mcp-builder | https://github.com/sphwl/my_skills/tree/main/mcp-builder | `mcp-builder/` |
| 14 | receiving-code-review | https://github.com/sphwl/my_skills/tree/main/receiving-code-review | `receiving-code-review/` |
| 15 | requesting-code-review | https://github.com/sphwl/my_skills/tree/main/requesting-code-review | `requesting-code-review/` |
| 16 | subagent-driven-development | https://github.com/sphwl/my_skills/tree/main/subagent-driven-development | `subagent-driven-development/` |
| 17 | systematic-debugging | https://github.com/sphwl/my_skills/tree/main/systematic-debugging | `systematic-debugging/` |
| 18 | test-driven-development | https://github.com/sphwl/my_skills/tree/main/test-driven-development | `test-driven-development/` |
| 19 | using-git-worktrees | https://github.com/sphwl/my_skills/tree/main/using-git-worktrees | `using-git-worktrees/` |
| 20 | using-superpowers | https://github.com/sphwl/my_skills/tree/main/using-superpowers | `using-superpowers/` |
| 21 | verification-before-completion | https://github.com/sphwl/my_skills/tree/main/verification-before-completion | `verification-before-completion/` |
| 22 | workflow-runner | https://github.com/sphwl/my_skills/tree/main/workflow-runner | `workflow-runner/` |
| 23 | writing-plans | https://github.com/sphwl/my_skills/tree/main/writing-plans | `writing-plans/` |
| 24 | writing-skills | https://github.com/sphwl/my_skills/tree/main/writing-skills | `writing-skills/` |

> 系统内置 skill（explore / research / review / security-review / test 等）随 Reasonix 自带，无需下载。

---

## 2. AI 自动下载方法（推荐）

在另一台设备上，AI 按本清单执行即可：

```bash
# 1) 一次性克隆下载源（含全部 24 个 skill）
git clone --depth 1 git@github.com:sphwl/my_skills.git "$HOME/.agents/skills"

# 2)（可选）如需 HTTPS 而非 SSH：
# git clone --depth 1 https://github.com/sphwl/my_skills.git "$HOME/.agents/skills"
```

若只需要其中某几个 skill（按独立来源逐个下载）：

```bash
# 示例：只下载 chinese-code-review 这一个 skill 到目标目录
git clone --depth 1 --filter=blob:none --sparse git@github.com:sphwl/my_skills.git /tmp/my_skills
cd /tmp/my_skills
git sparse-checkout set chinese-code-review
cp -r chinese-code-review "$HOME/.agents/skills/"
```

> AI 提示：本清单第 1 节表格中每一行就是一个 skill 的来源；下载完整集合用第 2 节第 1 条命令，
> 逐个下载用 sparse-checkout 方式。下载后按第 3 节布置到各平台目录。

---

## 3. 各平台部署位置

| 平台 | 目录 | 说明 |
|------|------|------|
| GitHub Copilot / 通用 agents | `~\.agents\skills\` | 自定义 skills 主目录，自动被识别 |
| Claude Code | `~\.claude\skills\` | 复制自 `.agents\skills`（默认子集 21 个；要完全一致则复制全部） |
| Cursor | `~\.cursor\skills-cursor\` | Cursor 官方自带 skills，有 `.sync-manifest.json`，**非自定义，无需部署** |
| Reasonix（项目级） | `<repo>\.reasonix\skills\` | 仅当需要项目级 skill 时使用 |

---

## 4. 一键部署脚本

脚本按第 1 节清单自动下载并布置到 `.agents\skills` 与 `.claude\skills`：

- Windows：`setup.ps1`（PowerShell）
- Linux / macOS：`setup.sh`（bash）

用法：

```powershell
# Windows（在仓库目录内）
.\setup.ps1              # 默认 SSH 克隆
.\setup.ps1 -Https       # 无 SSH key 时用 HTTPS
```

```bash
# Linux / macOS（在仓库目录内）
chmod +x setup.sh && ./setup.sh          # 默认 SSH 克隆
./setup.sh --https                       # 无 SSH key 时用 HTTPS
```

脚本行为：克隆 `sphwl/my_skills.git` → 复制全部 skill 到 `~/.agents/skills` → 复制到 `~/.claude/skills`。
已有目录会自动跳过（不会覆盖现有文件），可传 `-Force` / `--force` 强制覆盖。
克隆失败时会提示原因（SSH key 未配置 → 加 `--https`；网络不通 → 检查代理）。

---

## 5. 手动布置（不用脚本）

### Windows (PowerShell)

```powershell
git clone --depth 1 git@github.com:sphwl/my_skills.git "$HOME\.agents\skills"
Copy-Item "$HOME\.agents\skills\*" "$HOME\.claude\skills\" -Recurse -Force
```

### Linux / macOS (bash)

```bash
git clone --depth 1 git@github.com:sphwl/my_skills.git "$HOME/.agents/skills"
mkdir -p "$HOME/.claude/skills"
cp -r "$HOME/.agents/skills"/* "$HOME/.claude/skills/" 2>/dev/null
rm -f "$HOME/.claude/skills/README.md"
```

### 验证

```bash
ls "$HOME/.agents/skills"   # 应看到 24 个 skill 目录 + README.md
ls "$HOME/.claude/skills"   # 应看到 skill 目录
```

---

## 6. 维护要点

- 新增/修改 skill：改 `~\.agents\skills\<name>\SKILL.md`，然后
  `git add -A && git commit -m "..." && git push origin main`（在 `~\.agents\skills` 目录内）。
- 本清单与 `setup.ps1` / `setup.sh` 维护在 **`git@github.com:1340686678/skills_setup.git`**，
  新设备 clone 该仓库即可获得布置方案：`git clone git@github.com:1340686678/skills_setup.git`。
- Claude Code 的 `~\.claude\skills` 是副本，改动请以 `.agents\skills` 为准。
