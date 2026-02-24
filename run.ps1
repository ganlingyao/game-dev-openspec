# Game Dev OpenSpec - One-Line Installer
# 用法: irm https://raw.githubusercontent.com/ganlingyao/game-dev-openspec/main/run.ps1 | iex

param(
    [ValidateSet("install", "update")]
    [string]$Action = "install"
)

$ErrorActionPreference = "Stop"
$REPO_URL = "https://github.com/ganlingyao/game-dev-openspec/archive/refs/heads/main.zip"
$TEMP_DIR = "$env:TEMP\game-dev-openspec-$(Get-Random)"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Game Dev OpenSpec - $Action" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # 下载
    Write-Host "[1/4] Downloading..." -ForegroundColor Yellow
    $zipPath = "$TEMP_DIR.zip"
    Invoke-WebRequest -Uri $REPO_URL -OutFile $zipPath -UseBasicParsing

    # 解压
    Write-Host "[2/4] Extracting..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $TEMP_DIR -Force
    $extractedDir = (Get-ChildItem $TEMP_DIR -Directory)[0].FullName

    # 执行
    Write-Host "[3/4] Running $Action..." -ForegroundColor Yellow
    & "$extractedDir\$Action.ps1" -TargetPath (Get-Location).Path

    # 清理
    Write-Host "[4/4] Cleaning up..." -ForegroundColor Yellow
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Done!" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Remove-Item "$TEMP_DIR.zip" -Force -ErrorAction SilentlyContinue
    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
