---
name: speclet-draft
description: Generate a collaborative draft document with clarifying questions for a new feature
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Draft Skill

Generate a collaborative draft document for a new feature or refine an existing ticket.

## What I Do

- Ask 3-5 clarifying questions with lettered options for quick responses
- Create a structured draft document at `.speclet/draft.md`
- Identify scope, non-goals, and affected files
- Break down the feature into right-sized stories
- **For tickets:** Read existing ticket context and refine into actionable draft

## When to Use Me

Use this when:
- Starting a new feature and you need to clarify requirements
- Working on a specific ticket: `speclet-draft for TICKET-N`
- Defining scope and non-goals before coding

## Your Task

### Step 0: Detect Ticket Mode

**Check if the user prompt contains `TICKET-N` pattern** (e.g., "TICKET-1", "TICKET-3").

If yes → **Ticket Mode** (Step 1A)
If no → **Normal Mode** (Step 1B)

---

### Step 0.1: Context Switching and Collision Prevention

Before any mode, check for an existing `activeTicket` in `.speclet/config.json`:

1. **Read config:** `Read .speclet/config.json`
2. **If `activeTicket` exists:**
    - If it's different from the new target (or if target is Normal Mode):
        - **Stash current draft:** `mv .speclet/draft.md .speclet/tickets/[activeTicket]/draft.md` (if draft exists)
        - **Clear activeTicket:** Update `config.json` to reflect the new state.
3. **If starting a new ticket:**
    - Update `config.json` setting `activeTicket` to the new ID.

---

### Step 1A: Ticket Mode

When user says something like "speclet-draft for TICKET-1":

#### 1. Locate and validate the ticket

```
Read .speclet/tickets/TICKET-N/ticket.json
```

**Validation (CRITICAL):**
- Check if file exists at `.speclet/tickets/TICKET-N/ticket.json`
- Check if `"specletVersion"` field exists and equals `"1.0"`

**If validation passes:**
- Update `activeTicket` in `.speclet/config.json` to `TICKET-N`.
- Continue to step 2.

#### 2. Read ticket context

```
Read .speclet/tickets/TICKET-N/ticket-draft.md
```

This file contains the general draft context from when tickets were created.
If a `draft.md` already exists in the ticket folder (from a previous stashed session), use that instead.

#### 3. Read source document (optional but recommended)

The `sourceContext` field in the ticket JSON points to the original source:

```
Read [sourceContext path] if it exists
```

#### 4. Summarize context and ask questions

Present what you found:

```
📋 **TICKET-N: [title]**

**Description:** [from ticket JSON]

**Source:** [sourceContext]

**Preliminary Criteria:**
- [criterion 1]
- [criterion 2]

**Affected Files:** [files array]

---

Based on the ticket context, I have some clarifying questions:

1. [Question with options]
   A. ...
   B. ... ⭐ Recommended
   
2. [Question with options]
   ...
```

#### 5. Create refined draft

After getting answers, create `.speclet/draft.md` with the refined, actionable draft.

The draft should be more specific than `ticket-draft.md` — focused on implementation details.

---

### Step 1B: Normal Mode (No Ticket)

Standard flow for new features.

#### Ask Clarifying Questions

Ask 3-5 critical questions with **lettered options** for quick responses:

```
1. What is the primary goal?
   A. Improve user experience
   B. Fix existing bug
   C. Add new functionality
   D. Refactor/cleanup
   E. Other: ___

2. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
   C. Just the backend/API
   D. Just the UI
```

User responds quickly: **"1C, 2A"**

Focus on:
- **Goal:** What problem does this solve?
- **Scope:** Minimal vs full-featured?
- **Boundaries:** What should it NOT do?
- **Success:** How do we know it's done?

---

### Step 2: Create Draft Document

After getting answers, create `.speclet/draft.md`:

```markdown
# Draft: [Feature Name]

**Status:** In definition  
**Date:** YYYY-MM-DD  
**Branch:** feature/[suggested-branch-name]
**Ticket:** TICKET-N (if applicable)

---

## User Description

> [Original feature description from user]

---

## Clarifying Questions

1. [Question]
   A. ...
   B. ...
   
   **Answer:** [User's choice with explanation]

---

## Proposed Scope

### Included

- [What this feature WILL do]

### Non-Goals (Out of Scope)

- [What this feature will NOT do]
- [Critical for preventing scope creep]

---

## Files to Modify

| File | Changes | Complexity |
| ---- | ------- | ---------- |
| `path/to/file.ts` | [Description] | 🟢/🟡/🔴 |

---

## Stories (Draft)

1. **STORY-1:** [2-3 sentence description]
2. **STORY-2:** [2-3 sentence description]

---

## Pending Questions

1. [Any remaining uncertainties]
```

### Step 3: Confirm with User

After creating the draft, ask:

> "Does this capture everything? Any changes before we convert to spec.json?"

## Rules

- **Max 5 questions** - Don't overwhelm
- **Lettered options** - Enable quick "1A, 2C" responses
- **Non-Goals mandatory** - Always include what it WON'T do
- **Story sizing** - If you can't describe in 2-3 sentences, it's too big
- **Dependency order** - Schema first, UI last
- **Validate specletVersion** - Only process tickets with `"specletVersion": "1.0"`

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

## Ticket Mode Flow Summary

```
User: "speclet-draft for TICKET-1"
     │
     ▼
Check .speclet/tickets/TICKET-1/ticket.json
     │
     ├── File exists AND has "specletVersion": "1.0"? 
     │   │
     │   ├── NO → Fallback to Normal Mode (treat as feature description)
     │   │
     │   └── YES → Ticket Mode:
     │        │
     │        ▼
     │   Read .speclet/tickets/TICKET-1/ticket-draft.md
     │        │
     │        ▼
     │   Read sourceContext document (if exists)
     │        │
     │        ▼
     │   Present context + ask clarifying questions
     │        │
     │        ▼
     │   Create .speclet/draft.md (refined)
     │
     ▼
"Ready to convert to spec? Use speclet-spec skill."
```

## Output

Save the draft to `.speclet/draft.md`

When complete:

> "Draft saved to `.speclet/draft.md`. Ready to convert to spec? Use the speclet-spec skill."
