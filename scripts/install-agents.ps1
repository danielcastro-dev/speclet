<#
.SYNOPSIS
    Speclet Bootstrap Installer (PowerShell)
    Installs Speclet Council agents to your environment.

.DESCRIPTION
    This script detects the Windows environment, prompts for an installation path,
    backs up existing agents if found, and copies the new agent templates.
#>

param(
    [switch]$Force,
    [string]$Target
)

$ErrorActionPreference = "Stop"

# --- Configuration ---
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SourceDir = Join-Path $RepoRoot ".opencode\agent"
$GlobalConfigDir = Join-Path $env:USERPROFILE ".config\opencode\agent"
$AltConfigDir = Join-Path $env:USERPROFILE ".opencode\agent"
$LocalConfigDir = Join-Path $RepoRoot ".opencode\agent"

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

function Normalize-Path($Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    try {
        return (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path.TrimEnd("\")
    } catch {
        return [System.IO.Path]::GetFullPath($Path).TrimEnd("\")
    }
}

function Test-WriteAccess($Path) {
    try {
        $tempFile = Join-Path $Path ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType File -Path $tempFile -Force | Out-Null
        Remove-Item -Path $tempFile -Force
        return $true
    } catch {
        return $false
    }
}

# --- 1. Environment Detection ---
Log "Detecting environment..."
Log "OS: Windows (PowerShell)"

# --- 2. Check Source Files ---
if (-not (Test-Path $SourceDir)) {
    ErrorExit "Source directory '$SourceDir' not found. Run this script from the speclet repo root."
}

$AgentFiles = Get-ChildItem -Path $SourceDir -Filter "*.md" -File
if (-not $AgentFiles -or $AgentFiles.Count -eq 0) {
    ErrorExit "No agent templates found in '$SourceDir'. Cannot proceed."
}

# --- 3. Path Selection ---
$DefaultChoice = "1"
if (Test-Path $GlobalConfigDir) {
    $DefaultChoice = "1"
} elseif (Test-Path $AltConfigDir) {
    $DefaultChoice = "2"
} elseif (Test-Path $LocalConfigDir) {
    $DefaultChoice = "3"
}

if ($Force -and $Target) {
    $TargetDir = $Target
    Log "Force mode enabled. Using target path: $TargetDir"
} elseif ($Force) {
    $TargetDir = $GlobalConfigDir
    Log "Force mode enabled. Defaulting to Global Config: $TargetDir"
} elseif ($Target) {
    $TargetDir = $Target
    Log "Using target path: $TargetDir"
} else {
    Write-Host ""
    Write-Host "Select installation target:"
    Write-Host "  1) Global User Config ($GlobalConfigDir)$(if (Test-Path $GlobalConfigDir) { ' [found]' } else { ' [missing]' })"
    Write-Host "  2) User Home Config ($AltConfigDir)$(if (Test-Path $AltConfigDir) { ' [found]' } else { ' [missing]' })"
    Write-Host "  3) Project Local Config ($LocalConfigDir)$(if (Test-Path $LocalConfigDir) { ' [found]' } else { ' [missing]' })"
    Write-Host "  4) Custom Path"

    $Choice = Read-Host "Enter choice [$DefaultChoice]"
    if ([string]::IsNullOrWhiteSpace($Choice)) { $Choice = $DefaultChoice }

    switch ($Choice) {
        "1" { $TargetDir = $GlobalConfigDir }
        "2" { $TargetDir = $AltConfigDir }
        "3" { $TargetDir = $LocalConfigDir }
        "4" { $TargetDir = Read-Host "Enter custom path" }
        Default { ErrorExit "Invalid choice" }
    }
}

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    ErrorExit "Target directory was not provided."
}

Log "Target directory: $TargetDir"

if (-not (Test-Path $TargetDir)) {
    if ($Force -or $Target) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    } else {
        $CreateConfirm = Read-Host "Directory '$TargetDir' does not exist. Create it? [Y/n]"
        if ([string]::IsNullOrWhiteSpace($CreateConfirm)) { $CreateConfirm = "Y" }

        if ($CreateConfirm -match "^[Yy]") {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        } else {
            ErrorExit "Installation cancelled."
        }
    }
}

if (-not (Test-WriteAccess $TargetDir)) {
    ErrorExit "Target directory is not writable: $TargetDir"
}

$NormalizedSource = Normalize-Path $SourceDir
$NormalizedTarget = Normalize-Path $TargetDir
if ($NormalizedSource -and $NormalizedTarget -and ($NormalizedSource -ieq $NormalizedTarget)) {
    Warn "Source and target resolve to the same path ($NormalizedTarget)."
    Write-Host "Local install is unnecessary when running inside the source repository."
    exit 0
}

# --- 4. Backup Logic ---
$ExistingAgentFiles = @()
foreach ($agent in $AgentFiles) {
    $DestinationFile = Join-Path $TargetDir $agent.Name
    if (Test-Path $DestinationFile) {
        $ExistingAgentFiles += $DestinationFile
    }
}

if ($ExistingAgentFiles.Count -gt 0) {
    Log "Existing agents detected. Creating backup..."
    $BackupRoot = Join-Path (Split-Path $TargetDir -Parent) "backups"
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupDir = Join-Path $BackupRoot "agents_backup_$Timestamp"

    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    foreach ($file in $ExistingAgentFiles) {
        Copy-Item $file $BackupDir -Force
    }

    Log "Backup created at: $BackupDir"

    if (Test-Path $BackupRoot) {
        $BackupDirs = Get-ChildItem -Path $BackupRoot -Directory -Filter "agents_backup_*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending
        $OldBackups = $BackupDirs | Select-Object -Skip 3
        foreach ($dir in $OldBackups) {
            try {
                Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction Stop
                Log "Removed old backup: $($dir.Name)"
            } catch {
                Warn "Failed to remove old backup '$($dir.FullName)': $($_.Exception.Message)"
            }
        }
    }
} else {
    Log "No existing agents found. Skipping backup."
}

# --- 5. Installation ---
Log "Installing agents..."
foreach ($agent in $AgentFiles) {
    Copy-Item $agent.FullName $TargetDir -Force
    Write-Host "  - Installed $($agent.Name)"
}

# --- 6. Validation (Conditional) ---
Write-Host ""
if (Get-Command opencode -ErrorAction SilentlyContinue) {
    Log "Validating installation with OpenCode CLI..."

    try {
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
