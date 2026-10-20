---
name: speclet-review
description: Manually verify a complete implemented Speclet change against its specs, tasks and combined diff. No automatic execution, fixes or commits.
license: MIT
metadata:
  workflow: speclet
  phase: review
---

# Speclet Review

A user-invoked, **full-change** review inspired by OpenSpec's separate verify stage. Review all completed tasks together, not after each task. This stage is advisory, not implementation or archiving.

## Language and Entry

- Speak and report in Spanish; retain technical words such as diff, API, AC, TDD, test, runtime and worktree.
- Run **only** when the user explicitly invokes `$speclet-review` or asks to review an implemented Speclet change. `$speclet-loop` and `$speclet-archive` must never trigger it automatically.
- Resolve `.speclet/changes/<name>/` from an explicit path; without a path, auto-select only when exactly one eligible change exists. Ask which change if ambiguous. Read `spec.md`, `plan.md`, `tasks.md` and applicable rules.
- Normally review only after all tasks are done and `Estado: Implementado` (or legacy `Terminado`). If tasks are pending, identify them and stop, unless the user explicitly requested a partial review; clearly label it partial.
- Do not create a fourth required Markdown file, JSON state or mandatory reports.

## One Economical Reviewer or Explicit In-Session Fallback

- One manual invocation authorizes the review **once**, not repeated agents or model escalation.
- Prefer **one read-only independent subagent** with an explicitly selected, enforceably **cheaper model**, low reasoning effort and no nested delegation. Provide self-contained context: spec, ACs, plan, tasks, base/HEAD, combined diff, test results and constraints.
- Never hardcode provider model names, silently inherit the expensive parent model or launch multiple/recursive reviewers. If the runtime cannot enforce economical model selection, do the review in the current session instead, labeled **"Revisión en sesión; no independiente"**. Disclose the absence of an independent cheaper-model reviewer. Never claim the in-session inspection is independent.
- The reviewer must not edit implementation, tests or commits, and must not launch further agents. Do not automatically re-review a changed diff.

## Evidence and Scope

1. Inspect branch, Git status, task commit SHAs and worktree without switching checkouts. Resolve the authorized base from the plan or actual Git context; compute merge-base as appropriate. Review `base...HEAD` as one **combined diff**, including new files and changed consumers. Clearly distinguish uncommitted edits. If base is unknown, mark relevant checks **No verificado**; do not silently assume `main`.
2. Map every AC from `spec.md`, task checkbox and planned edge case to actual implementation and evidence. Do not trust checkboxes alone.
3. Check real executed test evidence, commands and exit codes in `tasks.md`. Run only relevant, bounded read-only verification when useful. A failed, skipped, blocked or inaccessible test is never passing evidence.
4. Inspect public contracts, integrations, data/security boundaries where relevant, project rules, code patterns and temporary/dead code. Avoid unrelated style demands or speculative refactors.

## Three-Dimension Rubric

- **Completitud:** All tasks, ACs, required scenarios and plan cases covered by implementation. Missing required functionality and incomplete tasks are critical.
- **Corrección:** Real implementation, regressions, tested behavior, error handling, API/data contracts and changed consumers. Distinguish confirmed bugs from hypotheses.
- **Coherencia:** Architectural consistency, rule compliance, helper reuse, integration fit, unintended changes, leftover TODOs, debug scaffolding and dead code.

Classify actionable issues as **CRÍTICO** (confirmed blocker), **ADVERTENCIA** (meaningful risk/unverified important condition), or **SUGERENCIA** (nonblocking improvement). Each finding needs location (file and line if possible), impact, and actionable fix/verification. Missing evidence must appear as **No verificado**, not as an implicit pass.

## Verdict and Recording

Report in Spanish:

```markdown
## Speclet Review — <change>
Base: <ref/sha> | HEAD: <sha> | Tipo: Independiente / En sesión
| Dimensión | Resultado |
| Completitud | ... |
| Corrección | ... |
| Coherencia | ... |
Críticos: N; Advertencias: N; Sugerencias: N; No verificado: N
Hallazgos: archivo:línea — impacto — acción
Tests: comando, evidencia, exit code
Veredicto: Aprobada / Con hallazgos / Parcial (no verificada)
```

- An `Aprobada` verdict requires no critical issues **and no unverified applicable checks**. Record remaining warnings transparently. Use `Con hallazgos` for confirmed problems, and `Parcial (no verificada)` when material checks lack evidence.
- Keep a concise **`## Revisión manual` section in existing `tasks.md`** with date, base ref, reviewed HEAD SHA, reviewer type, counts, main findings and verdict. Update/replace only this section on another **explicit invocation**, preserving all tasks and their evidence. The section is optional if local docs are read-only; then state that persistence was unavailable.
- Do not modify source, tests, task checkboxes, implementation status or Git. Do not create separate `review.md`, artifacts, commits, PRs or follow-up actions automatically.
- A new implementation commit makes any old review stale; the user must separately request `$speclet-loop` for fixes and `$speclet-review` for re-review. `$speclet-archive` remains manual and review remains advisory.
