# Speclet: LLM Session Instructions

**How to use:** Tell your LLM:

> "Read `.speclet/GUIDE.md` and let's start with Phase 0"

**Using Skills (recommended for OpenCode):**

| Skill | Command | Purpose |
|-------|---------|---------|
| `speclet-draft` | "Use the speclet-draft skill for [feature]" | Generate draft.md with clarifying questions |
| `speclet-spec` | "Use the speclet-spec skill" | Convert draft to spec.json |
| `speclet-loop` | "Use the speclet-loop skill" | Implement one story autonomously |

**Manual loop:** Once you have a `spec.json`:

> "Read `.speclet/loop.md` and execute one iteration."

---

## For the LLM: Workflow

### Phase 0: Bootstrap (NOW)

1. **Pre-flight checklist:**

   ```bash
   git status             # Check current state
   git stash              # If there are uncommitted changes
   git branch             # Confirm current branch
   ```

2. **Verify/create working branch:**

   | Current state  | Action                                       |
   | -------------- | -------------------------------------------- |
   | On `main`      | `git pull && git checkout -b feature/name`   |
   | On `feature/*` | Continue there (don't create new)            |

   > **Rule:** All commits in this session go to current branch. Don't create additional branches.

3. **Verify clean build (first iteration of the day only):**

   ```bash
   npm run build  # or your project's build command
   ```

4. **Create working structure:**

   ```
   .speclet/
   ├── GUIDE.md         ← This file (already exists)
   ├── DECISIONS.md     ← Permanent (create if doesn't exist)
   ├── draft.md         ← Create in Phase 1 (moves to archive)
   ├── spec.json        ← Create in Phase 2 (moves to archive)
   └── progress.md      ← Create in Phase 3 (moves to archive)
   ```

5. **Ask the user:**
   > "What do you want to work on today? Describe the feature/fix/refactor in 1-2 sentences."

6. **Decide Tier (based on response):**

   | Tier | Estimated time | Documentation | Example |
   |------|----------------|---------------|---------|
   | **Tier 1** | < 15 min | Descriptive commit only | Fix typo, add field |
   | **Tier 2** | 15-60 min | spec-lite.json (no draft) | Bug fix, small feature |
   | **Tier 3** | > 1 hour | Draft + spec.json + Progress | Multi-story feature |

   > Ask: "Does this look like Tier 1, 2, or 3?" and adjust flow.
   > - **Tier 1:** Skip to direct implementation
   > - **Tier 2:** Create spec-lite.json, then implement
   > - **Tier 3:** Follow complete flow (Phase 1 → 2 → 3)

---

### Phase 1: Collaborative Draft

**Goal:** Understand the problem BEFORE writing code.

1. Create `.speclet/draft.md` with the template below
2. **Ask 3-5 clarifying questions with lettered options** (see format below)
3. Document answers in the draft
4. Identify affected files
5. Estimate complexity

#### Clarifying Questions Format

Ask only critical questions where the initial prompt is ambiguous. Use lettered options for quick responses:

```
1. What is the primary goal of this feature?
   A. Improve user experience
   B. Fix existing bug
   C. Add new functionality
   D. Refactor/cleanup
   E. Other: [please specify]

2. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
   C. Just the backend/API
   D. Just the UI
```

**User can respond:** "1C, 2A" for quick iteration.

**Focus questions on:**
- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How do we know it's done?

**When user confirms:** Move to Phase 2.

---

### Phase 2: Spec (Execution Plan)

**Goal:** Detailed plan ready to implement in JSON format.

1. Convert draft into `.speclet/spec.json`
2. Divide into atomic stories (1 story = 1 commit)
3. Define acceptance criteria per story
4. Verify with user: "Shall we start?"

#### spec.json Structure

```json
{
  "feature": "Feature Name",
  "branch": "feature/branch-name",
  "date": "YYYY-MM-DD",
  "summary": "1-2 sentences of the goal",
  "nonGoals": [
    "What this feature will NOT do"
  ],
  "functionalRequirements": [
    "FR-1: The system must...",
    "FR-2: When user does X..."
  ],
  "stories": [
    {
      "id": "STORY-1",
      "title": "Short title",
      "description": "2-3 sentences max",
      "files": ["path/to/file.ts"],
      "acceptanceCriteria": [
        "Specific verifiable criterion",
        "Build/typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

#### Story Sizing Rule (CRITICAL)

**If you cannot describe the change in 2-3 sentences, it's too big. Split it.**

✅ **Right-sized stories:**
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

❌ **Too big (split these):**
- "Build the entire dashboard" → Split into: schema, queries, UI components, filters
- "Add authentication" → Split into: schema, middleware, login UI, session handling
- "Refactor the API" → Split into one story per endpoint or pattern

#### Story Order: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

**Correct order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

#### Acceptance Criteria: Must Be Verifiable

Each criterion must be something that can be CHECKED, not something vague.

✅ **Good criteria (verifiable):**
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Clicking delete shows confirmation dialog"
- "Typecheck passes"

❌ **Bad criteria (vague):**
- "Works correctly"
- "User can do X easily"
- "Good UX"
- "Handles edge cases"

**Always include as final criteria:**
- `Build/typecheck passes` (always)
- `Verify in browser` (if UI changes)

**When approved:** Move to Phase 3.

---

### Phase 3: Implementation

**Workflow per story:**

```
1. Mark story in_progress (todo list)
2. Implement atomic change
3. Verify:
   - npm run build (frontend)
   - lsp_diagnostics
4. Commit: feat(scope): brief description
5. Push immediately
6. Update spec.json: set "passes": true for completed story
7. Mark story completed in todo list
8. Next story
```

**When all stories are done:**

1. **Update DECISIONS.md** (see criteria below)
2. Move `draft.md`, `spec.json`, `progress.md` → `.speclet/archive/YYYY-MM-DD-name/`
3. Create PR if applicable (complete branch)

> **Note:** `DECISIONS.md` and `GUIDE.md` are NOT moved. They're permanent.

---

### Phase 4: Update DECISIONS.md

**Ask user before closing:**
> "Were there any architectural decisions we should document in DECISIONS.md?"

**Criteria - Does it go in DECISIONS.md?**

| ✅ YES add | ❌ NO add |
|------------|-----------|
| Decision that affects future code | One-off fix that doesn't set precedent |
| Pattern that should be repeated | Implementation detail |
| Trade-off with discarded alternatives | Bug that was fixed |
| Configuration/threshold chosen | UI/text change |

**Examples:**
- ✅ "Use Fuse.js threshold 0.4" → affects future searches
- ✅ "Separate brand/model" → pattern for new types
- ❌ "Added field X to form" → it's implementation, not decision
- ❌ "Fixed typo in label" → trivial fix

**If there's a new decision, use this format:**

```markdown
## YYYY-MM-DD: [Short title]

- **Decision:** [What was decided]
- **Context:** [Why - the problem it solves]
- **Alternatives discarded:** [What other options existed]
- **Applies to:** [When to use this pattern in the future]
```

**Stop Condition:**
> If ALL stories have `"passes": true`: "✅ All stories completed. Shall we create PR?"

---

## Templates

### Template: spec-lite.json (Tier 2)

```json
{
  "feature": "Title",
  "branch": "feature/x",
  "date": "YYYY-MM-DD",
  "actualTime": "~XX min",
  "problem": "1-2 sentences of the bug or need",
  "solution": "Description of the fix",
  "files": ["path/file.ts"],
  "acceptanceCriteria": [
    "Build passes",
    "Specific verifiable criterion"
  ],
  "passes": false,
  "notes": ""
}
```

### Template: draft.md

```markdown
# Draft: [Feature Name]

**Status:** In definition  
**Date:** YYYY-MM-DD  
**Branch:** feature/branch-name

---

## User Description

> [Paste what the user said here]

---

## Clarifying Questions

1. [Question with options]
   A. Option A
   B. Option B
   C. Option C
   D. Other: ___

   **Answer:** [User's choice]

2. [Next question]
   A. ...

   **Answer:** 

---

## Proposed Scope

### Included

-

### Non-Goals (Out of Scope)

- [What this feature will NOT include - critical for managing scope]

---

## Files to Modify

| File | Changes | Complexity |
| ---- | ------- | ---------- |
|      |         | 🟢/🟡/🔴   |

---

## Stories (Draft)

1. **STORY-1:** [2-3 sentence description max]
2. **STORY-2:** [2-3 sentence description max]
3. **STORY-3:** [2-3 sentence description max]

---

## Pending Questions

1.
```

### Template: spec.json

```json
{
  "feature": "[Feature Name]",
  "branch": "feature/branch-name",
  "date": "YYYY-MM-DD",
  "summary": "[1-2 sentences of the goal]",
  "nonGoals": [
    "[What this feature will NOT do]",
    "[Critical for preventing scope creep]"
  ],
  "functionalRequirements": [
    "FR-1: The system must [specific requirement]",
    "FR-2: When user does X, the system must [response]"
  ],
  "stories": [
    {
      "id": "STORY-1",
      "title": "[Title]",
      "description": "[2-3 sentences max]",
      "files": ["path/to/file.ts"],
      "acceptanceCriteria": [
        "[Specific verifiable criterion]",
        "Build/typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "STORY-2",
      "title": "[Title]",
      "description": "[Description]",
      "files": ["path/to/file.ts"],
      "acceptanceCriteria": [
        "[Criterion]",
        "Build/typecheck passes",
        "Verify in browser"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### Template: progress.md

```markdown
## Codebase Patterns

[Reusable patterns discovered during the session]

---

## YYYY-MM-DD - STORY-1 (~XX min actual)

- Implemented:
- Files:
- Learnings:
  -

---
```

---

## Golden Rules (What Worked)

### ✅ DO

1. **Atomic commits** - 1 story = 1 commit
2. **Build before push** - Always `npm run build`
3. **Push immediately** - Don't accumulate changes
4. **Ask if in doubt** - Max 3-5 questions with lettered options
5. **Respect UX decisions** - Don't question visual preferences
6. **Document decisions** - In draft.md or comments
7. **Size stories correctly** - 2-3 sentences max per story
8. **Update spec.json** - Set `"passes": true` after each story

### ❌ DON'T

1. **Don't commit planning files** - `.speclet/` is in gitignore
2. **No vague commits** - "docs update" ❌ → "docs(module): add field specs" ✅
3. **Don't refactor while fixing** - Minimal fix, separate refactor
4. **Don't ignore build errors** - Fix before continuing
5. **Don't implement without confirming** - Always verify understanding
6. **No vague acceptance criteria** - "Works correctly" ❌ → "Shows confirmation dialog" ✅

---

## Simplified Flow (Minor Fixes)

For small fixes (<15 min, <30 LOC, single file):

| Step | Action |
|------|--------|
| 1 | Implement fix directly |
| 2 | `npm run build` / verify |
| 3 | Commit with prefix `fix(scope): description` |
| 4 | Retroactive documentation in `archive/` (optional but recommended) |

**Criteria for simplified flow:**
- Change < 30 LOC
- Single file affected
- No architecture decisions required
- Estimated time < 15 minutes

**Always use complete flow (Draft → Spec) for:**
- New features
- Changes in multiple files
- Decisions that affect architecture
- Anything requiring clarifying questions

---

## Success Metrics

A good session has:

| Metric          | Target |
| --------------- | ------ |
| Broken builds   | 0      |
| Reverts         | 0      |
| Commits/hour    | 3-4    |
| Questions/story | ≤2     |

---

## Template: DECISIONS.md (Permanent)

```markdown
# Architecture Decisions

> Permanent file. Do NOT move to archive.

---

## YYYY-MM-DD: [Decision title]

- **Decision:** [What was decided]
- **Context:** [Why this decision was made]
- **Alternatives discarded:** [What other options were considered]
- **Consequences:** [What this decision implies]
- **Applies to:** [Where/when to use this pattern]

---
```

---

## Start Command

Tell the LLM:

```
Read .speclet/GUIDE.md

Context: [describe your problem in 1-2 sentences]

Let's start with Phase 0.
```
