<# 
.SYNOPSIS
    Speclet Autonomous Loop Runner
.DESCRIPTION
    Runs OpenCode with speclet-loop skill until all stories pass.
    Includes model fallback with retry logic.
.PARAMETER MaxIterations
    Maximum iterations before stopping. Default: 10
.EXAMPLE
    .\speclet.ps1
    .\speclet.ps1 -MaxIterations 20
#>

param(
    [int]$MaxIterations = 10
)

$ErrorActionPreference = "Stop"

$SPEC_FILE = ".speclet/spec.json"
$PROGRESS_FILE = ".speclet/progress.md"
$ARCHIVE_DIR = ".speclet/archive"

$MODELS = @(
    "github-copilot/claude-opus-4.5"
    "google/antigravity-claude-opus-4-5-thinking-medium"
    "openai/gpt-5.2-codex"
    "opencode/glm-4.7-free"
    "opencode/minimax-m2.1-free"
)
$MAX_RETRIES = 3
$script:CurrentModelIdx = 0

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Dependencies {
    if (-not (Get-Command "opencode" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Error: opencode CLI is required. See: https://opencode.ai" "Red"
        exit 1
    }
}

function Test-Spec {
    if (-not (Test-Path $SPEC_FILE)) {
        Write-ColorOutput "Error: $SPEC_FILE not found" "Red"
        Write-ColorOutput "Create a spec first:" "Yellow"
        Write-Host "  1. Use the speclet-draft skill for [your feature]"
        Write-Host "  2. Use the speclet-spec skill"
        exit 1
    }
}

function Get-SpecData {
    return Get-Content $SPEC_FILE -Raw | ConvertFrom-Json
}

function Get-FeatureInfo {
    $spec = Get-SpecData
    Write-ColorOutput "Feature: $($spec.feature)" "Cyan"
    Write-ColorOutput "Branch: $($spec.branch)" "Cyan"
    return $spec
}

function Get-StoryCount {
    $spec = Get-SpecData
    $total = $spec.stories.Count
    $passing = ($spec.stories | Where-Object { $_.passes -eq $true }).Count
    $remaining = $total - $passing
    Write-ColorOutput "Stories: $passing/$total complete ($remaining remaining)" "Cyan"
    return @{ Total = $total; Passing = $passing; Remaining = $remaining }
}

function Test-AllComplete {
    $spec = Get-SpecData
    $remaining = ($spec.stories | Where-Object { $_.passes -eq $false }).Count
    return $remaining -eq 0
}

function Get-NextStory {
    $spec = Get-SpecData
    $next = $spec.stories | Where-Object { $_.passes -eq $false } | Sort-Object priority | Select-Object -First 1
    if ($next) {
        return "$($next.id): $($next.title)"
    }
    return $null
}

function Set-CorrectBranch {
    param([string]$BranchName)
    
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $BranchName) {
        Write-ColorOutput "Switching to branch: $BranchName" "Yellow"
        $branchExists = git show-ref --verify --quiet "refs/heads/$BranchName" 2>$null
        if ($LASTEXITCODE -eq 0) {
            git checkout $BranchName
        } else {
            git checkout -b $BranchName
        }
    }
}

function Show-ModelInfo {
    $model = $MODELS[$script:CurrentModelIdx]
    $total = $MODELS.Count
    Write-ColorOutput "Model: $model ($($script:CurrentModelIdx + 1)/$total)" "Cyan"
}

function Show-Models {
    Write-ColorOutput "Configured models (in fallback order):" "Cyan"
    for ($i = 0; $i -lt $MODELS.Count; $i++) {
        if ($i -eq 0) {
            Write-ColorOutput "  $i. $($MODELS[$i]) (primary)" "Green"
        } elseif ($i -lt 3) {
            Write-ColorOutput "  $i. $($MODELS[$i]) (fallback)" "Yellow"
        } else {
            Write-ColorOutput "  $i. $($MODELS[$i]) (free)" "Blue"
        }
    }
}

