# skills_setup

在另一台设备上快速布置自定义 skills 的部署方案。

## 内容

- **SKILLS-SETUP.md** — 24 个自定义 skill 的清单，每个 skill 含独立来源 URL，AI 可据此逐条下载
- **setup.ps1** — Windows（PowerShell）一键部署脚本
- **setup.sh** — Linux / macOS（bash）一键部署脚本

## 快速开始

```bash
# 在新设备上获取本仓库
git clone git@github.com:1340686678/skills_setup.git
cd skills_setup

# 布置（自动克隆下载源 sphwl/my_skills.git 到 ~/.agents/skills 和 ~/.claude/skills）
# Windows:  .\setup.ps1
./setup.sh
```

详细说明见 [SKILLS-SETUP.md](SKILLS-SETUP.md)。
