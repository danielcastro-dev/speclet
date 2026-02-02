# Speclet

Lightweight spec-driven development workflow for LLM-assisted coding sessions.

**⚡ Quick Install:**
```powershell
# Windows
powershell -ExecutionPolicy Bypass -Command "IEX (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.ps1').Content"
```

```bash
# Linux/macOS
bash <(curl -s https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.sh)
```

See [INSTALLATION.md](INSTALLATION.md) for more options and details.

## What is Speclet?

Speclet is a structured workflow for developing features with AI assistants (Claude, GPT, etc.). It provides:

- **Phased approach**: Draft (markdown) → Spec (JSON) → Implementation → Archive
- **Tiered complexity**: Scale documentation based on task size
- **Context persistence**: Decisions and patterns survive across sessions
- **Atomic commits**: 1 story = 1 commit
- **Trackable progress**: JSON specs with `passes: true/false` for each story
- **Autonomous loop**: Run unattended with model fallback and build verification

## Quick Start

### Installation in Your Project

#### Option 1: One-Line Installation (Recommended)

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -Command "IEX (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.ps1').Content"
```

**Linux/macOS (bash):**
```bash
bash <(curl -s https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.sh)
```

#### Option 2: Clone and Install

**Windows (PowerShell):**
```powershell
git clone https://github.com/danielcastro-dev/speclet.git _speclet-installer
cd _speclet-installer
powershell -ExecutionPolicy Bypass -File .\install-universal.ps1
cd ..
Remove-Item -Recurse -Force _speclet-installer
```

**Linux/macOS (bash):**
```bash
git clone https://github.com/danielcastro-dev/speclet.git _speclet-installer
cd _speclet-installer
bash install-universal.sh
cd ..
rm -rf _speclet-installer
```

#### Option 3: Manual Installation

1. Copy the `skills/` folder to `.opencode/skill/`
2. Copy `GUIDE.md` and `loop.md` to `.speclet/`
3. Copy template files to `.speclet/templates/`
4. Copy `speclet.sh` and `speclet.ps1` to your project root

### What Gets Installed

The installer creates the following structure:
```
your-project/
├── .speclet/
│   ├── GUIDE.md                  # LLM instructions (permanent)
│   ├── loop.md                   # Loop runner documentation
│   ├── DECISIONS.md              # Architecture decisions (tracked)
│   ├── templates/                # Template files
│   ├── tickets/                  # Individual task tickets
│   └── archive/                  # Completed work
├── .opencode/skill/
│   ├── speclet-draft/            # Feature draft skill
│   ├── speclet-spec/             # Spec generation skill
│   ├── speclet-council/          # Review/validation skill
│   ├── speclet-ticket/           # Ticket generation skill
│   └── speclet-learn/            # Learning extraction skill
├── .codex/skills/
│   ├── speclet-draft/            # OpenAI Codex: Feature draft skill
│   ├── speclet-spec/             # OpenAI Codex: Spec generation skill
│   ├── speclet-council/          # OpenAI Codex: Review/validation skill
│   ├── speclet-ticket/           # OpenAI Codex: Ticket generation skill
│   └── speclet-learn/            # OpenAI Codex: Learning extraction skill
├── speclet.sh                    # Loop runner (Linux/macOS)
├── speclet.ps1                   # Loop runner (Windows)
└── .gitignore                    # Updated with .speclet/ rules
```

### Supported Platforms

- **OpenCode Skills** (.opencode/skill/)
- **OpenAI Codex Skills** (.codex/skills/)
- **OpenCode Autonomous Loop** (speclet.sh / speclet.ps1)

### Prerequisites

- **OpenCode** or **OpenAI Codex** installed on your system
- **Git** (optional; installer falls back to ZIP download if not available)
- **PowerShell 5.0+** (Windows) or **bash 4.0+** (Linux/macOS)

### Project Structure

```
your-project/
├── .opencode/skill/              # OpenCode skills
│   ├── speclet-draft/SKILL.md
│   ├── speclet-council/SKILL.md
│   ├── speclet-spec/SKILL.md
│   ├── speclet-ticket/SKILL.md
│   └── ralph-loop (built-in command)
├── .speclet/
│   ├── GUIDE.md                  # LLM instructions (permanent)
│   ├── DECISIONS.md              # Architecture decisions (permanent)
│   ├── config.json               # Loop configuration
│   ├── loop.md                   # Manual loop instructions
│   ├── templates/                # Templates for docs
│   ├── tickets/                  # Ticket backlog
│   │   ├── index.json            # Ticket index with status
│   │   ├── TICKET-1/             # Per-ticket folder
│   │   │   ├── ticket.json       # Ticket metadata
│   │   │   ├── ticket-draft.md   # Context from general draft
│   │   │   ├── draft.md          # Refined draft (after speclet-draft)
│   │   │   └── spec.json         # Spec (after speclet-spec)
│   │   └── TICKET-2/
│   │       └── ...
│   └── archive/                  # Completed specs (non-ticket workflow)
└── speclet.ps1                   # PowerShell runner (Windows-only)
```

## Usage

### Using Skills (Recommended)

| Skill | Command | Purpose |
|-------|---------|---------|
| **speclet-draft** | `Use the speclet-draft skill for [feature]` | Generate draft.md with clarifying questions |
| **speclet-council** | `Use the speclet-council skill` | Adversarial review of draft/spec/ticket via plan-reviewer agents |
| **speclet-spec** | `Use the speclet-spec skill` | Convert draft to spec.json |
| **speclet-ticket** | `Use the speclet-ticket skill` | Split draft into individual tickets |
| **/ralph-loop** | `/ralph-loop` | Run continuous implementation loop |
| **speclet-learn** | `Use the speclet-learn skill` | Generate lessons from completed stories |

### Complete Workflow

```
# Step 1: Create draft with clarifying questions
Use the speclet-draft skill for "add user authentication"

