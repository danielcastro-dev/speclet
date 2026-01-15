---
name: speclet-council
description: Run parallel multi-model reviews on .speclet/draft.md and emit Council artifacts
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Council Skill

Run a multi-model council review over an existing `.speclet/draft.md`, then emit audit artifacts.

## What I Do

- Validate `.speclet/draft.md` exists before any work
- Invoke four reviewers in parallel with per-reviewer timeouts and retries
- Collect critiques and generate a **Review Status Header** (succeeded vs. failed models)
- Synthesize feedback using **Thematic Clustering** and collapsible HTML tags
- Write `.speclet/council-session.md` and `.speclet/council-summary.md`
- Write optional `.speclet/draft.review.md` (full Council Review)
- Support `--dry-run` mode with mocked reviewer outputs

## When to Use Me

Use this after a draft exists and before converting to spec:

```
Use the speclet-council skill
```

## Setup (Required)

Reviewers must be configured in your `oh-my-opencode.json`:

- `plan-reviewer-opus` (architecture)
- `plan-reviewer-sonnet` (documentation clarity)
- `plan-reviewer-gemini` (edge cases and scalability)
- `plan-reviewer-gpt` (implementability)

**Permissions (recommended):**
- `read`: allow
- `webfetch`: allow (optional)
- `edit`: deny
- `bash`: deny

Do not edit `oh-my-opencode.json` from this repo; document this setup for the user.

## Inputs

- `.speclet/draft.md` (required)
- Reviewer prompts in `.opencode/skill/speclet-council/prompts/`

## Outputs

- `.speclet/council-session.md` (full audit log)
- `.speclet/council-summary.md` (executive summary)
- `.speclet/draft.review.md` (optional full review)

## Your Task

### Step 1: Validate Draft Exists

Check for `.speclet/draft.md`.

If missing, fail with:

```
❌ Missing .speclet/draft.md
Run speclet-draft first to create a draft before using speclet-council.
```

### Step 2: Load Reviewer Prompts

Use these prompt templates:

- `.opencode/skill/speclet-council/prompts/reviewer-opus.md`
- `.opencode/skill/speclet-council/prompts/reviewer-sonnet.md`
- `.opencode/skill/speclet-council/prompts/reviewer-gemini.md`
- `.opencode/skill/speclet-council/prompts/reviewer-gpt.md`

Each prompt defines a strict output contract. Pass the draft content inline after the prompt.

### Step 3: Parallel Review Invocation

Launch all reviewers in parallel using `call_omo_agent` with `run_in_background=true`.

Pseudo-flow:

```typescript
for (const reviewer of ["opus", "sonnet", "gemini", "gpt"]) {
  const prompt = `[PROMPT TEMPLATE CONTENT]\n\nDraft Content:\n${draftContent}`;
  call_omo_agent(
    subagent_type="explore",
    description=`Council Review: ${reviewer}`,
    prompt=prompt,
    run_in_background=true,
    session_id=reviewer
  );
}
```

**Defaults:**
- Per-reviewer timeout: 500s
- Max retries: 3
- Backoff: 1s → 2s → 4s

### Step 4: Classify Errors and Retry

Retry only for transient errors. If using `call_omo_agent`, monitor the task status via `background_output`.

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

### Step 6: Synthesize Council Review

Use a specialized synthesis prompt to consolidate all issues using **Thematic Clustering**:
1. **Thematic Grouping**: Identify shared problems across reviewers and group them under a single descriptive heading.
2. **Nuance Preservation**: Do NOT delete unique details. If Reviewer A found a race condition and Reviewer B found a general concurrency limit in the same area, list them both as distinct perspectives under the same theme.
3. **UX Formatting**: Use HTML `<details>` and `<summary>` tags. The summary MUST contain the severity (🔴 HIGH, 🟡 MEDIUM, 🟢 LOW) and the theme title.
4. **Reviewer Attribution**: Clearly state which models identified each issue.
5. **Language Parity**: Detect the language of the draft and ensure the synthesis matches it exactly.
6. **HTML Integrity**: Ensure all `<details>` blocks are correctly opened and closed.

Write the full Council Review into `.speclet/draft.review.md` (not into `draft.md`).

```markdown
# Council Review

### Status
- ✅ plan-reviewer-opus
- ✅ plan-reviewer-sonnet
- ⚠️ plan-reviewer-gemini (Timeout)
- ✅ plan-reviewer-gpt

<details>
<summary>🔴 HIGH: [Theme Title]</summary>

- **Reviewers:** Opus, GPT
- **Problem:** [Consolidated description of the theme]
- **Specific Notes:**
  - **Opus:** [Unique architectural nuance]
  - **GPT:** [Unique implementation detail]
- **Consolidated Suggestion:** [Actionable fix merging both suggestions]
</details>
```

### Step 7: Write Council Artifacts

Write `.speclet/council-session.md` with a deterministic audit log:

```markdown
# Council Session

- Started: YYYY-MM-DD HH:MM
- Finished: YYYY-MM-DD HH:MM

## Review Tasks
- plan-reviewer-opus
  - task_id: <id>
  - status: success|failed
  - attempts: N
  - error: [if failed]
- plan-reviewer-sonnet
  - task_id: <id>
  - status: success|failed
  - attempts: N
  - error: [if failed]

## Critiques
### plan-reviewer-opus
[raw critique output]

### plan-reviewer-sonnet
[raw critique output]
```

Write `.speclet/council-summary.md` as an executive summary:

```markdown
# Council Summary

- Total issues: N
- By severity: High H / Medium M / Low L
- By reviewer: opus X / sonnet Y / gemini Z / gpt W

## Decisions
- Accepted: [list]
- Rejected: [list]
- Deferred: [list]

## Draft Changes
- Council Review saved to .speclet/draft.review.md
```

### Step 8: Git Commit Rule

If the repo is clean and draft changes were written, create a commit for the specific artifacts:

```bash
git add .speclet/council-session.md .speclet/council-summary.md .speclet/draft.review.md
git commit -m "feat(speclet-council): save council review"
```

If repo is dirty or git is unavailable, skip the commit and warn the user.

### Step 9: Dry-Run Mode

When invoked with `--dry-run`:
- Do not call external models
- Use mocked reviewer outputs embedded in the skill
- Still write council-session.md, council-summary.md, and draft.review.md

Use this to validate the workflow without API costs.

## Notes

- This skill never modifies `draft.md`; use speclet-consolidate to merge accepted feedback.
- **English-First Protocol:** Internal orchestration prompts and background task instructions are in English for reliability, but final user-facing output matches the draft's language.
- Webfetch policies can only be enforced via reviewer prompts or disabled in agent config.
