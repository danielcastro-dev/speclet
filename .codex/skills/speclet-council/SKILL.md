---
name: speclet-council
description: Run parallel reviews on draft/spec/ticket inputs and emit Council artifacts
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Council Skill

Run a council review over a draft, spec, or ticket input, then emit audit artifacts.

## What I Do

- Validate the target input exists (`draft.md`, `spec.json`, or a ticket file)
- Invoke two reviewers (GPT, GLM) in parallel with per-reviewer timeouts and retries
- Collect critiques and generate a **Review Status Header** (succeeded vs. failed models)
- Synthesize feedback using **Thematic Clustering** and collapsible HTML tags
- Write `.speclet/council-session.md` and `.speclet/council-summary.md`
- Write optional `.speclet/draft.review.md` (full Council Review)
- Support `--dry-run` mode with mocked reviewer outputs

## When to Use Me

Use this after a target exists and before conversion/implementation:

```
Use the speclet-council skill
```

### Supported Targets

- Draft: `.speclet/draft.md` (default)
- Spec: `.speclet/spec.json` or an explicit spec path
- Ticket: `.speclet/tickets/<TICKET-ID>/draft.md` or `ticket-draft.md`

### Example Invocations

```
Use the speclet-council skill
Use the speclet-council skill for .speclet/spec.json
Use the speclet-council skill for .speclet/tickets/TICKET-1/draft.md
```

If the user says "use speclet-council to review this spec.json" or "review this ticket", treat the referenced file as the target input.

## Setup (Required)

Reviewers must be configured in your `oh-my-opencode.json`:

- `plan-reviewer-gpt` (implementability)
- `plan-reviewer-glm` (clean design and completeness)

Only these two reviewers are used by this skill.

Each agent should be configured to use a distinct model in your OpenCode config (for true multi-model reviews). If they all point to the same model, the council will run but not be multi-model.

**Permissions (recommended):**
- `read`: allow
- `webfetch`: allow (optional)
- `edit`: deny
- `bash`: deny
- `call_omo_agent`: deny
- `background_task`: allow (only for the orchestrator)

Do not edit `oh-my-opencode.json` from this repo; document this setup for the user.

## Inputs

- Target input (default: `.speclet/draft.md`)
- Reviewer prompts in `skills/speclet-council/prompts/`

## Outputs

- `.speclet/council-session.md` (full audit log)
- `.speclet/council-summary.md` (executive summary)
- `.speclet/draft.review.md` (optional full review)

Note: Always read existing artifact files before writing to avoid OpenCode validation errors.
Artifacts are written regardless of target type.

## Your Task

### Step 1: Validate Target Exists

Default target is `.speclet/draft.md` unless a path is provided by the user.

Supported targets:
- `.speclet/draft.md`
- `.speclet/spec.json`
- `.speclet/tickets/<TICKET-ID>/draft.md` or `ticket-draft.md`

If missing, fail with:

```
❌ Missing target file
Provide a valid draft/spec/ticket path before using speclet-council.
```

### Step 2: Load Reviewer Prompts

Use these prompt templates:

- `skills/speclet-council/prompts/reviewer-gpt.md`
- `skills/speclet-council/prompts/reviewer-glm.md`

Each prompt defines a strict output contract. Do not embed the target content in the orchestration prompt; instruct reviewers to read the target path directly. Orchestration prompts must be in English.

If the target is `spec.json`, reviewers should focus on story sizing, acceptance criteria verifiability, file lists, and non-goals.
If the target is a ticket draft, reviewers should focus on scope isolation, missing requirements, and ticket metadata alignment.

### Step 3: Parallel Review Invocation

Launch all reviewers in parallel using `background_task`.

Pseudo-flow:

