<#
.SYNOPSIS
    Speclet Installer for Windows
.DESCRIPTION
    Installs Speclet files into the current project directory.
.EXAMPLE
    .\install.ps1
#>

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput @"

╔═══════════════════════════════════════════════════════════╗
║                    SPECLET INSTALLER                      ║
╚═══════════════════════════════════════════════════════════╝
"@ "Green"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

New-Item -ItemType Directory -Path ".speclet/templates" -Force | Out-Null
New-Item -ItemType Directory -Path ".speclet/tickets" -Force | Out-Null
New-Item -ItemType Directory -Path ".speclet/archive" -Force | Out-Null
New-Item -ItemType Directory -Path ".opencode/skill" -Force | Out-Null

Copy-Item "$ScriptDir/GUIDE.md" ".speclet/" -Force
Copy-Item "$ScriptDir/loop.md" ".speclet/" -Force
Copy-Item "$ScriptDir/templates/*" ".speclet/templates/" -Force
Copy-Item "$ScriptDir/skills/*" ".opencode/skill/" -Recurse -Force
Copy-Item "$ScriptDir/speclet.sh" "./" -Force
Copy-Item "$ScriptDir/speclet.ps1" "./" -Force

if (-not (Test-Path ".speclet/DECISIONS.md")) {
    @"
# Architecture Decisions

> Permanent file. Do NOT move to archive.

---
"@ | Set-Content ".speclet/DECISIONS.md"
}

$gitignore = ".gitignore"
if (Test-Path $gitignore) {
    $content = Get-Content $gitignore -Raw
    if ($content -notmatch "\.speclet/") {
        Add-Content $gitignore @"

# Speclet
.speclet/*
!.speclet/DECISIONS.md
"@
    }
} else {
    @"
# Speclet
.speclet/*
!.speclet/DECISIONS.md
"@ | Set-Content $gitignore
}

Write-ColorOutput "Installed:" "Blue"
Write-Host "  .speclet/GUIDE.md"
Write-Host "  .speclet/loop.md"
Write-Host "  .speclet/DECISIONS.md"
Write-Host "  .speclet/templates/*"
Write-Host "  .opencode/skill/speclet-draft/"
Write-Host "  .opencode/skill/speclet-spec/"
Write-Host "  .opencode/skill/speclet-loop/"
Write-Host "  ./speclet.sh"
Write-Host "  ./speclet.ps1"
Write-Host ""
Write-ColorOutput "Ready! Usage:" "Green"
Write-Host "  Use the speclet-draft skill for [feature]"
Write-Host "  Use the speclet-spec skill"
Write-Host "  Use the speclet-loop skill"
Write-Host ""
Write-Host "  Or autonomous: .\speclet.ps1"
