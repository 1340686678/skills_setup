#!/usr/bin/env bash
# setup.sh — 一键布置自定义 skills（Linux / macOS / Git Bash）
# 用法： ./setup.sh          （克隆 + 布置；已存在目录跳过）
#        ./setup.sh --force  （强制覆盖已有文件）
# 下载源： git@github.com:sphwl/my_skills.git（含全部 24 个 skill）

set -euo pipefail

SOURCE_REPO="git@github.com:sphwl/my_skills.git"
SOURCE_REPO_HTTPS="https://github.com/sphwl/my_skills.git"
HOME_DIR="${HOME:-$USERPROFILE}"
AGENTS_DIR="$HOME_DIR/.agents/skills"
CLAUDE_DIR="$HOME_DIR/.claude/skills"
TMP_CLONE="${TMPDIR:-/tmp}/my_skills_setup"
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
    -h|--help)
      echo "用法: $0 [--force]"; echo "  克隆下载源并布置 skills 到 ~/.agents/skills 和 ~/.claude/skills"; exit 0 ;;
  esac
done

step() { echo "==> $*" >&2; }

# 1. 克隆下载源
if [ -d "$TMP_CLONE/.git" ] && [ "$FORCE" = "1" ]; then
  rm -rf "$TMP_CLONE"
fi
if [ ! -d "$TMP_CLONE/.git" ]; then
  step "克隆下载源 $SOURCE_REPO ..."
  if ! git clone --depth 1 "$SOURCE_REPO" "$TMP_CLONE" 2>/dev/null; then
    step "SSH 克隆失败，改用 HTTPS ..."
    git clone --depth 1 "$SOURCE_REPO_HTTPS" "$TMP_CLONE"
  fi
else
  step "使用已有临时克隆: $TMP_CLONE"
fi

# 2. 布置到 ~/.agents/skills
step "布置到 $AGENTS_DIR"
mkdir -p "$AGENTS_DIR"
for d in "$TMP_CLONE"/*/; do
  name="$(basename "$d")"
  dest="$AGENTS_DIR/$name"
  if [ -e "$dest" ]; then
    if [ "$FORCE" = "1" ]; then
      rm -rf "$dest"; cp -r "$d" "$dest"; echo "  覆盖: $name"
    else
      echo "  跳过（已存在）: $name"
    fi
  else
    cp -r "$d" "$dest"; echo "  安装: $name"
  fi
done
[ -f "$TMP_CLONE/README.md" ] && cp -f "$TMP_CLONE/README.md" "$AGENTS_DIR/README.md" 2>/dev/null || true

# 3. 布置到 ~/.claude/skills（子集）
step "布置到 $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR"
for d in "$TMP_CLONE"/*/; do
  name="$(basename "$d")"
  dest="$CLAUDE_DIR/$name"
  if [ -e "$dest" ]; then
    if [ "$FORCE" = "1" ]; then
      rm -rf "$dest"; cp -r "$d" "$dest"; echo "  覆盖: $name"
    else
      echo "  跳过（已存在）: $name"
    fi
  else
    cp -r "$d" "$dest"; echo "  安装: $name"
  fi
done

# 4. 清理临时克隆
rm -rf "$TMP_CLONE"

echo ""
count=$(ls -d "$AGENTS_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')
echo "完成！已布置 $count 个 skill 到:"
echo "  $AGENTS_DIR"
echo "  $CLAUDE_DIR"
