<#
.SYNOPSIS
    Test script for Speclet installation
.DESCRIPTION
    Creates a test directory and verifies installation
.EXAMPLE
    .\test-install.ps1
#>

$ErrorActionPreference = "Stop"

$TestDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "speclet-test-$(Get-Random)") -Force

Write-Host "Testing Speclet installation in: $TestDir"

try {
    Push-Location $TestDir
    
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    
    Write-Host "Running install-universal.ps1..."
    & "$ScriptDir\install-universal.ps1" `
        -RepositoryUrl "file://$ScriptDir" `
        -Branch main `
        -TargetDir "."
    
    Write-Host ""
    Write-Host "Verifying installation..."
    
    $checks = @(
        ".speclet/GUIDE.md"
        ".speclet/loop.md"
        ".speclet/DECISIONS.md"
        ".speclet/templates"
        ".opencode/skill"
        ".codex/skills"
        "speclet.ps1"
        ".gitignore"
    )
    
    $allPassed = $true
    foreach ($check in $checks) {
        if (Test-Path $check) {
            Write-Host "✓ $check"
        } else {
            Write-Host "✗ $check"
            $allPassed = $false
        }
    }
    
    if ($allPassed) {
        Write-Host ""
        Write-Host "✓ All checks passed!"
    } else {
        exit 1
    }
    
} finally {
    Pop-Location
    Remove-Item -Path $TestDir -Recurse -Force
}
