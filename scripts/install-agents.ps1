<#
.SYNOPSIS
    Speclet Bootstrap Installer (PowerShell)
    Installs Speclet Council agents to your environment.

.DESCRIPTION
    This script detects the Windows environment, prompts for an installation path,
    backs up existing agents if found, and copies the new agent templates.
#>

$ErrorActionPreference = "Stop"

# --- Configuration ---
$SourceDir = ".opencode\agent"
$GlobalConfigDir = "$env:USERPROFILE\.config\opencode\agent"
$LocalConfigDir = ".opencode\agent"
$BackupDirBase = "agents_backup"

# --- Colors ---
function Write-Color($Text, $Color) {
    Write-Host -ForegroundColor $Color $Text
}

function Log($Text) {
    Write-Host -ForegroundColor Cyan "[speclet-bootstrap] $Text"
}

function Warn($Text) {
    Write-Host -ForegroundColor Yellow "[WARNING] $Text"
}

function ErrorExit($Text) {
    Write-Host -ForegroundColor Red "[ERROR] $Text"
    exit 1
}

# --- 1. Environment Detection ---
Log "Detecting environment..."
Log "OS: Windows (PowerShell)"

# --- 2. Check Source Files ---
if (-not (Test-Path $SourceDir)) {
    # Try forward slash if backslash fails (e.g. running in some shells)
    $SourceDir = ".opencode/agent"
    if (-not (Test-Path $SourceDir)) {
        ErrorExit "Source directory '$SourceDir' not found. Run this script from the speclet repo root."
    }
}

$RequiredAgents = @("plan-reviewer-opus.md", "plan-reviewer-sonnet.md", "plan-reviewer-gemini.md", "plan-reviewer-gpt.md", "plan-reviewer-glm.md")
$MissingAgents = $false

foreach ($agent in $RequiredAgents) {
    if (-not (Test-Path "$SourceDir\$agent")) {
        Warn "Missing source template: $agent"
        $MissingAgents = $true
    }
}

if ($MissingAgents) {
    ErrorExit "Some required agent templates are missing in '$SourceDir'. Cannot proceed."
}

# --- 3. Path Selection ---
Write-Host ""
Write-Host "Select installation target:"
Write-Host "  1) Global User Config ($GlobalConfigDir) - Recommended for system-wide access"
Write-Host "  2) Project Local Config ($LocalConfigDir) - Good for project-specific overrides"
Write-Host "  3) Custom Path"

$Choice = Read-Host "Enter choice [1]"
if ([string]::IsNullOrWhiteSpace($Choice)) { $Choice = "1" }

switch ($Choice) {
    "1" { $TargetDir = $GlobalConfigDir }
    "2" { $TargetDir = $LocalConfigDir }
    "3" { $TargetDir = Read-Host "Enter custom path" }
    Default { ErrorExit "Invalid choice" }
}

Log "Target directory: $TargetDir"

if (-not (Test-Path $TargetDir)) {
    $CreateConfirm = Read-Host "Directory '$TargetDir' does not exist. Create it? [Y/n]"
    if ([string]::IsNullOrWhiteSpace($CreateConfirm)) { $CreateConfirm = "Y" }
    
    if ($CreateConfirm -match "^[Yy]") {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    } else {
        ErrorExit "Installation cancelled."
    }
}

# --- 4. Backup Logic ---
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir = Join-Path $TargetDir "${BackupDirBase}_${Timestamp}"
$AgentsFound = $false

# Check if any target agents already exist
foreach ($agent in $RequiredAgents) {
    if (Test-Path "$TargetDir\$agent") {
        $AgentsFound = $true
        break
    }
}

if ($AgentsFound) {
    Log "Existing agents detected. Creating backup..."
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    foreach ($agent in $RequiredAgents) {
        if (Test-Path "$TargetDir\$agent") {
            Copy-Item "$TargetDir\$agent" "$BackupDir\" -Force
        }
    }
    Log "Backup created at: $BackupDir"
}

# --- 5. Installation ---
Log "Installing agents..."
foreach ($agent in $RequiredAgents) {
    Copy-Item "$SourceDir\$agent" "$TargetDir\" -Force
    Write-Host "  - Installed $agent"
}

# --- 6. Validation (Conditional) ---
Write-Host ""
if (Get-Command opencode -ErrorAction SilentlyContinue) {
    Log "Validating installation with OpenCode CLI..."
    
    try {
        # Using invoke-expression or direct call
        opencode agent list | Out-Null
        Write-Color "✔ OpenCode agent list verified." "Green"
        Write-Host "You may need to restart OpenCode or your terminal for changes to take effect."
    } catch {
        Warn "OpenCode CLI is installed but 'agent list' failed. Please check manually."
    }
} else {
    Log "OpenCode CLI not found in PATH. Skipping validation."
    Write-Host "Please ensure OpenCode is installed to use these agents."
}

Write-Host ""
Write-Color "Installation Complete! 🚀" "Green"
Write-Host "Your Speclet Council agents are ready."
