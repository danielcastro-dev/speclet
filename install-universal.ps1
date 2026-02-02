<#
.SYNOPSIS
    Universal Speclet Installer for Windows and Linux
.DESCRIPTION
    Downloads and installs Speclet from a GitHub repository.
    Can be invoked from any directory.
.PARAMETER RepositoryUrl
    Git repository URL (default: https://github.com/danielcastro-dev/speclet.git)
.PARAMETER Branch
    Git branch to checkout (default: main)
.PARAMETER TargetDir
    Installation target directory (default: current directory)
.EXAMPLE
    powershell -ExecutionPolicy Bypass -Command "IEX (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.ps1').Content"
    
    # Or locally:
    .\install-universal.ps1 -RepositoryUrl https://github.com/danielcastro-dev/speclet.git -TargetDir .
#>

param(
    [string]$RepositoryUrl = "https://github.com/danielcastro-dev/speclet.git",
    [string]$Branch = "main",
    [string]$TargetDir = "."
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput @"

╔═══════════════════════════════════════════════════════════╗
║              SPECLET UNIVERSAL INSTALLER                  ║
╚═══════════════════════════════════════════════════════════╝
"@ "Green"

# Validate target directory
if (-not (Test-Path $TargetDir)) {
    Write-ColorOutput "Error: Target directory does not exist: $TargetDir" "Red"
    exit 1
}

$TargetDir = (Resolve-Path $TargetDir).Path
Write-Host "Target: $TargetDir"
Write-Host "Repository: $RepositoryUrl"
Write-Host ""

# Create temporary directory for installation files
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "speclet-install-$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    Write-Host "Downloading Speclet from repository..."
    
    # Check if git is available
    $GitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    
    if ($GitAvailable) {
        # Clone the repository
        Push-Location $TempDir
        git clone --branch $Branch $RepositoryUrl speclet-repo 2>&1 | Out-Null
        Pop-Location
        $SourceDir = Join-Path $TempDir "speclet-repo"
    } else {
        # Fallback: Download as ZIP
        Write-Host "Git not found, downloading as ZIP..."
        $ZipUrl = $RepositoryUrl -replace "\.git$", "" -replace "https://github.com/", "https://github.com/" + "archive/refs/heads/$Branch.zip"
        $ZipPath = Join-Path $TempDir "speclet.zip"
        
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -ErrorAction SilentlyContinue
        
        if (-not (Test-Path $ZipPath)) {
            Write-ColorOutput "Error: Could not download repository" "Red"
            exit 1
        }
        
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
        $ExtractedFolder = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "speclet-*" } | Select-Object -First 1
        $SourceDir = $ExtractedFolder.FullName
    }
    
    if (-not (Test-Path $SourceDir)) {
        Write-ColorOutput "Error: Could not retrieve Speclet files" "Red"
        exit 1
    }
    
    Write-Host "Installing files..."
    
    # Create directories
    New-Item -ItemType Directory -Path "$TargetDir/.speclet/templates" -Force | Out-Null
    New-Item -ItemType Directory -Path "$TargetDir/.speclet/tickets" -Force | Out-Null
    New-Item -ItemType Directory -Path "$TargetDir/.speclet/archive" -Force | Out-Null
    New-Item -ItemType Directory -Path "$TargetDir/.opencode/skill" -Force | Out-Null
    New-Item -ItemType Directory -Path "$TargetDir/.codex/skills" -Force | Out-Null
    
    # Copy files
    Copy-Item "$SourceDir/GUIDE.md" "$TargetDir/.speclet/" -Force -ErrorAction SilentlyContinue
    Copy-Item "$SourceDir/loop.md" "$TargetDir/.speclet/" -Force -ErrorAction SilentlyContinue
    Copy-Item "$SourceDir/templates/*" "$TargetDir/.speclet/templates/" -Force -ErrorAction SilentlyContinue
    Copy-Item "$SourceDir/skills/*" "$TargetDir/.opencode/skill/" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item "$SourceDir/skills/*" "$TargetDir/.codex/skills/" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item "$SourceDir/speclet.sh" "$TargetDir/" -Force -ErrorAction SilentlyContinue
    Copy-Item "$SourceDir/speclet.ps1" "$TargetDir/" -Force -ErrorAction SilentlyContinue
    
    # Create DECISIONS.md if not exists
    if (-not (Test-Path "$TargetDir/.speclet/DECISIONS.md")) {
        @"
# Architecture Decisions

> Permanent file. Do NOT move to archive.

---
"@ | Set-Content "$TargetDir/.speclet/DECISIONS.md"
    }
    
    # Update .gitignore
    $gitignore = "$TargetDir/.gitignore"
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
    
    Write-ColorOutput "✓ Installed:" "Blue"
    Write-Host "  .speclet/GUIDE.md"
    Write-Host "  .speclet/loop.md"
    Write-Host "  .speclet/DECISIONS.md"
    Write-Host "  .speclet/templates/*"
    Write-Host "  .opencode/skill/*"
    Write-Host "  .codex/skills/*"
    Write-Host "  ./speclet.sh"
    Write-Host "  ./speclet.ps1"
    Write-Host ""
    Write-ColorOutput "Ready! Usage:" "Green"
    Write-Host "  Use the speclet-draft skill for [feature]"
    Write-Host "  Use the speclet-spec skill"
    Write-Host "  Use the speclet-council skill"
    Write-Host ""
    Write-Host "  Or autonomous: .\speclet.ps1"
    Write-Host ""
    
} catch {
    Write-ColorOutput "Error: $_" "Red"
    exit 1
} finally {
    # Cleanup
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
