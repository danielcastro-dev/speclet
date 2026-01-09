---
name: speclet-loop
description: Execute one autonomous iteration - implement the next story from spec.json
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  phase: implementation
---

# Speclet Loop Skill

Execute one autonomous iteration of the Speclet workflow.

## What I Do

- Pick the highest priority story where `passes: false`
- Implement that single story
- Run quality checks
- Commit if checks pass
- Update spec.json with `passes: true`
- Append learnings to progress.md

## When to Use Me

Use this repeatedly until all stories are complete:

```
Use the speclet-loop skill
```

Keep using until you see `✅ COMPLETE`.

## Your Task

### Step 1: Read Context

```
Read .speclet/spec.json
Read .speclet/progress.md (if exists)
```

Check the `## Codebase Patterns` section first.

### Step 2: Verify Branch

Check you're on the correct branch from spec `branch` field.

```bash
git branch
git status
```

If not on correct branch, checkout or create it.

### Step 3: Pick Next Story

Find the story with:
- `passes: false`
- Lowest `priority` number

If ALL stories have `passes: true`, skip to Stop Condition.

### Step 4: Implement Story

Implement the single story:
- Follow existing code patterns
- Meet acceptance criteria exactly
- Minimal changes (no scope creep)

### Step 5: Quality Checks

Before committing:

```bash
npm run build  # or your project's build command
```

Run `lsp_diagnostics` on modified files - must be clean.

For UI stories: verify in browser.

### Step 6: Commit

If checks pass:

```bash
git add -A
git commit -m "feat([scope]): [STORY-ID] - [Story Title]"
git push origin [branch]
```

### Step 7: Update spec.json

Update the completed story:

```json
{
  "id": "STORY-X",
  "passes": true,
  "notes": "[Any learnings]"
}
```

### Step 8: Update progress.md

APPEND to `.speclet/progress.md`:

```markdown
---

## YYYY-MM-DD HH:MM - [STORY-ID]: [Title]

- **Implemented:** [What was done]
- **Files changed:** 
  - `path/to/file.ts` - [what changed]
- **Learnings:**
  - [Patterns discovered]
  - [Gotchas encountered]
```

If you discovered a **reusable pattern**, add it to `## Codebase Patterns` at TOP of progress.md.

### Step 9: Update AGENTS.md (if applicable)

Add valuable, reusable knowledge to AGENTS.md in edited directories.

## Stop Condition

**If ALL stories have `passes: true`:**

```
✅ COMPLETE - All stories passing.

Summary:
- Feature: [name]
- Branch: [branch]
- Stories completed: [N]

Ready to create PR.
```

**If stories remain:** End response normally. Use this skill again for next story.

## Error Recovery

### After 3 failed attempts
1. Stop
2. Document what was tried
3. Ask user for help

## Rules

- **ONE story per iteration**
- **Commit frequently** - One story = one commit
- **Keep CI green** - Never commit broken code
- **Update passes AFTER commit**
- **No type suppression** - Never use `as any` or `@ts-ignore`

## Global Rules

### Always Show Recommendation + Reason

When asking questions with options, ALWAYS:
1. Mark the recommended option with ⭐
2. Add `**Reason for recommendation:**` explaining why

**Example format:**
```
1. [Question]?
   A. Option A
   B. Option B ⭐ Recommended — [brief reason]
   C. Option C

   **Reason for recommendation:** [Detailed explanation of why B is best]
```