```typescript
for (const reviewer of ["gpt", "glm"]) {
  background_task(
    agent=`plan-reviewer-${reviewer}`,
    description=`Council Review: ${reviewer}`,
    prompt=`[ENGLISH INSTRUCTIONS ONLY]\n\nPlease read the target file and respond in the target's language.`
  );
}
```

**Defaults:**
- Per-reviewer timeout: 500s
- Max retries: 3
- Backoff: 1s → 2s → 4s

### Step 4: Classify Errors and Retry

Retry only for transient errors. If using `background_task`, monitor the task status via `background_output`.

Transient errors:
- Timeouts
- Rate limit / 429
- Temporary network failures

Do not retry for:
- Invalid model name
- Permission denied
- Missing agent configuration

If a reviewer fails after max retries, record the failure and continue.

### Step 5: Collect Results

Retrieve each task with `background_output(task_id="...", block=true)` and map it back to its reviewer.
Note: Ensure you wait for all tasks to complete or timeout before proceeding to synthesis.

**Review Status Header:**
Generate a summary table or list showing the status of each reviewer.
- ✅ [Model Name] (Success)
- ⚠️ [Model Name] (Failed/Timeout)

If **zero** reviewers succeed, fail with:

```
❌ All reviewers failed
Check API keys, network, or agent configuration. Try again or reduce the reviewer set.
```

If any reviewer fails due to missing agent configuration, include a reminder to install or configure agents as described in the Setup section.

### Step 6: Synthesize Council Review

Use a specialized synthesis prompt to consolidate all issues using **Thematic Clustering**:
1. **Thematic Grouping**: Identify shared problems across reviewers and group them under a single descriptive heading.
2. **Nuance Preservation**: Do NOT delete unique details. If Reviewer A found a race condition and Reviewer B found a general concurrency limit in the same area, list them both as distinct perspectives under the same theme.
3. **UX Formatting**: Use HTML `<details>` and `<summary>` tags. The summary MUST contain the severity (🔴 HIGH, 🟡 MEDIUM, 🟢 LOW) and the theme title.
4. **Reviewer Attribution**: Clearly state which models identified each issue.
5. **Language Parity**: Detect the language of the target and ensure the synthesis matches it exactly.
6. **HTML Integrity**: Ensure all `<details>` blocks are correctly opened and closed.

Before writing any artifacts, read the existing files (if any) to avoid OpenCode read-before-write violations.

Write the full Council Review into `.speclet/draft.review.md` (not into the target file).

```markdown
# Council Review

### Status
- ✅ plan-reviewer-gpt
- ✅ plan-reviewer-glm

<details>
<summary>🔴 HIGH: [Theme Title]</summary>

- **Reviewers:** GPT, GLM
- **Problem:** [Consolidated description of the theme]
- **Specific Notes:**
  - **Opus:** [Unique architectural nuance]
  - **GPT:** [Unique implementation detail]
- **Consolidated Suggestion:** [Actionable fix merging both suggestions]
</details>
```

### Step 7: Write Council Artifacts

Write `.speclet/council-session.md` with a deterministic audit log (include the target path in the header):


```markdown
# Council Session

- Target: path/to/target
- Started: YYYY-MM-DD HH:MM
- Finished: YYYY-MM-DD HH:MM

## Review Tasks
- plan-reviewer-gpt
  - task_id: <id>
  - status: success|failed
  - attempts: N
  - error: [if failed]
- plan-reviewer-glm
  - task_id: <id>
  - status: success|failed
  - attempts: N
  - error: [if failed]

## Critiques
### plan-reviewer-gpt
[raw critique output]

### plan-reviewer-glm
[raw critique output]
```

Write `.speclet/council-summary.md` as an executive summary (read the file first if it already exists):

```markdown
# Council Summary

- Total issues: N
- By severity: High H / Medium M / Low L
- By reviewer: gpt X / glm Y

## Decisions
- Accepted: [list]
- Rejected: [list]
- Deferred: [list]

## Draft Changes
- Council Review saved to .speclet/draft.review.md
```

### Step 8: Git Commit Rule

Do not create commits unless the user explicitly asks.

### Step 9: Dry-Run Mode

When invoked with `--dry-run`:
- Do not call external models
- Use mocked reviewer outputs embedded in the skill
- Still write council-session.md, council-summary.md, and draft.review.md

Use this to validate the workflow without API costs.

## Notes

- This skill never modifies the target file; use /speclet-consolidate to merge accepted feedback when reviewing drafts.
- **English-First Protocol:** Internal orchestration prompts and background task instructions are in English for reliability, but final user-facing output matches the target's language.
- Webfetch policies can only be enforced via reviewer prompts or disabled in agent config.
