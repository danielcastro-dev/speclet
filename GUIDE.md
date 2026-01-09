# Speclet: LLM Session Instructions

**How to use:** Copy this file to `.speclet/` and tell your LLM:

> "Read `.speclet/GUIDE.md` and let's start with Phase 0"

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
   ├── spec.md          ← Create in Phase 2 (moves to archive)
   └── progress.md      ← Create in Phase 3 (moves to archive)
   ```

5. **Ask the user:**
   > "What do you want to work on today? Describe the feature/fix/refactor in 1-2 sentences."

6. **Decide Tier (based on response):**

   | Tier | Estimated time | Documentation | Example |
   |------|----------------|---------------|---------|
   | **Tier 1** | < 15 min | Descriptive commit only | Fix typo, add field |
   | **Tier 2** | 15-60 min | Spec Lite (no draft) | Bug fix, small feature |
   | **Tier 3** | > 1 hour | Draft + Spec + Progress | Multi-story feature |

   > Ask: "Does this look like Tier 1, 2, or 3?" and adjust flow.
   > - **Tier 1:** Skip to direct implementation
   > - **Tier 2:** Create Spec Lite, then implement
   > - **Tier 3:** Follow complete flow (Phase 1 → 2 → 3)

---

### Phase 1: Collaborative Draft

**Goal:** Understand the problem BEFORE writing code.

1. Create `.speclet/draft.md` with the template below
2. Ask clarifying questions (max 3 rounds)
3. Document answers in the draft table
4. Identify affected files
5. Estimate complexity

**When user confirms:** Move to Phase 2.

---

### Phase 2: Spec (Execution Plan)

**Goal:** Detailed plan ready to implement.

1. Convert draft into `.speclet/spec.md`
2. Divide into atomic stories (1 story = 1 commit)
3. Define "Done" criteria per story
4. Verify with user: "Shall we start?"

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
6. Mark story completed
7. Next story
```

**When all stories are done:**

1. **Update DECISIONS.md** (see criteria below)
2. Move `draft.md`, `spec.md`, `progress.md` → `.speclet/archive/YYYY-MM-DD-name-*.md`
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
> If ALL stories pass: "✅ All stories completed. Shall we create PR?"

---

## Templates

### Template: Spec Lite (Tier 2)

```markdown
# [TICKET-ID]: [Title]

**Date:** YYYY-MM-DD | **Branch:** feature/x | **Actual time:** ~XX min

---

## Problem
[1-2 sentences of the bug or need]

## Solution
[Description or code]

## Files
- `path/file.ts` - [change]

## Done
- [x] Build passes
- [x] [Specific criterion]
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

## Questions and Answers

| #   | Question | Answer |
| --- | -------- | ------ |
| 1   |          |        |
| 2   |          |        |
| 3   |          |        |

---

## Proposed Scope

### Included

-

### Excluded (out of scope)

-

---

## Files to Modify

| File | Changes | Complexity |
| ---- | ------- | ---------- |
|      |         | 🟢/🟡/🔴   |

---

## Stories (Draft)

1. **STORY-1:**
2. **STORY-2:**
3. **STORY-3:**

---

## Pending Questions

1.
```

### Template: spec.md

```markdown
# Spec: [Feature Name]

**Date:** YYYY-MM-DD  
**Branch:** feature/branch-name  
**Estimate:** X commits, ~Y LOC

---

## Summary

[1-2 sentences of the goal]

---

## Stories

### STORY-1: [Title]

**File(s):** `path/to/file.ts`

**Changes:**

-

**Done Criteria:**

- [ ] Build passes
- [ ] lsp_diagnostics clean
- [ ] [Specific criterion]

---

### STORY-2: [Title]

...

---

## Final Verification

- [ ] All stories completed
- [ ] Build without errors
- [ ] Functionality manually tested
- [ ] Clean commit history (1 commit = 1 story)

---

## References

- Key files:
- Documentation:
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
4. **Ask if in doubt** - Max 3 questions per round
5. **Respect UX decisions** - Don't question visual preferences
6. **Document decisions** - In draft.md or comments

### ❌ DON'T

1. **Don't commit planning files** - `.speclet/` is in gitignore
2. **No vague commits** - "docs update" ❌ → "docs(module): add field specs" ✅
3. **Don't refactor while fixing** - Minimal fix, separate refactor
4. **Don't ignore build errors** - Fix before continuing
5. **Don't implement without confirming** - Always verify understanding

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
