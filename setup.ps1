# setup.ps1 - one-click skills deployment (Windows / PowerShell)
# Usage:  .\setup.ps1           (clone + deploy; existing dirs are skipped)
#         .\setup.ps1 -Force    (force overwrite existing files)
#         .\setup.ps1 -Https    (use HTTPS clone, e.g. no SSH key configured)
# Source: git@github.com:sphwl/my_skills.git (contains all 24 skills)

param(
    [switch]$Force,
    [switch]$Https   # use HTTPS instead of SSH for cloning
)

$ErrorActionPreference = "Stop"
$SOURCE_REPO = "git@github.com:sphwl/my_skills.git"
$SOURCE_REPO_HTTPS = "https://github.com/sphwl/my_skills.git"
$AGENTS_DIR = Join-Path $HOME ".agents\skills"
$CLAUDE_DIR = Join-Path $HOME ".claude\skills"
$TMP_CLONE = Join-Path $env:TEMP "my_skills_setup"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

# 1. Clone the source repo
if (Test-Path $TMP_CLONE) {
    $isValid = Test-Path (Join-Path $TMP_CLONE ".git")
    if ($isValid -and -not $Force) {
        Write-Step "Reusing existing temp clone: $TMP_CLONE"
    } else {
        # leftover dir or -Force: wipe and re-clone
        Remove-Item $TMP_CLONE -Recurse -Force
    }
}
if (-not (Test-Path $TMP_CLONE)) {
    if ($Https) {
        Write-Step "Cloning via HTTPS $SOURCE_REPO_HTTPS ..."
        git clone --depth 1 $SOURCE_REPO_HTTPS $TMP_CLONE
    } else {
        Write-Step "Cloning source $SOURCE_REPO ..."
        git clone --depth 1 $SOURCE_REPO $TMP_CLONE
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "Clone failed. Possible causes:" -ForegroundColor Yellow
        Write-Host "  1. No SSH key configured -> retry with: .\setup.ps1 -Https"
        Write-Host "  2. Cannot reach github.com -> check proxy/network"
        throw "Clone failed (exit=$LASTEXITCODE). Retry with -Https."
    }
}

# 2. Deploy to ~/.agents/skills
Write-Step "Deploying to $AGENTS_DIR"
New-Item -ItemType Directory -Force -Path $AGENTS_DIR | Out-Null
Get-ChildItem $TMP_CLONE -Directory | ForEach-Object {
    $dest = Join-Path $AGENTS_DIR $_.Name
    if (Test-Path $dest) {
        if ($Force) { Copy-Item $_.FullName $dest -Recurse -Force }
        else { Write-Host "  skip (exists): $($_.Name)" }
    } else {
        Copy-Item $_.FullName $dest -Recurse
        Write-Host "  install: $($_.Name)"
    }
}
Copy-Item (Join-Path $TMP_CLONE "README.md") (Join-Path $AGENTS_DIR "README.md") -Force -ErrorAction SilentlyContinue

# 3. Deploy to ~/.claude/skills
Write-Step "Deploying to $CLAUDE_DIR"
New-Item -ItemType Directory -Force -Path $CLAUDE_DIR | Out-Null
Get-ChildItem $TMP_CLONE -Directory | ForEach-Object {
    $dest = Join-Path $CLAUDE_DIR $_.Name
    if (Test-Path $dest) {
        if ($Force) { Copy-Item $_.FullName $dest -Recurse -Force }
        else { Write-Host "  skip (exists): $($_.Name)" }
    } else {
        Copy-Item $_.FullName $dest -Recurse
        Write-Host "  install: $($_.Name)"
    }
}

# 4. Cleanup temp clone
if (Test-Path $TMP_CLONE) { Remove-Item $TMP_CLONE -Recurse -Force }

Write-Host ""
Write-Host "Done! Deployed $(Get-ChildItem $AGENTS_DIR -Directory | Measure-Object | Select-Object -ExpandProperty Count) skills to:"
Write-Host "  $AGENTS_DIR"
Write-Host "  $CLAUDE_DIR"