function Invoke-OpenCodeWithFallback {
    $retries = 0
    $delay = 5
    
    while ($true) {
        $model = $MODELS[$script:CurrentModelIdx]
        
        Write-ColorOutput "Using model: $model" "Cyan"
        
        try {
            $result = & opencode -m $model -p "Use the speclet-loop skill"
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
            throw "OpenCode exited with code $LASTEXITCODE"
        } catch {
            $retries++
            Write-ColorOutput "OpenCode failed: $_" "Yellow"
            
            if ($retries -lt $MAX_RETRIES) {
                Write-ColorOutput "Retry $retries/$MAX_RETRIES with $model (waiting ${delay}s)..." "Yellow"
                Start-Sleep -Seconds $delay
                $delay = $delay * 3
                continue
            }
            
            $script:CurrentModelIdx++
            $retries = 0
            $delay = 5
            
            if ($script:CurrentModelIdx -ge $MODELS.Count) {
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Red"
                Write-ColorOutput "All models exhausted. Tried:" "Red"
                foreach ($m in $MODELS) {
                    Write-ColorOutput "  - $m" "Red"
                }
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Red"
                return $false
            }
            
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Yellow"
            Write-ColorOutput "Switching to fallback model: $($MODELS[$script:CurrentModelIdx])" "Yellow"
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Yellow"
        }
    }
}

function Invoke-Iteration {
    param([int]$Iteration)
    
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    Write-ColorOutput "Iteration $Iteration/$MaxIterations" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    
    Show-ModelInfo
    
    $nextStory = Get-NextStory
    Write-ColorOutput "Next story: $nextStory" "Cyan"
    Write-Host ""
    
    $success = Invoke-OpenCodeWithFallback
    if (-not $success) {
        Write-ColorOutput "Failed to run opencode with any model" "Red"
        return 2
    }
    
    if (Test-AllComplete) {
        return 0
    }
    return 1
}

function Save-Archive {
    param([string]$FeatureName)
    
    $date = Get-Date -Format "yyyy-MM-dd"
    $featureSlug = $FeatureName.ToLower() -replace '[^a-z0-9]', '-' -replace '--+', '-'
    $archivePath = "$ARCHIVE_DIR/$date-$featureSlug"
    
    Write-ColorOutput "Archiving to: $archivePath" "Cyan"
    New-Item -ItemType Directory -Path $archivePath -Force | Out-Null
    
    if (Test-Path ".speclet/draft.md") { Move-Item ".speclet/draft.md" $archivePath -Force }
    if (Test-Path $SPEC_FILE) { Move-Item $SPEC_FILE $archivePath -Force }
    if (Test-Path $PROGRESS_FILE) { Move-Item $PROGRESS_FILE $archivePath -Force }
    
    Write-ColorOutput "Archived!" "Green"
}

function Main {
    Write-ColorOutput @"

╔═══════════════════════════════════════════════════════════╗
║                    SPECLET AUTONOMOUS LOOP                ║
╚═══════════════════════════════════════════════════════════╝
"@ "Green"
    
    Test-Dependencies
    Test-Spec
    $spec = Get-FeatureInfo
    Get-StoryCount | Out-Null
    Show-Models
    Write-Host ""
    
    if (Test-AllComplete) {
        Write-ColorOutput "✅ All stories already complete!" "Green"
        exit 0
    }
    
    Set-CorrectBranch -BranchName $spec.branch
    
    for ($i = 1; $i -le $MaxIterations; $i++) {
        $result = Invoke-Iteration -Iteration $i
        
        if ($result -eq 0) {
            Write-Host ""
            Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" "Green"
            Write-ColorOutput "║              ✅ COMPLETE - All stories passing!           ║" "Green"
            Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" "Green"
            Write-Host ""
            Get-StoryCount | Out-Null
            
            Write-Host ""
            $archive = Read-Host "Archive spec files? (y/n)"
            if ($archive -eq 'y') {
                Save-Archive -FeatureName $spec.feature
            }
            
            Write-Host ""
            $createPR = Read-Host "Create PR? (y/n)"
            if ($createPR -eq 'y') {
                Write-ColorOutput "Creating PR..." "Cyan"
                gh pr create --fill
            }
            
            exit 0
        } elseif ($result -eq 2) {
            Write-ColorOutput "Cannot continue - all models failed" "Red"
            exit 1
        }
        
        Start-Sleep -Seconds 2
    }
    
    Write-Host ""
    Write-ColorOutput "⚠️  Max iterations ($MaxIterations) reached" "Yellow"
    Get-StoryCount | Out-Null
    Write-ColorOutput "Run again to continue: .\speclet.ps1" "Yellow"
    exit 1
}

Main
