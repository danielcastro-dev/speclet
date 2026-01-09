<# 
.SYNOPSIS
    Speclet Autonomous Loop Runner
.DESCRIPTION
    Runs OpenCode with speclet-loop skill until all stories pass.
    Includes model fallback, build verification, and checkpoint/resume.
.PARAMETER MaxIterations
    Maximum iterations before stopping. Default: 10
.EXAMPLE
    .\speclet.ps1
    .\speclet.ps1 -MaxIterations 20
#>

param(
    [int]$MaxIterations = 10
)

$ErrorActionPreference = "Continue"

$SPEC_FILE = ".speclet/spec.json"
$PROGRESS_FILE = ".speclet/progress.md"
$ARCHIVE_DIR = ".speclet/archive"
$CONFIG_FILE = ".speclet/config.json"
$CHECKPOINT_FILE = ".speclet/checkpoint.json"
$LOG_FILE = ".speclet/loop.log"

$script:MODELS = @(
    "github-copilot/claude-opus-4.5"
    "google/antigravity-claude-opus-4-5-thinking-medium"
    "openai/gpt-5.2-codex"
    "opencode/glm-4.7-free"
    "opencode/minimax-m2.1-free"
)
$script:MAX_RETRIES = 3
$script:MAX_STORY_FAILURES = 3
$script:BUILD_COMMAND = "npm run build"
$script:VERIFY_BUILD = $true
$script:CurrentModelIdx = 0
$script:StoryFailures = @{}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Add-Content -Path $LOG_FILE -Value $logMessage -ErrorAction SilentlyContinue
    Write-ColorOutput $Message $Color
}

function Import-Config {
    if (Test-Path $CONFIG_FILE) {
        Write-ColorOutput "Loading config from $CONFIG_FILE" "Cyan"
        try {
            $config = Get-Content $CONFIG_FILE -Raw | ConvertFrom-Json
            
            if ($config.models) { $script:MODELS = $config.models }
            if ($config.maxRetries) { $script:MAX_RETRIES = $config.maxRetries }
            if ($config.maxStoryFailures) { $script:MAX_STORY_FAILURES = $config.maxStoryFailures }
            if ($config.buildCommand) { $script:BUILD_COMMAND = $config.buildCommand }
            if ($null -ne $config.verifyBuild) { $script:VERIFY_BUILD = $config.verifyBuild }
            if ($config.logFile) { $script:LOG_FILE = $config.logFile }
        } catch {
            Write-ColorOutput "Warning: Could not parse config file" "Yellow"
        }
    }
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
    $blocked = ($spec.stories | Where-Object { $_.blocked -eq $true }).Count
    $remaining = $total - $passing - $blocked
    Write-ColorOutput "Stories: $passing/$total complete ($remaining remaining, $blocked blocked)" "Cyan"
    return @{ Total = $total; Passing = $passing; Remaining = $remaining; Blocked = $blocked }
}

function Test-AllComplete {
    $spec = Get-SpecData
    $remaining = ($spec.stories | Where-Object { $_.passes -eq $false -and $_.blocked -ne $true }).Count
    return $remaining -eq 0
}

function Get-NextStoryId {
    $spec = Get-SpecData
    $next = $spec.stories | Where-Object { $_.passes -eq $false -and $_.blocked -ne $true } | Sort-Object priority | Select-Object -First 1
    if ($next) { return $next.id }
    return $null
}

function Get-NextStoryDisplay {
    $spec = Get-SpecData
    $next = $spec.stories | Where-Object { $_.passes -eq $false -and $_.blocked -ne $true } | Sort-Object priority | Select-Object -First 1
    if ($next) { return "$($next.id): $($next.title)" }
    return $null
}

function Set-CorrectBranch {
    param([string]$BranchName)
    
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $BranchName) {
        Write-ColorOutput "Switching to branch: $BranchName" "Yellow"
        $null = git show-ref --verify --quiet "refs/heads/$BranchName" 2>$null
        if ($LASTEXITCODE -eq 0) {
            git checkout $BranchName
        } else {
            git checkout -b $BranchName
        }
    }
}

function Show-ModelInfo {
    $model = $script:MODELS[$script:CurrentModelIdx]
    $total = $script:MODELS.Count
    Write-ColorOutput "Model: $model ($($script:CurrentModelIdx + 1)/$total)" "Cyan"
}

function Show-Models {
    Write-ColorOutput "Configured models (in fallback order):" "Cyan"
    for ($i = 0; $i -lt $script:MODELS.Count; $i++) {
        if ($i -eq 0) {
            Write-ColorOutput "  $i. $($script:MODELS[$i]) (primary)" "Green"
        } elseif ($i -lt 3) {
            Write-ColorOutput "  $i. $($script:MODELS[$i]) (fallback)" "Yellow"
        } else {
            Write-ColorOutput "  $i. $($script:MODELS[$i]) (free)" "Blue"
        }
    }
}

