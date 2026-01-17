---
name: speclet-consolidate
description: Merge accepted council feedback into draft.md and keep review artifacts separate
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Consolidate Skill

Merge accepted Council feedback into a spec-ready `draft.md` without copying the full Council Review content.

## What I Do

- Read `.speclet/draft.md` and `.speclet/council-summary.md`
- Apply **Accepted** council decisions into the base draft
- Support explicit overrides for accept/reject/defer decisions and story removal
- Update `.speclet/council-summary.md` with final status
- Keep review artifacts separate (never append to `draft.md`)

## When to Use Me

Use this after running `speclet-council` and before `speclet-spec`:

```
Use the speclet-consolidate skill
```

## Inputs

- `.speclet/draft.md` (required unless `--target-draft` or `activeTicket` is used)
- `.speclet/council-summary.md` (required)
- `.speclet/council-session.md` (optional)
- Overrides (optional): `--accept`, `--reject`, `--defer`, `--exclude-story`, `--target-draft`

## Overrides

Supported overrides:
- `--accept C2,C4`
- `--reject C3`
- `--defer C5`
- `--exclude-story STORY-3`
- `--target-draft path/to/draft.md`

If overrides conflict with `council-summary.md`, overrides win.

### Ticket Workflow Notes

- When `activeTicket` is set, consolidation should target `.speclet/tickets/<activeTicket>/draft.md` by default.
- Use `--target-draft` to override the ticket path explicitly when needed.

## Your Task

### Step 1: Validate Inputs

- Ensure `council-summary.md` exists
- Resolve the draft path in this order:
  1. If `--target-draft` is provided, use that file
  2. If `activeTicket` is configured, use `.speclet/tickets/<activeTicket>/draft.md`
  3. Otherwise, use `.speclet/draft.md`
- Ensure the resolved draft exists before proceeding

### Step 2: Parse Council Summary

- Extract decisions and statuses
- Build a list of **Accepted** items to apply
- Apply overrides (accept/reject/defer)

### Step 3: Apply Accepted Changes

- Update draft scope, stories, or acceptance criteria based on accepted decisions
- If `--exclude-story` is set, remove the story from the draft and note it in decisions
- Add or update a **Council Decisions** block in the draft (summary only)

### Step 4: Update Council Summary

- Append the resolved status (Accepted/Rejected/Deferred) for each item
- Record overrides used

### Step 5: Output

- Updated `draft.md` (spec-ready)
- Updated `council-summary.md`

## Output Format

### Council Decisions Block (in draft)

```markdown
## Council Decisions

- Accepted: C1, C3
- Rejected: C2
- Deferred: C4
- Overrides: --exclude-story STORY-3
```

## Notes

- This skill never writes the full review into `draft.md`.
- Use `speclet-spec` immediately after consolidation.
