# Speclet Loop Skill

Execute one autonomous iteration of the Speclet workflow.

## Usage

```
Load the loop skill and execute one iteration
```

Keep sending this until you see `✅ COMPLETE`.

## Your Task

1. Read `.speclet/spec.json`
2. Read `.speclet/progress.md` (check Codebase Patterns first)
3. Verify you're on the correct branch
4. Pick the **highest priority** story where `passes: false`
5. Implement that single story
6. Run quality checks
7. Commit if checks pass
8. Update spec.json: set `passes: true`
9. Append to progress.md

## Step 1: Read Context

```
Read .speclet/spec.json
Read .speclet/progress.md (if exists)
```

Check the `## Codebase Patterns` section first - it contains learnings from previous iterations.

## Step 2: Verify Branch

Check you're on the correct branch from spec `branch` field.

```bash
git branch
git status
```

If not on correct branch:
- If branch exists: `git checkout [branch]`
- If not: `git checkout -b [branch]`

## Step 3: Pick Next Story

Find the story with:
- `passes: false`
- Lowest `priority` number (1 = highest priority)

If ALL stories have `passes: true`, skip to Stop Condition.

## Step 4: Implement Story

Implement the single story. Follow:
- Existing code patterns
- Acceptance criteria exactly
- Minimal changes (no scope creep)

## Step 5: Quality Checks

Before committing, verify:

### Build
```bash
npm run build  # or your project's build command
```

### Type Check
Run `lsp_diagnostics` on all modified files - must be clean.

### Browser (for UI stories)
If acceptance criteria includes "Verify in browser":
- Navigate to relevant page
- Confirm changes work as expected
- Take screenshot if helpful

## Step 6: Commit

If all checks pass:

```bash
git add -A
git commit -m "feat([scope]): [STORY-ID] - [Story Title]"
git push origin [branch]
```

## Step 7: Update spec.json

Update the completed story:

```json
{
  "id": "STORY-X",
  "passes": true,
  "notes": "[Any learnings or context]"
}
```

## Step 8: Update progress.md

APPEND to `.speclet/progress.md` (never replace):

```markdown
---

## YYYY-MM-DD HH:MM - [STORY-ID]: [Title]

- **Implemented:** [What was done]
- **Files changed:** 
  - `path/to/file.ts` - [what changed]
- **Learnings for future iterations:**
  - [Patterns discovered]
  - [Gotchas encountered]
  - [Useful context]
```

### Consolidate Patterns

If you discovered a **reusable pattern**, add it to the `## Codebase Patterns` section at TOP of progress.md:

```markdown
## Codebase Patterns

- Use X pattern for Y
- Always check Z before doing W
- This codebase uses A for B
```

Only add patterns that are **general and reusable**, not story-specific.

## Step 9: Update AGENTS.md (if applicable)

If you discovered learnings worth preserving:

1. Find AGENTS.md in edited directories
2. Add valuable, reusable knowledge
3. Include in commit

Good additions:
- "When modifying X, also update Y"
- "This module uses pattern Z"
- "Tests require server running on PORT 3000"

Do NOT add:
- Story-specific details
- Temporary notes
- Info already in progress.md

## Stop Condition

After completing the story, check spec.json.

**If ALL stories have `passes: true`:**

```
✅ COMPLETE - All stories passing.

Summary:
- Feature: [name]
- Branch: [branch]
- Stories completed: [N]

Ready to create PR.
```

**If stories remain with `passes: false`:**

End your response normally. Another iteration will pick up the next story.

## Error Recovery

### Build fails
1. Fix the issue
2. Re-run build
3. Only commit when passing

### Test fails
1. Fix the test or code
2. Re-run tests
3. Only commit when passing

### After 3 failed attempts
1. Stop
2. Document what was tried in progress.md
3. Ask user for help

## Rules

- **ONE story per iteration** - Never implement multiple
- **Commit frequently** - One story = one commit
- **Keep CI green** - Never commit broken code
- **Read patterns first** - Check progress.md before starting
- **Update passes AFTER commit** - Not before
- **No type suppression** - Never use `as any` or `@ts-ignore`
