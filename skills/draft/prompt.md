# Speclet Draft Skill

Generate a collaborative draft document for a new feature.

## Usage

```
Load the draft skill and create a draft for [your feature description]
```

## Your Task

You are helping a developer define requirements for a new feature. Your goal is to:

1. Understand the feature through clarifying questions
2. Create a structured draft document
3. Identify scope, non-goals, and affected files

## Step 1: Ask Clarifying Questions

Ask 3-5 critical questions with **lettered options** for quick responses. Focus on:

- **Goal:** What problem does this solve?
- **Scope:** Minimal vs full-featured?
- **Boundaries:** What should it NOT do?
- **Success:** How do we know it's done?

Format questions like this:

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

## Step 2: Create Draft Document

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

2. [Next question]
   ...

---

## Proposed Scope

### Included

- [What this feature WILL do]
- [Be specific]

### Non-Goals (Out of Scope)

- [What this feature will NOT do]
- [Critical for preventing scope creep]
- [Be explicit about boundaries]

---

## Files to Modify

| File | Changes | Complexity |
| ---- | ------- | ---------- |
| `path/to/file.ts` | [Description] | 🟢/🟡/🔴 |

---

## Stories (Draft)

<!--
Each story: 2-3 sentences max. If more, split it.
Order: schema → backend → UI → dashboard
-->

1. **STORY-1:** [2-3 sentence description]
2. **STORY-2:** [2-3 sentence description]
3. **STORY-3:** [2-3 sentence description]

---

## Pending Questions

1. [Any remaining uncertainties]
```

## Step 3: Confirm with User

After creating the draft, ask:

> "Does this capture everything? Any changes before we convert to spec.json?"

## Rules

- **Max 5 questions** - Don't overwhelm
- **Lettered options** - Enable quick "1A, 2C" responses
- **Non-Goals mandatory** - Always include what it WON'T do
- **Story sizing** - If you can't describe in 2-3 sentences, it's too big
- **Dependency order** - Schema first, UI last

## Output

Save the draft to `.speclet/draft.md`

When complete, tell user:

> "Draft saved to `.speclet/draft.md`. Ready to convert to spec? Load the spec skill."
