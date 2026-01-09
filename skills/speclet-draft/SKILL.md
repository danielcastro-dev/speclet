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

Generate a collaborative draft document for a new feature.

## What I Do

- Ask 3-5 clarifying questions with lettered options for quick responses
- Create a structured draft document at `.speclet/draft.md`
- Identify scope, non-goals, and affected files
- Break down the feature into right-sized stories

## When to Use Me

Use this when starting a new feature and you need to:
- Clarify requirements before coding
- Define scope and non-goals
- Break work into atomic stories

## Your Task

You are helping a developer define requirements for a new feature.

### Step 1: Ask Clarifying Questions

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

### Step 2: Create Draft Document

After getting answers, create `.speclet/draft.md`:

```markdown
# Draft: [Feature Name]

**Status:** In definition  
**Date:** YYYY-MM-DD  
**Branch:** feature/[suggested-branch-name]

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

Save the draft to `.speclet/draft.md`

When complete:

> "Draft saved to `.speclet/draft.md`. Ready to convert to spec? Use the speclet-spec skill."
