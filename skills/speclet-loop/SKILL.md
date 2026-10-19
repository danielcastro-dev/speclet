---
name: speclet-loop
description: Execute Markdown tasks of an approved Speclet change with consulted worktree, tests, independent review, and local commit per task. Continue until finished or blocked; not for planning or legacy JSON workflow.
license: MIT
metadata:
  workflow: speclet
  phase: implementation
---

# Speclet Loop

Implement the approved change and prove it works. `tasks.md` preserves progress; tests and diffs demonstrate behavior.

## Language and Communication Rules

- **Always speak, ask questions, and interact with the user in Spanish.**
- **Write commit messages in Spanish** using repository style (e.g., `feat(scope): descripción concisa`).
- **Update `tasks.md` and document notes/evidence in Spanish.**
- Preserve standard technical terms in English ("log", "health", "endpoint", "middleware", "worktree", "payload", "token", "diff", "gate", "runtime", etc.). Do not translate technical jargon awkwardly.

## Input and Authorization

1. Resolve `.speclet/changes/<name>/` from the given path. Without a path, select the single unfinished change having spec, plan, and tasks; if multiple exist, ask the user to pick. Do not import legacy status. If only legacy status exists, state that a new change is required.
2. Read the three Markdown files and applicable instructions. Require an approved spec, resolved material decisions, and authorization to execute the plan. An explicit user request to run this loop on that plan counts as authorization; do not ask for redundant confirmation.
3. Load `ponytail` and `caveman` by reading their installed entrypoints. Ponytail guides code and review; Caveman abbreviates only Spanish chat. Borrowed activation ends upon exiting Speclet, without turning off modes previously activated by the user. Documents, commits, questions, and errors keep normal language and exact data.

## Worktree First, Always Consulted

Before creating a worktree or switching checkouts, propose a concrete path and branch, and ask the user. **Do not create or switch while the response is pending.** Approving the plan does not substitute this choice. If the user already authorized that worktree for this work, verify it and reuse it without asking again. If rejected, do not write code until another checkout is agreed.

Inspect Git status, branch, root, and existing worktrees. Apply the submodule guard (`git rev-parse --show-superproject-working-tree` 2>/dev/null): if it returns a path, the workspace is inside a submodule and not an isolated checkout or main root; handle accordingly to avoid breaking the superproject structure. Do not force checkouts, clean untracked foreign changes, or assume a `main` base. Use the agreed base or the current branch indicated in the plan. All tasks share the change's authorized worktree.

When creating the worktree, carry over only the three local Markdown files and apply the local Speclet Git exclude (`git rev-parse --git-path info/exclude`). Do not copy secrets, dependencies, or build artifacts automatically. Contrast existing documents before replacing them. If authorized environment setup is missing, declare the requirement.

## Baseline and Selection

- Before editing code, run relevant detected project commands once. Record command, key signal, and exit code in the verification section of `plan.md`, without generating a separate report.
- Distinguish inherited failures, environment issues, and own regressions. An inherited failure is not a passing test and does not authorize fixing unrelated code. If it blocks a required gate, stop unless an explicit, documented exception is granted by the user.
- Select the first pending task whose dependencies are satisfied. Keep one active task per worktree and mark it in `tasks.md` to support resumption.
- When resuming, contrast progress against actual files and commits. Do not re-run closed tasks or trust evidence from an altered diff.

## Implement and Verify

Make the smallest complete change: reuse existing code and preserve public contracts, validation, and error handling. Check compliance with the project constitution (`.speclet/constitution.md` or `constitution.md`) when present: favor helper extraction and logic reuse over duplication (Ponytail), ensure queries leverage defined database indexes/keys, and enforce security/sanitization invariants. Adjust affected consumers, tests, and fixtures; do not refactor unrelated areas.

Execute task verifications and assert AC compliance. Non-trivial logic and regressions require discriminating tests; trivial edits do not warrant artificial suites. If justified by a critical branch, temporarily alter a condition to ensure the test fails; restore and re-verify before review or commit. Do not disable tests or pass mocks off as evidence of real external providers.

Targeted checks applied only when relevant to the change:

