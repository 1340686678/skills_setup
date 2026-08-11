# setup.ps1 — 一键布置自定义 skills（Windows / PowerShell）
# 用法： .\setup.ps1          （克隆 + 布置；已存在目录跳过）
#        .\setup.ps1 -Force   （强制覆盖已有文件）
# 下载源： git@github.com:sphwl/my_skills.git（含全部 24 个 skill）

param(
    [switch]$Force,
    [switch]$Https   # 使用 HTTPS 而非 SSH 克隆（无 SSH key 时用）
)

$ErrorActionPreference = "Stop"
$SOURCE_REPO = "git@github.com:sphwl/my_skills.git"
$SOURCE_REPO_HTTPS = "https://github.com/sphwl/my_skills.git"
$HOME_DIR = $HOME
$AGENTS_DIR = Join-Path $HOME_DIR ".agents\skills"
$CLAUDE_DIR = Join-Path $HOME_DIR ".claude\skills"
$TMP_CLONE = Join-Path $env:TEMP "my_skills_setup"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

# 1. 克隆下载源
if (Test-Path $TMP_CLONE) {
    $isValid = Test-Path (Join-Path $TMP_CLONE ".git")
    if ($isValid -and -not $Force) {
        Write-Step "使用已有临时克隆: $TMP_CLONE"
    } else {
        # 残留目录或 -Force：清掉重新克隆
        Remove-Item $TMP_CLONE -Recurse -Force
    }
}
if (-not (Test-Path $TMP_CLONE)) {
    if ($Https) {
        Write-Step "使用 HTTPS 克隆 $SOURCE_REPO_HTTPS ..."
        git clone --depth 1 $SOURCE_REPO_HTTPS $TMP_CLONE
    } else {
        Write-Step "克隆下载源 $SOURCE_REPO ..."
        git clone --depth 1 $SOURCE_REPO $TMP_CLONE
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "" -NoNewline
        Write-Host "克隆失败。可能原因：" -ForegroundColor Yellow
        Write-Host "  1. 未配置 SSH key → 改用 .\setup.ps1 -Https"
        Write-Host "  2. 网络无法访问 github.com → 检查代理/网络"
        throw "克隆失败（exit=$LASTEXITCODE），可加 -Https 参数重试"
    }
}

# 2. 复制到 ~/.agents/skills（目标：用户主目录下的 .agents\skills）
Write-Step "布置到 $AGENTS_DIR"
New-Item -ItemType Directory -Force -Path $AGENTS_DIR | Out-Null
Get-ChildItem $TMP_CLONE -Directory | ForEach-Object {
    $dest = Join-Path $AGENTS_DIR $_.Name
    if (Test-Path $dest) {
        if ($Force) { Copy-Item $_.FullName $dest -Recurse -Force }
        else { Write-Host "  跳过（已存在）: $($_.Name)" }
    } else {
        Copy-Item $_.FullName $dest -Recurse
        Write-Host "  安装: $($_.Name)"
    }
}
Copy-Item (Join-Path $TMP_CLONE "README.md") (Join-Path $AGENTS_DIR "README.md") -Force -ErrorAction SilentlyContinue

# 3. 复制到 ~/.claude/skills（子集）
Write-Step "布置到 $CLAUDE_DIR"
New-Item -ItemType Directory -Force -Path $CLAUDE_DIR | Out-Null
Get-ChildItem $TMP_CLONE -Directory | ForEach-Object {
    $dest = Join-Path $CLAUDE_DIR $_.Name
    if (Test-Path $dest) {
        if ($Force) { Copy-Item $_.FullName $dest -Recurse -Force }
        else { Write-Host "  跳过（已存在）: $($_.Name)" }
    } else {
        Copy-Item $_.FullName $dest -Recurse
        Write-Host "  安装: $($_.Name)"
    }
}

# 4. 清理临时克隆
if (Test-Path $TMP_CLONE) { Remove-Item $TMP_CLONE -Recurse -Force }

Write-Host ""
Write-Host "完成！已布置 $(Get-ChildItem $AGENTS_DIR -Directory | Measure-Object | Select-Object -ExpandProperty Count) 个 skill 到:"
Write-Host "  $AGENTS_DIR"
Write-Host "  $CLAUDE_DIR"
