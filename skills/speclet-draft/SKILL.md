---
name: speclet-draft
description: Read the project and agree on requirements through multiple-choice questions before creating a concise spec.md. Use when defining a non-trivial change or starting Speclet; not for simple questions, reviews, or single-file fixes.
license: MIT
metadata:
  workflow: speclet
  phase: definition
---

# Speclet Draft

Define **what changes and how we will know it works**. Do not implement or pick an architecture before understanding the problem.

## Language and Communication Rules

- **Always speak, ask questions, and interact with the user in Spanish.**
- **Write `spec.md` in Spanish.**
- Preserve standard technical terms in English ("log", "health", "endpoint", "middleware", "worktree", "payload", "token", etc.). Do not translate technical jargon awkwardly.

## Operating Principles

- Load installed skills `ponytail` and `caveman` by reading their `SKILL.md`. Ponytail guides simplicity and reuse; Caveman keeps Spanish chat concise. This borrowed activation ends upon exiting Speclet; respect any mode previously activated by the user. Documents, questions, commands, and errors keep normal grammar and exact data. Do not activate plugins, hooks, or proxies.
- Reuse existing code and dependencies. Discard speculative extras while preserving requested behavior and verifications.
- Read existing policies and the project rules (`.speclet/rules.md`, `rules.md`, or `.speclet/constitution.md`) when present. Treat its guidelines (Ponytail logic reuse, DB schema invariants, naming conventions) as non-negotiable rules. Do not demand or generate manuals, central catalogs, baseline.md, or project-context.md.

## 1. First: Understand the Project

Before asking requirement questions, perform a targeted inspection: project rules (`.speclet/rules.md`, `rules.md`, or `.speclet/constitution.md`), applicable instructions, manifests, affected area structure, entry points, consumers, tests, and conventions. Trace relevant behavior without routinely walking the entire repo or running services just to prepare questions.

Briefly summarize what exists, where the change fits, and which decisions remain open. Support key facts with project file paths. Do not ask the user about technologies, files, or behaviors that this inspection can answer. If no project is accessible, state this limit and ask only for necessary context.

## 2. Next: Multiple-Choice Questions in Short Rounds

- Present 1 to 3 questions per round, only if answers alter scope, behavior, acceptance, or key risks.
- Prefer multiple-choice: 2 to 4 concrete options, with a recommendation and one sentence explaining tradeoffs. Do not invent filler options or force a choice when an open question is needed.
- Use the structured question tool available in the environment (`ask_question`). If unavailable, number questions and label options A/B/C so the user can reply `1B, 2A`.
- Formulate questions in Spanish with complete, clear sentences, even if Caveman is active. Accept free-form and hybrid answers; options guide but do not restrict the user's choice.
- Incorporate each answer before the next round. Do not repeat answered questions or treat recommendations as user approvals.
- If the change is already well-defined, summarize it and confirm only missing approvals; do not fabricate an interview. Prior reading is still required.

## 3. Specification Document

Resolve the Git root and a stable descriptive change name. Write exclusively to `.speclet/changes/<name>/spec.md` in Spanish. If a path is provided, use it. If the name belongs to another task, ask before overwriting.

Documents are local: exclude the new directory via `git rev-parse --git-path info/exclude`, without editing tracked `.gitignore` or untracking existing files. If this change already has tracked documents, flag the conflict before editing. Without Git, the spec can be agreed; execution will require a repository.

Use a concise Spanish structure:

```markdown
# Nombre del cambio
Estado: Borrador

## Objetivo y alcance
Resultado observable, comportamiento actual y cambio solicitado.
Fuera de alcance: extras que se excluyen.

## Comportamiento y aceptación
- AC-01: Dado ..., cuando ..., entonces ...
- AC-02: Error o límite relevante y resultado esperado.

## Decisiones y pendientes
Decisiones confirmadas, evidencia pertinente y preguntas materiales.

## Aprobación
Pendiente; registrar la aprobación real cuando exista.
```

Acceptance criteria (AC) describe observable outcomes, not "works", "secure", or implementation steps. Separate code facts, decisions, and unknowns; cite paths supporting material decisions.

Update the same document during the conversation. Do not create brainstorm, draft, research, or extra reports. Mark `Estado: Aprobado` only with real authorization; explicit user authorization covering this design requires no duplicate confirmation.

## Limits and Exit

- Do not read, migrate, move, or delete legacy workflow JSON, manuals, or history. Exclusively use the change directory.
- Do not create worktrees, switch branches, install dependencies, or edit code during this phase.
- If material decisions are missing, keep `Estado: Borrador` and ask. If approved, suggest `$speclet-plan` with the path, without auto-implementing.
- Translate data, error, concurrency, or retry risks into ACs when applicable; do not run general security/audit checklists.
