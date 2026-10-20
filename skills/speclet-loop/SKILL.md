---
name: speclet-loop
description: Execute approved Speclet Markdown tasks with consulted worktree, TDD, verification and atomic commits; manual review is a separate skill.
license: MIT
metadata:
  workflow: speclet
  phase: implementation
---

# Speclet Loop

Implement the approved change and prove it works. `tasks.md` preserves progress; tests and diffs demonstrate behavior. **Never launch a reviewer or `$speclet-review` automatically.**

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

Make the smallest complete change: reuse existing code and preserve public contracts, validation, and error handling. Check compliance with the project rules (`.speclet/rules.md`, `rules.md`, or `.speclet/constitution.md`) when present: favor helper extraction and logic reuse over duplication (Ponytail), ensure queries leverage defined database indexes/keys, and enforce security/sanitization invariants. Adjust affected consumers, tests, and fixtures; do not refactor unrelated areas.

Execute task verifications and assert AC compliance. Non-trivial logic and regressions require discriminating tests; trivial edits do not warrant artificial suites. If justified by a critical branch, temporarily alter a condition to ensure the test fails; restore and re-verify before review or commit. Do not disable tests or pass mocks off as evidence of real external providers.

Targeted checks applied only when relevant to the change:

- **Data/Transactions:** Parameterization, correct connection/transaction boundaries, rollback, and concurrency as dictated by the affected contract.
- **Errors:** Preserve public contract, correlation IDs, and secret redaction; distinguish confirmed failures from uncertain outcomes.
- **Network/Retries:** Deadlines and bounded retry attempts; never repeat non-idempotent operations without verified deduplication. Do not add unnecessary circuit breakers, infrastructure, or manuals.

A failed or unexecuted verification does not equal success. Record limitations and keep the task pending if required evidence is missing.

## Cost-Aware Execution; Review Is Manual

The orchestrator owns decisions, implementation, integration, tests, task state and commits. **Do not spawn subagents automatically** for exploration, implementation, verification or closure. Run project-native tests directly; they do not constitute a reviewer.

Only if the user explicitly requests delegation may the orchestrator spawn **at most one direct child**, with no nested delegation and exactly one writer per worktree. Select an explicitly configured cheaper model with low reasoning effort only when the runtime can enforce the override. Never silently inherit a costly parent model or escalate. If cost constraints cannot be enforced, do the work in the main session and disclose the limitation.

Independent reviews belong **exclusively** to `$speclet-review`, invoked manually by the user after the implementation. Do not commission a review per task or a final review automatically. Reviewer availability or verdict is **not** a prerequisite for task verification, local commits or implementation closure.

Maintain TDD and the required acceptance checks on **each task** before committing. No passing test should be misrepresented as an independent code review.

## Commit and Progress

Only after the task's required verification passes:

1. Inspect the diff and stage only task-related files, along with necessary tests and fixtures. Never stage unrelated changes or `.speclet/**`.
2. Create a local commit per task following repository style with a concise description in Spanish (e.g., `git commit -m "feat(scope): descripción"`). Append Jira issue key only if one exists; do not invent one. Never create empty commits.
3. In `tasks.md`, record executed commands/exit codes, verified ACs, relevant notes (including technical rulings if any), and commit SHA. Mark `[x]` only then, and clear the active task marker. Manual review is a separate, optional state.
4. Continue without asking "should I continue?". A task satisfied by an earlier commit may only be closed after verifying the actual evidence; cite the existing SHA without redundant commits.

If a commit fails, keep the task pending and explain the error; do not redo already verified implementation. Any change made to code after review invalidates that review.

## Closing After Implementation (No Automatic Review)

1. Execute planned integration verification and check that all ACs and task tests have real evidence. Look for accidental temporary files and unrelated staged changes. This is a lightweight implementation gate, **not a 3D independent reviewer**.
2. If a required check fails, record the blocker in `tasks.md` and leave it pending; never misreport success or automatically revert valid commits.
3. When all tasks and integration checks pass, set `Estado: Implementado` in `tasks.md` (legacy `Terminado` remains readable). Record `Revisión manual: Pendiente` unless an unchanged HEAD was already explicitly reviewed. Do not imply independent approval.
4. Stop after informing the user of commits, tests and limitations. Explain that `$speclet-review` is an **optional manual command** for whole-change review. **Do not invoke it, a reviewer subagent, or a review retry automatically.**
5. `$speclet-archive` is also manual and can archive an implemented change without review, warning explicitly if that review was skipped or is stale.

When subsequent implementation changes HEAD, the prior review's HEAD is outdated until a new explicit `$speclet-review`. The review skill owns the 3D rubric and its advisory findings.

Provide ready-to-run post-merge commands on request; do not force interactive execution. Push, PR, merge, deployments and publication require explicit user authorization.