- **Data/Transactions:** Parameterization, correct connection/transaction boundaries, rollback, and concurrency as dictated by the affected contract.
- **Errors:** Preserve public contract, correlation IDs, and secret redaction; distinguish confirmed failures from uncertain outcomes.
- **Network/Retries:** Deadlines and bounded retry attempts; never repeat non-idempotent operations without verified deduplication. Do not add unnecessary circuit breakers, infrastructure, or manuals.

A failed or unexecuted verification does not equal success. Record limitations and keep the task pending if required evidence is missing.

## Delegation and Independent Review

The orchestrator retains decisions, integration, state, and commits. Delegate implementation/investigation only when it adds clear value. Maximum three direct children, no sub-delegation, inheriting session configuration without hardcoding deprecated models or effort tiers. Exactly one writer per worktree; reviewers make no edits or commits.

After verifying each task, request **an independent review** from a subagent with self-contained context:

- Objective, AC, active task, paths to spec/plan/tasks, and relevant constraints.
- Exact base and diff (including new files) and consumers to read.
- Executed commands and observed outputs, without presenting them as conclusive proof of correctness.
- Request an acceptance and quality review: finding, file/line, impact, and verification step. Request a concise, explicit verdict; no separate report file.

Contrast findings against code before accepting them. The review identifies non-compliance, real bugs, and insufficient tests; it must not demand unrelated refactoring for stylistic preferences. Apply the **"Rulings, not stalls"** principle: when encountering minor technical discrepancies, stylistic preferences, or harmless ambiguities that do not break AC or public contracts, the orchestrator issues a reasoned technical ruling, documents it in the notes of `tasks.md`, and continues execution without stalling the loop.

Fix accepted blocking findings; re-run affected tests and review the updated diff. Maximum **two correction rounds per task** after the initial review. If a true blocker persists that cannot be resolved via technical ruling, record it and pause the loop with the task pending. Non-blocking observations may remain justified.

If independent review is unavailable, declare the limitation and halt before committing. Do not silently substitute self-review or fake approvals. Do not produce review reports, JSON catalogs, or mandatory diaries.

## Commit and Progress

Only after verification and review pass:

1. Inspect the diff and stage only task-related files, along with necessary tests and fixtures. Never stage unrelated changes or `.speclet/**`.
2. Create a local commit per task following repository style with a concise description in Spanish (e.g., `git commit -m "feat(scope): descripción"`). Append Jira issue key only if one exists; do not invent one. Never create empty commits.
3. In `tasks.md`, record executed commands/exit codes, verified ACs, verdict, relevant notes (including technical rulings if any), and commit SHA. Mark `[x]` only then, and clear the active task marker.
4. Continue without asking "should I continue?". A task satisfied by an earlier commit may only be closed after verifying evidence and review; cite the existing SHA without creating redundant commits.

If a commit fails, keep the task pending and explain the error; do not redo already verified implementation. Any change made to code after review invalidates that review.

## Closing and Final Review

Execute the planned integration verification. Before declaring completion, perform a final closing review using the **3D Review Rubric**:

1. **Completeness:** Verify all ACs from `spec.md` and test coverage from `plan.md` are satisfied by the final combined diff.
2. **Contract Integration:** Verify public APIs, consumers, migrations, and interfaces align without unintended breaking changes.
3. **Cruft and Cleanliness:** Ensure no debug logs, temporary test scaffolding, leftover TODOs, commented-out dead code, or unintended tracked files remain.

If the change spans multiple components or contracts, commission an independent review of the combined diff. If closing verification fails, record the blocker in `tasks.md`; do not mark complete or automatically revert valid task commits.

Update overall status to `Terminado` in `tasks.md` only after successful closing. Reply to the user in Spanish with the outcome, commit list, test results, and any genuine limitations. Offer `$speclet-archive` to cleanly move `.speclet/changes/<name>/` to `.speclet/archive/YYYY-MM-<name>/` without cluttering the repository. Provide ready-to-run post-merge commands (merge, worktree/branch cleanup, and verification commands) ready to copy or execute on request, without forcing interactive execution. Do not create separate diaries, handoff files, or extra reports. Push, PR, merge, deployments, and publishing require explicit user authorization; do not execute them automatically or force interactive prompts to do so.