function Save-Checkpoint {
    param([string]$StoryId, [int]$Iteration, [int]$Failures)
    
    $checkpoint = @{
        lastStory = $StoryId
        iteration = $Iteration
        storyFailures = $Failures
        modelIndex = $script:CurrentModelIdx
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    }
    $checkpoint | ConvertTo-Json | Set-Content $CHECKPOINT_FILE
    Write-Log "Checkpoint saved: story=$StoryId, iteration=$Iteration" "Cyan"
}

function Import-Checkpoint {
    if (Test-Path $CHECKPOINT_FILE) {
        Write-ColorOutput "Found checkpoint, resuming..." "Cyan"
        try {
            $checkpoint = Get-Content $CHECKPOINT_FILE -Raw | ConvertFrom-Json
            $script:CurrentModelIdx = $checkpoint.modelIndex
            Write-Log "Resumed from checkpoint: iteration=$($checkpoint.iteration), model_idx=$($checkpoint.modelIndex)" "Cyan"
            return $checkpoint.iteration
        } catch {
            return 1
        }
    }
    return 1
}

function Remove-Checkpoint {
    if (Test-Path $CHECKPOINT_FILE) { Remove-Item $CHECKPOINT_FILE -Force }
}

function Set-StoryBlocked {
    param([string]$StoryId)
    
    $spec = Get-SpecData
    foreach ($story in $spec.stories) {
        if ($story.id -eq $StoryId) {
            $story | Add-Member -NotePropertyName "blocked" -NotePropertyValue $true -Force
        }
    }
    $spec | ConvertTo-Json -Depth 10 | Set-Content $SPEC_FILE
    Write-Log "Story $StoryId marked as BLOCKED after $script:MAX_STORY_FAILURES failures" "Red"
}

function Test-Build {
    if (-not $script:VERIFY_BUILD) { return $true }
    
    Write-Log "Verifying build: $script:BUILD_COMMAND" "Cyan"
    
    try {
        $output = Invoke-Expression $script:BUILD_COMMAND 2>&1
        $output | Add-Content -Path $LOG_FILE -ErrorAction SilentlyContinue
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Build passed ✓" "Green"
            return $true
        } else {
            Write-Log "Build FAILED ✗" "Red"
            return $false
        }
    } catch {
        Write-Log "Build FAILED: $_" "Red"
        return $false
    }
}

function Undo-Changes {
    Write-Log "Reverting uncommitted changes..." "Yellow"
    git checkout . 2>$null
    git clean -fd 2>$null
}

function Invoke-OpenCodeWithFallback {
    $retries = 0
    $delay = 5
    
    while ($true) {
        $model = $script:MODELS[$script:CurrentModelIdx]
        
        Write-Log "Using model: $model" "Cyan"
        
        try {
            & opencode -m $model -p "Use the speclet-loop skill" 2>&1 | Add-Content -Path $LOG_FILE -ErrorAction SilentlyContinue
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
            throw "OpenCode exited with code $LASTEXITCODE"
        } catch {
            $retries++
            Write-Log "OpenCode failed: $_" "Yellow"
            
            if ($retries -lt $script:MAX_RETRIES) {
                Write-Log "Retry $retries/$script:MAX_RETRIES with $model (waiting ${delay}s)..." "Yellow"
                Start-Sleep -Seconds $delay
                $delay = $delay * 3
                continue
            }
            
            $script:CurrentModelIdx++
            $retries = 0
            $delay = 5
            
            if ($script:CurrentModelIdx -ge $script:MODELS.Count) {
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Red"
                Write-Log "All models exhausted" "Red"
                foreach ($m in $script:MODELS) {
                    Write-ColorOutput "  - $m" "Red"
                }
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Red"
                return $false
            }
            
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Yellow"
            Write-Log "Switching to fallback model: $($script:MODELS[$script:CurrentModelIdx])" "Yellow"
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Yellow"
        }
    }
}

function Invoke-Iteration {
    param([int]$Iteration)
    
    Write-Host ""
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    Write-Log "Iteration $Iteration/$MaxIterations" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    
    Show-ModelInfo
    
    $storyId = Get-NextStoryId
    $storyDisplay = Get-NextStoryDisplay
    
    if (-not $storyId) {
        Write-Log "No more stories to process" "Green"
        return 0
    }
    
    Write-Log "Next story: $storyDisplay" "Cyan"
    
    $currentFailures = if ($script:StoryFailures.ContainsKey($storyId)) { $script:StoryFailures[$storyId] } else { 0 }
    
    if ($currentFailures -ge $script:MAX_STORY_FAILURES) {
        Write-Log "Story $storyId has failed $currentFailures times, marking as blocked" "Red"
        Set-StoryBlocked -StoryId $storyId
        return 1
    }
    
    Save-Checkpoint -StoryId $storyId -Iteration $Iteration -Failures $currentFailures
    
    Write-Host ""
    
    $success = Invoke-OpenCodeWithFallback
    if (-not $success) {
        Write-Log "Failed to run opencode with any model" "Red"
        return 2
    }
    
    if ($script:VERIFY_BUILD) {
        if (-not (Test-Build)) {
            Write-Log "Build failed after story implementation, reverting..." "Red"
            Undo-Changes
            
            $script:StoryFailures[$storyId] = $currentFailures + 1
            Write-Log "Story $storyId failure count: $($script:StoryFailures[$storyId])/$script:MAX_STORY_FAILURES" "Yellow"
            
            return 1
        }
    }
    
    $script:StoryFailures[$storyId] = 0
    
    if (Test-AllComplete) {
        Remove-Checkpoint
        return 0
    }
    return 1
}

