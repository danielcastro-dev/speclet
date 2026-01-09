# Speclet Autonomous Loop

You are an autonomous coding agent working on a software project using the Speclet workflow.

## Your Task

1. Read the spec at `.speclet/spec.json`
2. Read the progress log at `.speclet/progress.md` (check Codebase Patterns section first)
3. Check you're on the correct branch from spec `branch`. If not, check it out or create from main/master.
4. Pick the **highest priority** story where `passes: false`
5. Implement that single story
6. Run quality checks (see Quality Requirements below)
7. Update AGENTS.md files if you discover reusable patterns (see below)
8. If checks pass, commit ALL changes with message: `feat([scope]): [Story ID] - [Story Title]`
9. Update `.speclet/spec.json` to set `passes: true` for the completed story
10. Append your progress to `.speclet/progress.md`

## Progress Report Format

APPEND to `.speclet/progress.md` (never replace, always append):

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

The learnings section is critical - it helps future iterations avoid repeating mistakes and understand the codebase better.

## Consolidate Patterns

If you discover a **reusable pattern** that future iterations should know, add it to the `## Codebase Patterns` section at the TOP of progress.md (create it if it doesn't exist). This section should consolidate the most important learnings:

```markdown
## Codebase Patterns

- Use X pattern for Y
- Always check Z before doing W
- Export types from module A for use in B
```

Only add patterns that are **general and reusable**, not story-specific details.

## Update AGENTS.md Files

Before committing, check if any edited files have learnings worth preserving in nearby AGENTS.md files:

1. **Identify directories with edited files** - Look at which directories you modified
2. **Check for existing AGENTS.md** - Look for AGENTS.md in those directories or parent directories
3. **Add valuable learnings** - If you discovered something future developers/agents should know:
   - API patterns or conventions specific to that module
   - Gotchas or non-obvious requirements
   - Dependencies between files
   - Testing approaches for that area
   - Configuration or environment requirements

**Examples of good AGENTS.md additions:**
- "When modifying X, also update Y to keep them in sync"
- "This module uses pattern Z for all API calls"
- "Tests require the dev server running on PORT 3000"
- "Field names must match the template exactly"

**Do NOT add:**
- Story-specific implementation details
- Temporary debugging notes
- Information already in progress.md

Only update AGENTS.md if you have **genuinely reusable knowledge** that would help future work in that directory.

## Quality Requirements

Before committing, verify:

1. **Build passes** - Run your project's build command
2. **Type check passes** - No TypeScript/type errors
3. **Lint passes** - No linting errors (if applicable)
4. **Tests pass** - Run relevant tests (if applicable)

### Browser Testing (Required for Frontend Stories)
For any story that changes UI:
1. Verify the UI changes work as expected in the browser
2. Take a screenshot if helpful for the progress log

A frontend story is NOT complete until browser verification passes.

## Commit Rules

- ALL commits must pass quality checks
- Do NOT commit broken code
- Keep changes focused and minimal
- Follow existing code patterns
- One story = one commit
- Push immediately after commit

## Stop Condition

After completing a story, check if ALL stories have `passes: true` in `.speclet/spec.json`.

**If ALL stories are complete:**
```
✅ COMPLETE - All stories passing. Ready for PR.
```

**If stories remain:**
End your response normally. Another iteration will pick up the next story.

## Important Reminders

- Work on ONE story per iteration
- Read Codebase Patterns in progress.md before starting
- Update `passes: true` AFTER successful commit
- Never suppress type errors with `as any` or `@ts-ignore`
- Fix root causes, not symptoms

---

## How to Use This Loop

### Manual Iteration
Tell your LLM:
```
Read .speclet/loop.md and execute one iteration.
```

### Continuous Loop
Keep sending the same prompt until you see `✅ COMPLETE`.

### Starting Fresh
1. Create `.speclet/spec.json` from template (Phase 2 of GUIDE.md)
2. Create empty `.speclet/progress.md`
3. Start loop
