# Speclet Spec Skill

Convert a draft document into an executable spec.json.

## Usage

```
Load the spec skill and convert draft.md to spec.json
```

Or for quick fixes (Tier 2):

```
Load the spec skill and create a spec-lite for [bug/fix description]
```

## Your Task

Convert `.speclet/draft.md` into `.speclet/spec.json` - a structured, trackable execution plan.

## Step 1: Read the Draft

Read `.speclet/draft.md` and extract:
- Feature name and summary
- Non-goals
- Proposed stories
- Files to modify

## Step 2: Create spec.json

Generate `.speclet/spec.json`:

```json
{
  "feature": "[Feature Name]",
  "branch": "feature/branch-name",
  "date": "YYYY-MM-DD",
  "summary": "[1-2 sentences of the goal]",
  "nonGoals": [
    "[What this feature will NOT do]",
    "[From draft's Non-Goals section]"
  ],
  "functionalRequirements": [
    "FR-1: The system must [specific requirement]",
    "FR-2: When user does X, the system must [response]",
    "FR-3: [Be explicit and unambiguous]"
  ],
  "stories": [
    {
      "id": "STORY-1",
      "title": "[Short title - 2-3 words]",
      "description": "[2-3 sentences max - if more, split the story]",
      "files": ["path/to/file.ts"],
      "acceptanceCriteria": [
        "[Specific verifiable criterion - not vague]",
        "[Another specific criterion]",
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
- "Refactor the API"

### Story Order: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

### Acceptance Criteria: Must Be Verifiable

Each criterion must be CHECKABLE, not vague.

✅ Good:
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Clicking delete shows confirmation dialog"

❌ Bad:
- "Works correctly"
- "User can do X easily"
- "Good UX"
- "Handles edge cases"

### Required Final Criteria

Always include:
- `Build/typecheck passes` (every story)
- `Verify in browser` (UI stories)

### Functional Requirements

Number each requirement: FR-1, FR-2, FR-3...
Be explicit and unambiguous.

### Non-Goals

Copy from draft. If draft didn't have them, ASK the user:

> "What should this feature explicitly NOT do?"

## Step 3: Verify with User

After creating spec.json, show summary:

```
## Spec Created: [Feature Name]

**Branch:** feature/branch-name
**Stories:** N total

| ID | Title | Priority | Files |
|----|-------|----------|-------|
| STORY-1 | [Title] | 1 | file.ts |
| STORY-2 | [Title] | 2 | file.ts |

**Non-Goals:**
- [List them]

Ready to implement? Load the loop skill.
```

## Spec-Lite (Tier 2)

For quick fixes (15-60 min), create `.speclet/spec-lite.json`:

```json
{
  "feature": "[Title]",
  "branch": "fix/branch-name",
  "date": "YYYY-MM-DD",
  "actualTime": "",
  "problem": "[1-2 sentences of the bug or need]",
  "solution": "[Description of the fix]",
  "files": ["path/file.ts"],
  "acceptanceCriteria": [
    "Build passes",
    "[Specific verifiable criterion]"
  ],
  "passes": false,
  "notes": ""
}
```

## Output

- Full spec: `.speclet/spec.json`
- Quick fix: `.speclet/spec-lite.json`

When complete:

> "Spec saved. Ready to implement? Load the loop skill to start autonomous execution."