# Step 2: Run adversarial council review (Optional but recommended)
Use the speclet-council skill

# Optional: review a spec or ticket directly
Use the speclet-council skill for .speclet/spec.json
Use the speclet-council skill for .speclet/tickets/TICKET-1/draft.md

# Note: speclet-council uses plan-reviewer agents configured in OpenCode.
# If all reviewers map to the same model, the council runs but is not multi-model.
# It can review draft/spec/ticket targets by passing a path.

# Step 3: Convert to executable spec
Use the speclet-spec skill

# Step 4: Run autonomous loop
/ralph-loop (continuous) or .\speclet.ps1
```

### Ticket-Based Workflow (Multiple Issues)

When you have multiple independent issues/features from a single analysis:

```
# Step 1: Create initial draft from analysis
Use the speclet-draft skill for @docs/my-analysis.md

# Step 2: Split into tickets
Use the speclet-ticket skill

# Step 3: Work on tickets one at a time
Use the speclet-draft skill for TICKET-1
Use the speclet-spec skill
.\speclet.ps1

# Step 4: Archive and continue
# (Artifacts auto-saved to .speclet/tickets/TICKET-1/)
Use the speclet-draft skill for TICKET-2
# ... repeat
```

**Key benefit:** Each ticket preserves its own `draft.md` and `spec.json` in `.speclet/tickets/TICKET-N/`, preventing overwrites between sessions.

### Fully Autonomous Mode

Run the entire workflow unattended:

```powershell
# PowerShell (Windows)
.\speclet.ps1

