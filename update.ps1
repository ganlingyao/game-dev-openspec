# Game Dev OpenSpec Updater
# Usage:
#   git clone git@github.com:ganlingyao/game-dev-openspec.git $env:TEMP\gdw
#   & "$env:TEMP\gdw\update.ps1"
#   Remove-Item -Recurse -Force $env:TEMP\gdw

param(
    [string]$TargetPath = ".",
    [switch]$Force
)

$SKILLS_SOURCE = "$PSScriptRoot\skills"
$SKILLS_TARGET = "$TargetPath\.claude\skills"
$SCHEMAS_SOURCE = "$PSScriptRoot\schemas"
$SCHEMAS_TARGET = "$TargetPath\openspec\schemas"
$AGENTS_TARGET = "$TargetPath\.claude\agents"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Game Dev OpenSpec Updater" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check target exists
if (-not (Test-Path $SKILLS_TARGET)) {
    Write-Host "[X] Skills directory not found: $SKILLS_TARGET" -ForegroundColor Red
    Write-Host "    Run install.ps1 first." -ForegroundColor Yellow
    exit 1
}

# Check source skills exist
if (-not (Test-Path $SKILLS_SOURCE)) {
    Write-Host "[X] Source skills not found: $SKILLS_SOURCE" -ForegroundColor Red
    exit 1
}

# Update skills
Write-Host "Updating skills..." -ForegroundColor Yellow
Write-Host ""

$updated = 0
$skipped = 0

Get-ChildItem $SKILLS_SOURCE -Directory | ForEach-Object {
    $skillName = $_.Name
    $source = $_.FullName
    $target = "$SKILLS_TARGET\$skillName"

    $sourceSkillFile = "$source\SKILL.md"
    $targetSkillFile = "$target\SKILL.md"

    # Check if update needed (compare modification time or force)
    $needUpdate = $Force

    if (-not $needUpdate -and (Test-Path $targetSkillFile)) {
        $sourceTime = (Get-Item $sourceSkillFile).LastWriteTime
        $targetTime = (Get-Item $targetSkillFile).LastWriteTime

        if ($sourceTime -gt $targetTime) {
            $needUpdate = $true
        }
    }
    elseif (-not (Test-Path $target)) {
        $needUpdate = $true
    }

    if ($needUpdate) {
        Copy-Item -Path $source -Destination $SKILLS_TARGET -Recurse -Force
        Write-Host "  [+] $skillName (updated)" -ForegroundColor Green
        $updated++
    }
    else {
        Write-Host "  [-] $skillName (unchanged)" -ForegroundColor Gray
        $skipped++
    }
}

# Update agents
Write-Host ""
Write-Host "Updating agents..." -ForegroundColor Yellow
Write-Host ""

$agentsUpdated = 0
$agentFile = "$AGENTS_TARGET\unity-csharp-explorer.md"

if (-not (Test-Path $AGENTS_TARGET)) {
    New-Item -ItemType Directory -Path $AGENTS_TARGET -Force | Out-Null
}

try {
    # Get latest tag from unity-csharp-explorer repo
    $tagsUrl = "https://api.github.com/repos/zhing2006/unity-csharp-explorer/tags"
    $tags = Invoke-RestMethod -Uri $tagsUrl -Headers @{ "User-Agent" = "PowerShell" } -ErrorAction Stop
    
    if ($tags.Count -gt 0) {
        $latestTag = $tags[0].name
        $agentUrl = "https://raw.githubusercontent.com/zhing2006/unity-csharp-explorer/$latestTag/.claude/agents/unity-csharp-explorer.md"
    }
    else {
        $latestTag = "main"
        $agentUrl = "https://raw.githubusercontent.com/zhing2006/unity-csharp-explorer/main/.claude/agents/unity-csharp-explorer.md"
    }
    
    Invoke-WebRequest -Uri $agentUrl -OutFile $agentFile -ErrorAction Stop
    Write-Host "  [+] unity-csharp-explorer ($latestTag)" -ForegroundColor Green
    $agentsUpdated++
}
catch {
    Write-Host "  [!] unity-csharp-explorer (update failed: $_)" -ForegroundColor Yellow
}

# Update schemas
$schemasUpdated = 0
if (Test-Path $SCHEMAS_SOURCE) {
    Write-Host ""
    Write-Host "Updating schemas..." -ForegroundColor Yellow
    Write-Host ""

    if (-not (Test-Path $SCHEMAS_TARGET)) {
        New-Item -ItemType Directory -Path $SCHEMAS_TARGET -Force | Out-Null
    }

    Get-ChildItem $SCHEMAS_SOURCE -Directory | ForEach-Object {
        $schemaName = $_.Name
        $source = $_.FullName

        Copy-Item -Path $source -Destination $SCHEMAS_TARGET -Recurse -Force
        Write-Host "  [+] $schemaName (updated)" -ForegroundColor Green
        $schemasUpdated++
    }
}

# Done
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Update Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Skills:  $updated updated, $skipped unchanged" -ForegroundColor White
Write-Host "Agents:  $agentsUpdated updated" -ForegroundColor White
Write-Host "Schemas: $schemasUpdated updated" -ForegroundColor White
Write-Host ""
if ($agentsUpdated -gt 0) {
    Write-Host "[!] IMPORTANT: Restart Claude Code to activate updated agents" -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "To force update all:" -ForegroundColor White
Write-Host "  & `"update.ps1`" -Force" -ForegroundColor Gray
Write-Host ""
