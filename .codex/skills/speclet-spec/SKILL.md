---
name: speclet-spec
description: Convert a draft document into an executable spec.json with trackable stories
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Spec Skill

Convert a draft document into an executable spec.json.

## What I Do

- Convert `.speclet/draft.md` into `.speclet/spec.json`
- Create atomic stories with verifiable acceptance criteria
- Number functional requirements (FR-1, FR-2, etc.)
- Set up `passes: true/false` tracking for each story

## When to Use Me

Use this after creating a draft with `speclet-draft` skill, or for quick fixes:
- Convert draft to executable spec
- Create spec-lite for quick fixes (Tier 2)

## Your Task

Convert `.speclet/draft.md` into `.speclet/spec.json`.

### Step 1: Read the Draft

Read `.speclet/draft.md` and extract:
- Feature name and summary
- Non-goals
- Proposed stories
- Files to modify

### Step 2: Create spec.json

Generate `.speclet/spec.json`:

```json
{
  "feature": "[Feature Name]",
  "branch": "feature/branch-name",
  "date": "YYYY-MM-DD",
  "summary": "[1-2 sentences of the goal]",
  "nonGoals": [
    "[What this feature will NOT do]"
  ],
  "functionalRequirements": [
    "FR-1: The system must [specific requirement]",
    "FR-2: When user does X, the system must [response]"
  ],
  "stories": [
    {
      "id": "STORY-1",
      "title": "[Short title - 2-3 words]",
      "description": "[2-3 sentences max]",
      "files": ["path/to/file.ts"],
      "acceptanceCriteria": [
        "[Specific verifiable criterion]",
        "Build/typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## Critical Rules

### Story Sizing

**If you cannot describe the change in 2-3 sentences, it's too big. Split it.**

✅ Right-sized:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic

❌ Too big (split these):
- "Build the entire dashboard"
- "Add authentication"

### Story Order: Dependencies First

1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views

### Acceptance Criteria: Must Be Verifiable

✅ Good:
- "Add `status` column with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"

❌ Bad:
- "Works correctly"
- "Good UX"

Always include:
- `Build/typecheck passes` (every story)
- `Verify in browser` (UI stories)

## Spec-Lite (Tier 2)

For quick fixes (15-60 min), create `.speclet/spec-lite.json`:

```json
{
  "feature": "[Title]",
  "branch": "fix/branch-name",
  "date": "YYYY-MM-DD",
  "problem": "[1-2 sentences]",
  "solution": "[Description]",
  "files": ["path/file.ts"],
  "acceptanceCriteria": ["Build passes", "[Criterion]"],
  "passes": false,
  "notes": ""
}
```

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

## Output

- Full spec: `.speclet/spec.json`
- Quick fix: `.speclet/spec-lite.json`

When complete:

> "Spec saved. Ready to implement? Use the speclet-loop skill."
