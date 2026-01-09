---
name: speclet-ticket
description: Convert a large draft into individual tickets for isolated implementation sessions
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Ticket Skill

Convert a large draft document into individual tickets for isolated implementation sessions.

## What I Do

- Read `.speclet/draft.md` and identify discrete work items
- Generate individual ticket files in `.speclet/tickets/TICKET-N.json`
- Create/update `.speclet/tickets/index.json` for centralized status tracking
- Enable ticket-by-ticket workflow: one ticket → one session → full speclet cycle

## When to Use Me

Use this when:
- A draft contains multiple independent fixes/features
- The combined scope would overwhelm LLM context
- You want to work on items one at a time across sessions

## Your Task

### Step 1: Read the Draft

```
Read .speclet/draft.md
```

Identify discrete work items. Each item that can be implemented independently = 1 ticket.

**Splitting Rule:** 1 ticket = 1 friction/problem. Maximum atomicity.

### Step 2: Ask Clarifying Questions (if needed)

If the draft is ambiguous about how to split, ask questions with lettered options.

**Example:**
```
1. How should I group these items?
   A. One ticket per file mentioned ⭐ Recommended — maximum isolation
   B. Group by feature area
   C. Group by complexity
   D. Keep as single ticket

   **Reason for recommendation:** Isolated tickets prevent context bleed and allow
   prioritization between sessions.
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

### Step 3: Create Ticket Files

For each discrete item, create `.speclet/tickets/TICKET-N.json`:

```json
{
  "id": "TICKET-1",
  "title": "Short descriptive title",
  "description": "2-3 sentences explaining the problem/friction and desired outcome",
  "files": ["path/to/likely/affected/file.ts"],
  "sourceContext": "Reference to where this came from (e.g., 'Code review finding #3')",
  "preliminaryCriteria": [
    "Preliminary acceptance criterion (will be refined in speclet-draft)",
    "Another criterion"
  ],
  "priority": 1,
  "dependsOn": [],
  "retryHints": [],
  "status": "pending"
}
```

#### Field Descriptions

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (TICKET-1, TICKET-2, etc.) |
| `title` | Yes | Short title (< 80 chars) |
| `description` | Yes | 2-3 sentences explaining the problem and desired outcome |
| `files` | Yes | Array of likely affected files (best guess, refined later) |
| `sourceContext` | Yes | Reference to origin (code review, user request, etc.) |
| `preliminaryCriteria` | Yes | Initial acceptance criteria (refined during speclet-draft) |
| `priority` | Yes | Numeric priority (1 = highest) |
| `dependsOn` | No | Array of ticket IDs that must complete first |
| `retryHints` | No | Accumulated hints from failed attempts |
| `status` | Yes | One of: `pending`, `in_progress`, `done`, `blocked` |

### Step 4: Create/Update Index

Create or update `.speclet/tickets/index.json`:

```json
{
  "source": ".speclet/draft.md",
  "createdAt": "2025-01-09T15:30:00Z",
  "tickets": [
    {
      "id": "TICKET-1",
      "title": "Fix empty state guidance",
      "status": "pending",
      "priority": 1
    },
    {
      "id": "TICKET-2", 
      "title": "Improve serial scanner UX",
      "status": "pending",
      "priority": 2
    }
  ]
}
```

### Step 5: Confirm with User

After creating tickets, summarize:

```
✅ Created N tickets from draft.md

| ID | Title | Priority | Dependencies |
|----|-------|----------|--------------|
| TICKET-1 | [title] | 1 | - |
| TICKET-2 | [title] | 2 | TICKET-1 |

**Next steps:**
1. Pick a ticket: "Use speclet-draft for TICKET-1"
2. Complete full cycle: draft → spec → loop
3. Come back for next ticket

Ready to start with TICKET-1?
```

## Workflow Integration

The ticket workflow fits into the speclet ecosystem:

```
Large draft.md
     │
     ▼
speclet-ticket (this skill)
     │
     ▼
.speclet/tickets/
├── TICKET-1.json
├── TICKET-2.json
├── TICKET-3.json
└── index.json
     │
     ▼ (for each ticket, new session)
speclet-draft (refine one ticket)
     │
     ▼
speclet-spec (convert to spec.json)
     │
     ▼
speclet-loop (implement)
     │
     ▼
Mark ticket done, next session
```

## Rules

- **One friction = one ticket** — Maximum atomicity
- **Dependencies are declarative** — Field exists but no automated blocking
- **Preliminary criteria only** — Real criteria come from speclet-draft
- **Status tracking** — Update index.json when ticket status changes
- **No complexity field** — Estimation happens during draft phase

## Output

- Individual tickets: `.speclet/tickets/TICKET-N.json`
- Central index: `.speclet/tickets/index.json`

When complete:

> "Tickets created in `.speclet/tickets/`. Start with: Use speclet-draft for TICKET-1"
