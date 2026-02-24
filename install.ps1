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
$SCHEMAS_SOURCE = "$PSScriptRoot\schemas"
$SCHEMAS_TARGET = "$TargetPath\openspec\schemas"

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

# Copy schemas
$schemasInstalled = 0
if (Test-Path $SCHEMAS_SOURCE) {
    Write-Host ""
    Write-Host "Installing schemas..." -ForegroundColor Yellow
    Write-Host ""

    # Create schemas directory if not exists
    if (-not (Test-Path $SCHEMAS_TARGET)) {
        New-Item -ItemType Directory -Path $SCHEMAS_TARGET -Force | Out-Null
    }

    Get-ChildItem $SCHEMAS_SOURCE -Directory | ForEach-Object {
        $schemaName = $_.Name
        $source = $_.FullName

        Copy-Item -Path $source -Destination $SCHEMAS_TARGET -Recurse -Force
        Write-Host "  [+] $schemaName" -ForegroundColor Green
        $schemasInstalled++
    }
}

# Update config.yaml to use game-dev-workflow as default schema
$configPath = "$TargetPath\openspec\config.yaml"
if (Test-Path $configPath) {
    Write-Host ""
    Write-Host "Updating config.yaml..." -ForegroundColor Yellow

    $configContent = Get-Content $configPath -Raw
    if ($configContent -match "schema:\s*\S+") {
        $configContent = $configContent -replace "schema:\s*\S+", "schema: game-dev-workflow"
        Set-Content -Path $configPath -Value $configContent -NoNewline
        Write-Host "  [+] Set default schema to game-dev-workflow" -ForegroundColor Green
    }
}

# Copy CLAUDE.md template
$claudeTemplate = "$PSScriptRoot\CLAUDE.md.template"
$claudeTarget = "$TargetPath\CLAUDE.md"
$claudeInstalled = $false

if (Test-Path $claudeTemplate) {
    Write-Host ""
    Write-Host "Installing CLAUDE.md..." -ForegroundColor Yellow

    if (Test-Path $claudeTarget) {
        Write-Host "  [!] CLAUDE.md already exists, skipping" -ForegroundColor Yellow
        Write-Host "      To update, delete existing file and re-run install" -ForegroundColor Gray
    }
    else {
        # Get project name from folder
        $projectName = (Get-Item $TargetPath).Name
        $namespace = $projectName -replace '[^a-zA-Z0-9]', ''

        # Copy and replace placeholders
        $content = Get-Content $claudeTemplate -Raw
        $content = $content -replace '\{\{PROJECT_NAME\}\}', $projectName
        $content = $content -replace '\{\{PROJECT_NAMESPACE\}\}', $namespace
        Set-Content -Path $claudeTarget -Value $content -NoNewline

        Write-Host "  [+] CLAUDE.md (project: $projectName)" -ForegroundColor Green
        $claudeInstalled = $true
    }
}

# Done
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed:" -ForegroundColor White
Write-Host "  - $installed skills" -ForegroundColor Gray
Write-Host "  - $schemasInstalled schemas" -ForegroundColor Gray
Write-Host "  - Default schema: game-dev-workflow" -ForegroundColor Gray
if ($claudeInstalled) {
    Write-Host "  - CLAUDE.md (project instructions)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "To update later, run:" -ForegroundColor White
Write-Host "  irm https://raw.githubusercontent.com/ganlingyao/game-dev-openspec/main/run.ps1 | iex" -ForegroundColor Cyan
Write-Host ""
