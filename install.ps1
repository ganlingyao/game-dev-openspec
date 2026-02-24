# Game Dev OpenSpec Installer (Private Repo)
# Usage:
#   git clone git@github.com:ganlingyao/game-dev-openspec.git $env:TEMP\gdw
#   & "$env:TEMP\gdw\install.ps1"
#   Remove-Item -Recurse -Force $env:TEMP\gdw

param(
    [string]$TargetPath = "."
)

$SKILLS_SOURCE = "$PSScriptRoot\skills"
$SKILLS_TARGET = "$TargetPath\.claude\skills"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Game Dev OpenSpec Installer" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check OpenSpec
$openspecPath = "$TargetPath\openspec"
if (-not (Test-Path $openspecPath)) {
    Write-Host "[!] OpenSpec not initialized" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Game Dev OpenSpec depends on OpenSpec." -ForegroundColor White
    Write-Host "Please run first:" -ForegroundColor White
    Write-Host ""
    Write-Host "  openspec init" -ForegroundColor Cyan
    Write-Host ""

    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}
else {
    Write-Host "[OK] OpenSpec detected" -ForegroundColor Green
}

# Check source skills exist
if (-not (Test-Path $SKILLS_SOURCE)) {
    Write-Host "[X] Skills directory not found: $SKILLS_SOURCE" -ForegroundColor Red
    exit 1
}

# Create target directory
if (-not (Test-Path $SKILLS_TARGET)) {
    New-Item -ItemType Directory -Path $SKILLS_TARGET -Force | Out-Null
    Write-Host "[OK] Created .claude/skills directory" -ForegroundColor Green
}

# Copy skills
Write-Host ""
Write-Host "Installing skills..." -ForegroundColor Yellow
Write-Host ""

$installed = 0
Get-ChildItem $SKILLS_SOURCE -Directory | ForEach-Object {
    $skillName = $_.Name
    $source = $_.FullName
    $target = "$SKILLS_TARGET\$skillName"

    Copy-Item -Path $source -Destination $SKILLS_TARGET -Recurse -Force
    Write-Host "  [+] $skillName" -ForegroundColor Green
    $installed++
}

# Done
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed $installed skills to:" -ForegroundColor White
Write-Host "  $SKILLS_TARGET" -ForegroundColor Gray
Write-Host ""
Write-Host "To update later, run:" -ForegroundColor White
Write-Host "  git clone git@github.com:ganlingyao/game-dev-openspec.git `$env:TEMP\gdw" -ForegroundColor Gray
Write-Host "  & `"`$env:TEMP\gdw\update.ps1`"" -ForegroundColor Gray
Write-Host "  Remove-Item -Recurse -Force `$env:TEMP\gdw" -ForegroundColor Gray
Write-Host ""
