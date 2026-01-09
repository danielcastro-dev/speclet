# Speclet vs Ralph Wiggum: Compliance Checklist

Based on [AIhero's 11 Tips for AI Coding with Ralph Wiggum](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)

## Summary

| Category | Ralph Tips | Speclet Status |
|----------|------------|----------------|
| Verified ✅ | 11/11 | Fully Compliant |
| Partial ⚠️ | 0/11 | - |
| Missing ❌ | 0/11 | - |

---

## Tip 1: Use a Markdown PRD ✅

> "Start with a Markdown PRD that describes the feature"

**Ralph:** Uses `prd.md` in Markdown format.

**Speclet:** Uses `draft.md` (Markdown) → `spec.json` (JSON)

**Status:** ✅ **COMPLIANT** - Speclet uses hybrid approach:
- `draft.md` for human collaboration (Markdown)
- `spec.json` for execution tracking (JSON with `passes: true/false`)

**Advantage Speclet:** JSON enables programmatic tracking of story completion.

---

## Tip 2: Break Down into Atomic Stories ✅

> "Break down the PRD into small, atomic stories"

**Ralph:** Stories should be ~10-30 minutes each.

**Speclet:** 
- GUIDE.md: "If you cannot describe the change in 2-3 sentences, it's too big. Split it."
- Story sizing examples provided
- Target: 3-4 commits/hour

**Status:** ✅ **COMPLIANT**

**Location:** `GUIDE.md` lines 160-173, `skills/speclet-spec/SKILL.md` lines 77-88

---

## Tip 3: One Story = One Commit ✅

> "Each story should result in exactly one commit"

**Ralph:** Atomic commits per story.

**Speclet:**
- GUIDE.md: "Atomic commits - 1 story = 1 commit"
- speclet-loop: "ONE story per iteration", "Commit frequently - One story = one commit"

**Status:** ✅ **COMPLIANT**

**Location:** `GUIDE.md` line 433, `skills/speclet-loop/SKILL.md` lines 154-155

---

## Tip 4: Stories Have Verifiable Acceptance Criteria ✅

> "Each story should have acceptance criteria that can be verified"

**Ralph:** Criteria must be checkable, not vague.

**Speclet:**
- "Each criterion must be something that can be CHECKED, not something vague"
- ✅ Good: "Filter dropdown has options: All, Active, Completed"
- ❌ Bad: "Works correctly", "Good UX"
- Always includes: "Build/typecheck passes"

**Status:** ✅ **COMPLIANT**

**Location:** `GUIDE.md` lines 185-203, `skills/speclet-spec/SKILL.md` lines 97-109

---

## Tip 5: Keep Context in Progress File ✅

> "Keep a progress file that documents learnings during implementation"

**Ralph:** `progress.md` accumulates learnings.

**Speclet:**
- `progress.md` with template
- `## Codebase Patterns` section for reusable patterns
- speclet-loop updates progress after each story

**Status:** ✅ **COMPLIANT**

**Location:** `GUIDE.md` lines 409-426, `skills/speclet-loop/SKILL.md` lines 105-122

---

## Tip 6: Maintain DECISIONS.md ✅

> "Document architectural decisions that affect future code"

**Ralph:** Uses ADR-style decisions file.

**Speclet:**
- `DECISIONS.md` is permanent (not archived)
- Clear criteria: "Does it go in DECISIONS.md?"
- Template with: Decision, Context, Alternatives, Applies to

**Status:** ✅ **COMPLIANT**

**Location:** `GUIDE.md` lines 236-265, 492-510

---

## Tip 7: Dependency Order in Stories ✅

> "Order stories by dependencies - schema first, UI last"

**Ralph:** Backend before frontend.

**Speclet:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views

**Status:** ✅ **COMPLIANT**

**Location:** `GUIDE.md` lines 175-183, `skills/speclet-spec/SKILL.md` lines 90-95

---

## Tip 8: Build Before Commit ✅

> "Always verify the build passes before committing"

**Ralph:** CI must stay green.

**Speclet:**
- speclet-loop: "npm run build" before commit
- "Run `lsp_diagnostics` on modified files - must be clean"
- "Keep CI green - Never commit broken code"

**Status:** ✅ **COMPLIANT**

**Location:** `skills/speclet-loop/SKILL.md` lines 71-81, 156

---

## Tip 9: Push Immediately After Commit ✅

> "Push immediately after each commit - don't accumulate"

**Ralph:** Prevents merge conflicts and lost work.

**Speclet:**
- GUIDE.md: "Push immediately - Don't accumulate changes"
- speclet-loop: `git push origin [branch]` after each commit

**Status:** ✅ **COMPLIANT**

**Location:** `GUIDE.md` line 436, `skills/speclet-loop/SKILL.md` line 90

---

## Tip 10: Track Story Completion Status ✅

> "Track which stories are done vs pending"

**Ralph:** Uses status markers in PRD.

**Speclet:**
- JSON format with `"passes": true/false` per story
- speclet-loop updates after each commit
- speclet.sh reads JSON to determine next story

**Status:** ✅ **COMPLIANT** - Better than Ralph

**Advantage Speclet:** JSON enables:
- `jq` queries for automation
- PowerShell `ConvertFrom-Json` parsing
- Programmatic loop control

**Location:** `spec.json` schema, `skills/speclet-loop/SKILL.md` lines 93-103

---

## Tip 11: Autonomous Loop Mode ✅

> "Agent picks next story and implements autonomously until complete"

**Ralph:** `ralph.sh` runs until all stories pass.

**Speclet:**
- `speclet.sh` (Bash) and `speclet.ps1` (PowerShell)
- Model fallback with retry and exponential backoff
- Build verification with automatic revert on failure
- Test verification (optional, configurable)
- Story timeout to prevent stuck iterations
- Skip blocked stories after N failures
- Checkpoint/resume capability
- Session summary with metrics
- Archive + PR creation at end

**Status:** ✅ **COMPLIANT** - Exceeds Ralph

| Feature | Ralph | Speclet |
|---------|-------|---------|
| Basic loop | ✅ | ✅ |
| Model fallback | ❌ | ✅ |
| Cross-platform | ❌ | ✅ (Bash + PowerShell) |
| Build verification | ✅ | ✅ |
| Test verification | ❌ | ✅ (optional) |
| Skip stuck story | ✅ | ✅ |
| Resume after crash | ✅ | ✅ |
| Story timeout | ❌ | ✅ |
| Session summary | ❌ | ✅ |
| Story completion check | ❌ | ✅ |

**Location:** `speclet.sh`, `speclet.ps1`, `.speclet/config.json`

---

## Extra: Non-Goals Section ✅

> Not in Ralph tips, but important

**Speclet adds:**
- `nonGoals` field in spec.json (mandatory)
- Prevents scope creep
- Clear boundaries for what feature will NOT do

**Status:** ✅ **SPECLET ADVANTAGE**

---

## Extra: Lettered Questions ✅

> Not in Ralph tips, but improves UX

**Speclet adds:**
- Questions with lettered options (A, B, C, D)
- User responds "1C, 2A" for speed
- Reduces back-and-forth

**Status:** ✅ **SPECLET ADVANTAGE**

---

## Extra: Tiered Complexity ✅

> Not in Ralph tips, but improves efficiency

**Speclet adds:**
- Tier 1 (<15 min): Commit only
- Tier 2 (15-60 min): spec-lite.json
- Tier 3 (>1 hour): Full draft + spec flow

**Status:** ✅ **SPECLET ADVANTAGE**

---

## Implementation Status

All recommended features have been implemented:

### ✅ Completed

1. **Build verification in loop script** - Runs after each story, reverts on failure
2. **Test verification (optional)** - `testCommand` and `verifyTests` config options
3. **Skip story after failures** - Marks as `blocked` after `maxStoryFailures` attempts
4. **Checkpoint/Resume** - State saved to `.speclet/checkpoint.json`
5. **Config file** - `.speclet/config.json` for models, retries, build command
6. **Log file** - `.speclet/loop.log` for debugging
7. **Story timeout** - `storyTimeoutMinutes` kills stuck stories
8. **Session summary** - Metrics at end (time, completions, failures, models used)
9. **Story completion check** - Verifies `passes: true` after each iteration

### ⏳ Not Planned

- **Notification (beep/toast)** - Out of scope
- **Dry-run mode** - Out of scope  
- **Time estimation** - Out of scope

---

## Conclusion

Speclet is **100% compliant** with Ralph Wiggum principles and adds several improvements:
- JSON tracking (programmatic)
- Non-Goals (scope control)
- Lettered questions (faster UX)
- Tiered complexity (efficiency)
- Model fallback with retry (resilience)
- Cross-platform (Bash + PowerShell)
- Build + test verification (safety)
- Story timeout (prevents stuck loops)
- Session summary (observability)
- Story completion verification (correctness)
