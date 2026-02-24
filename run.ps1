# Game Dev OpenSpec - Remote Runner
# 用法: gh api repos/ganlingyao/game-dev-openspec/contents/run.ps1 --jq '.content' | % { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) } | iex
# 或简化: irm https://raw.githubusercontent.com/ganlingyao/game-dev-openspec/main/run.ps1 | iex  (仅公开仓库)

param(
    [ValidateSet("install", "update")]
    [string]$Action = "install"
)

$ErrorActionPreference = "Stop"
$REPO = "ganlingyao/game-dev-openspec"
$TEMP_DIR = "$env:TEMP\game-dev-openspec-$(Get-Random)"

Write-Host ""
Write-Host "Game Dev OpenSpec - Remote $Action" -ForegroundColor Cyan
Write-Host ""

try {
    # 下载仓库 zip
    Write-Host "[1/4] Downloading repository..." -ForegroundColor Yellow
    $zipPath = "$TEMP_DIR.zip"
    gh api "repos/$REPO/zipball" -H "Accept: application/vnd.github+json" > $zipPath

    # 解压
    Write-Host "[2/4] Extracting..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $TEMP_DIR -Force

    # 找到解压后的目录（GitHub zip 会创建一个带 commit hash 的子目录）
    $extractedDir = (Get-ChildItem $TEMP_DIR -Directory)[0].FullName

    # 执行安装或更新脚本
    Write-Host "[3/4] Running $Action script..." -ForegroundColor Yellow
    $scriptPath = Join-Path $extractedDir "$Action.ps1"
    & $scriptPath -TargetPath (Get-Location).Path

    # 清理
    Write-Host "[4/4] Cleaning up..." -ForegroundColor Yellow
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Done!" -ForegroundColor Green
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    # 清理
    Remove-Item "$TEMP_DIR.zip" -Force -ErrorAction SilentlyContinue
    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