# With max iterations
.\speclet.ps1 -MaxIterations 20
```

The script will:
1. Load config from `.speclet/config.json`
2. Read `spec.json` and switch to the correct branch
3. Run OpenCode with `/ralph-loop` repeatedly
4. **Verify build** after each story (reverts if failed)
5. **Skip blocked stories** after 3 failures
6. **Resume from checkpoint** if interrupted
7. Log everything to `.speclet/loop.log`
8. Offer to archive files and create PR

## Configuration

Create `.speclet/config.json`:

```json
{
  "models": [
    "github-copilot/claude-opus-4.5",
    "google/antigravity-claude-opus-4-5-thinking-medium",
    "openai/gpt-5.2-codex",
    "opencode/glm-4.7-free",
    "opencode/minimax-m2.1-free"
  ],
  "maxRetries": 3,
  "maxStoryFailures": 3,
  "buildCommand": "npm run build",
  "verifyBuild": true,
  "testCommand": "npm test",
  "verifyTests": false,
  "storyTimeoutMinutes": 30,
  "logFile": ".speclet/loop.log"
}
```

| Option | Default | Description |
|--------|---------|-------------|
| `models` | 5 models | Fallback chain (primary → free) |
| `maxRetries` | 3 | Retries per model before fallback |
| `maxStoryFailures` | 3 | Failures before marking story blocked |
| `buildCommand` | `npm run build` | Command to verify build |
| `verifyBuild` | true | Run build after each story |
| `testCommand` | `""` | Command to run tests (optional) |
| `verifyTests` | false | Run tests after build (if testCommand set) |
| `storyTimeoutMinutes` | 30 | Kill story if exceeds this time |
| `logFile` | `.speclet/loop.log` | Log file path |

## Features

### Model Fallback with Retry

If a model fails (rate limit, timeout, etc.):
1. Retry 3 times with exponential backoff (5s → 15s → 45s)
2. Switch to next model in fallback chain
3. Continue until all models exhausted

### Build Verification

After each story:
1. Run `buildCommand` (e.g., `npm run build`)
2. If passes: continue to next story
3. If fails: revert changes, increment failure count

### Test Verification (Optional)

If `verifyTests: true` and `testCommand` configured:
1. Run `testCommand` after successful build
2. If passes: continue to next story
3. If fails: revert changes, increment failure count

### Story Timeout

Prevents stuck stories:
1. Each story has `storyTimeoutMinutes` limit (default: 30)
2. If exceeded: kill the process, count as failure
3. Bash uses `timeout` command, PowerShell uses `WaitForExit`

### Story Completion Verification

After each iteration:
1. Read `spec.json` and check if `passes: true` for current story
2. If not marked complete: count as failure
3. Ensures agent actually completed the work

### Skip Blocked Stories

If a story fails 3 times:
1. Mark as `"blocked": true` in spec.json
2. Skip and continue with next story
3. Report blocked stories at end

### Checkpoint/Resume

If the script crashes or is interrupted:
1. State saved to `.speclet/checkpoint.json`
2. On restart: resume from last story
3. No lost progress

### Session Summary

At end of session (complete, max iterations, or failure):
- Total time elapsed
- Stories completed / blocked
- Build failures / test failures
- Average time per story
- Models used during session

### Logging

All activity logged to `.speclet/loop.log`:
- Model switches
- Build results
- Story completions
- Errors and retries

### GitHub Integration

At completion:
1. Prompts to create PR
2. If not authenticated: prompts for token
3. Uses `gh pr create --fill`

## Workflow Phases

| Phase | Purpose | Artifact |
|-------|---------|----------|
| **0: Bootstrap** | Setup branch, verify build | - |
| **1: Draft** | Clarify requirements | `draft.md` |
| **2: Spec** | Detailed plan with stories | `spec.json` |
| **3: Implementation** | Code + atomic commits | `progress.md` |
| **4: Close** | Document decisions | `DECISIONS.md` |

## Tiers (Complexity Scaling)

| Tier | Time | Documentation | Example |
|------|------|---------------|---------|
| **1** | < 15 min | Commit only | Fix typo, add field |
| **2** | 15-60 min | spec-lite.json | Bug fix, small feature |
| **3** | > 1 hour | Full flow | Multi-story feature |

## spec.json Structure

```json
{
  "feature": "Task Priority System",
  "branch": "feature/task-priority",
  "date": "2024-01-15",
  "summary": "Add priority levels to tasks",
  "nonGoals": ["No priority-based notifications"],
  "functionalRequirements": [
    "FR-1: Add priority field to tasks table",
    "FR-2: Display priority badge on task cards"
  ],
  "stories": [
    {
      "id": "STORY-1",
      "title": "Add priority field to database",
      "description": "Add priority column with default 'medium'",
      "files": ["migrations/001_add_priority.sql"],
      "acceptanceCriteria": [
        "Column created with enum: high, medium, low",
        "Build/typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "blocked": false,
      "notes": ""
    }
  ]
}
```

## Key Concepts

### Lettered Questions

Fast clarification during draft phase:

```
1. What is the primary goal?
   A. Improve user experience
   B. Fix existing bug
   C. Add new functionality

2. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
```

User responds: **"1C, 2A"**

### Story Sizing

**If you cannot describe the change in 2-3 sentences, it's too big. Split it.**

✅ Right-sized:
- Add a database column and migration
- Add a UI component to an existing page

❌ Too big:
- "Build the entire dashboard"
- "Add authentication"

### Non-Goals

Every spec must define what it will NOT do. Critical for preventing scope creep.

## Golden Rules

### ✅ DO
- Atomic commits (1 story = 1 commit)
- Build before push
- Push immediately
- Update `passes: true` after each story
- Document architectural decisions

### ❌ DON'T
- Commit `.speclet/` files
- Refactor while fixing bugs
- Implement without confirming understanding
- Ignore build errors
- Use vague acceptance criteria

## Success Metrics

| Metric | Target |
|--------|--------|
| Broken builds | 0 |
| Reverts | 0 |
| Commits/hour | 3-4 |
| Questions/story | ≤2 |


## Philosophy

Speclet is inspired by:
- **Spec-Driven Development**: Specification before code
- **BDD**: Acceptance criteria, Gherkin-style scenarios
- **ADR**: Architecture Decision Records
- **[Ralph](https://ghuntley.com/ralph/)**: Story sizing, JSON tracking

The key insight: **LLMs work better with structured context**. Speclet provides that structure while staying lightweight.

## License

MIT