function Save-Archive {
    param([string]$FeatureName)
    
    $date = Get-Date -Format "yyyy-MM-dd"
    $featureSlug = $FeatureName.ToLower() -replace '[^a-z0-9]', '-' -replace '--+', '-'
    $archivePath = "$ARCHIVE_DIR/$date-$featureSlug"
    
    Write-Log "Archiving to: $archivePath" "Cyan"
    New-Item -ItemType Directory -Path $archivePath -Force | Out-Null
    
    if (Test-Path ".speclet/draft.md") { Move-Item ".speclet/draft.md" $archivePath -Force }
    if (Test-Path $SPEC_FILE) { Move-Item $SPEC_FILE $archivePath -Force }
    if (Test-Path $PROGRESS_FILE) { Move-Item $PROGRESS_FILE $archivePath -Force }
    if (Test-Path $LOG_FILE) { Copy-Item $LOG_FILE $archivePath -Force }
    
    Write-Log "Archived!" "Green"
}

function Test-GhAuth {
    $null = gh auth status 2>&1
    return $LASTEXITCODE -eq 0
}

function Invoke-GhAuth {
    if (Test-GhAuth) { return $true }
    
    Write-ColorOutput "GitHub CLI not authenticated." "Yellow"
    Write-Host ""
    Write-ColorOutput "Options:" "Cyan"
    Write-Host "  1. Enter token manually"
    Write-Host "  2. Skip PR creation"
    Write-Host ""
    $choice = Read-Host "Choice (1/2)"
    
    if ($choice -eq "1") {
        Write-ColorOutput "Enter your GitHub token (ghp_...):" "Cyan"
        $token = Read-Host
        if ($token) {
            $token | gh auth login --with-token 2>&1 | Out-Null
            if (Test-GhAuth) {
                Write-Log "GitHub authenticated!" "Green"
                return $true
            } else {
                Write-Log "GitHub authentication failed" "Red"
                return $false
            }
        }
    }
    return $false
}

function New-PullRequest {
    if (Invoke-GhAuth) {
        Write-Log "Creating PR..." "Cyan"
        gh pr create --fill
    } else {
        Write-ColorOutput "Skipping PR. Create manually:" "Yellow"
        Write-Host "  gh auth login"
        Write-Host "  gh pr create --fill"
    }
}

function Main {
    $logDir = Split-Path $LOG_FILE -Parent
    if ($logDir -and -not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    Write-ColorOutput @"

╔═══════════════════════════════════════════════════════════╗
║                    SPECLET AUTONOMOUS LOOP                ║
╚═══════════════════════════════════════════════════════════╝
"@ "Green"
    
    Write-Log "Session started" "Green"
    
    Test-Dependencies
    Import-Config
    Test-Spec
    $spec = Get-FeatureInfo
    Get-StoryCount | Out-Null
    Show-Models
    Write-ColorOutput "Build command: $script:BUILD_COMMAND" "Cyan"
    Write-ColorOutput "Verify build: $script:VERIFY_BUILD" "Cyan"
    Write-ColorOutput "Log file: $LOG_FILE" "Cyan"
    Write-Host ""
    
    if (Test-AllComplete) {
        Write-Log "All stories already complete!" "Green"
        exit 0
    }
    
    $startIteration = Import-Checkpoint
    
    Set-CorrectBranch -BranchName $spec.branch
    
    for ($i = $startIteration; $i -le $MaxIterations; $i++) {
        $result = Invoke-Iteration -Iteration $i
        
        if ($result -eq 0) {
            Write-Host ""
            Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" "Green"
            Write-ColorOutput "║              ✅ COMPLETE - All stories passing!           ║" "Green"
            Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" "Green"
            Write-Host ""
            Get-StoryCount | Out-Null
            Write-Log "All stories complete!" "Green"
            
            Write-Host ""
            $archive = Read-Host "Archive spec files? (y/n)"
            if ($archive -eq 'y') {
                Save-Archive -FeatureName $spec.feature
            }
            
            Write-Host ""
            $createPR = Read-Host "Create PR? (y/n)"
            if ($createPR -eq 'y') {
                New-PullRequest
            }
            
            exit 0
        } elseif ($result -eq 2) {
            Write-Log "Cannot continue - all models failed" "Red"
            exit 1
        }
        
        Start-Sleep -Seconds 2
    }
    
    Write-Host ""
    Write-Log "Max iterations ($MaxIterations) reached" "Yellow"
    Get-StoryCount | Out-Null
    Write-ColorOutput "Run again to continue: .\speclet.ps1" "Yellow"
    exit 1
}

Main
