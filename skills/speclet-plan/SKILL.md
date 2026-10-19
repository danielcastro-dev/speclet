---
name: speclet-plan
description: Convert an approved Speclet spec.md into a minimal technical plan and verifiable Markdown tasks. Use after agreeing on requirements; does not implement code or create JSON or manuals.
license: MIT
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Plan

Decide **how to build the change** and break it into executable tasks without inventing requirements.

## Language and Communication Rules

- **Always speak, ask questions, and interact with the user in Spanish.**
- **Write `plan.md` and `tasks.md` in Spanish.**
- Preserve standard technical terms in English ("log", "health", "endpoint", "middleware", "worktree", "payload", "token", "gate", "diff", etc.). Do not translate technical jargon awkwardly.

## Input and Approach

Resolve `.speclet/changes/<name>/spec.md` from the given path. If no path is given, select the single approved spec whose change is not finished; if multiple exist, ask the user. Do not select status from the previous workflow.

Read the spec, applicable instructions, implementations, consumers, tests, and actual commands. Check for the project rules (`.speclet/rules.md`, `rules.md`, or `.speclet/constitution.md`). Strictly adhere to its rules: verify that the planned approach reuses existing code instead of duplicating logic (extract shared helpers when appropriate), respect database schema invariants (primary keys, foreign keys, required indexes), and maintain architectural contracts.

Load `ponytail` and `caveman` from their installed entrypoints: simplicity for approach, conciseness only for Spanish chat. Borrowed activation ends upon exiting Speclet, without turning off any mode previously activated by the user. Do not abbreviate documents or questions.

If spec approval is missing, resolve it via `$speclet-draft` without assuming it. Reuse authorized decisions and ask only about new material dilemmas. Research externally when necessary information is missing or requested.

## Technical Plan

Write `plan.md` alongside the spec, without repeating its acceptance criteria:

```markdown
# Plan técnico
Spec: spec.md
Estado: Propuesto

## Enfoque y decisiones
Implementación mínima, reutilización y contratos afectados.

## Ejecución
Repositorio(s), base/rama conocida y worktree propuesto, sujeto a consulta.
Documentos Speclet locales; código y pruebas en commits por tarea.

## Verificación y riesgos
Comandos encontrados y comportamiento que validan; límites del entorno.
Riesgos pertinentes y mitigación; basal pendiente hasta ejecutarlo realmente.

## Focos de revisión y casos límite
Puntos críticos de inspección, casos límite (entradas vacías/extremas, fallos de borde o condiciones de error); cada uno vinculado obligatoriamente a tareas con tests en tasks.md.

## Aprobación
Autorización real existente o decisiones pendientes antes de ejecutar.
```

Specify signatures, schemas, or sequences where coordination requires it. Do not create abstractions, dependencies, or options for hypothetical future needs. Define required failure contracts within the plan and AC, without separate manuals.

Do not install packages, create worktrees, edit code, or mutate services during planning. Run read-only checks only if they resolve an uncertainty; record only real evidence.

## Executable Tasks

Write `tasks.md` with overall status `Pendiente` and an ordered dependency list. Each task produces a testable behavior or contract:

```markdown
# Tareas
Estado: Pendiente
Tarea activa: ninguna

- [ ] T01 — Resultado concreto
  - Depende de: ninguna
  - Aceptación: AC-01 de spec.md / Foco o caso límite de plan.md
  - Archivos: rutas reales afectadas
  - Verificación: comando y resultado observable esperado
  - Evidencia, revisión y commit: pendientes
```

- Every AC and every focus point/edge case must be covered by a task and verified with tests. Document unverifiable boundaries before execution without promising fictitious coverage.
- Include tests alongside the change; not tests that merely mirror implementation or prove that code executed.
- A consumer task must know the contracts produced by its dependency when multiple interpretations are possible.
- Dependencies and list order suffice: do not impose priorities, quality budgets, sessions, catalogs, or JSON status.
- If updating an in-progress plan, preserve completed tasks and their evidence. A material change in scope requires approval before execution.
- Keep the three local Markdown files excluded via the Git exclude established by draft. Do not create separate baseline, progress, reviews, diary, or handoff files.

## Output

Provide clickable links to the plan/tasks and outline any pending decisions. An explicit user request to run `$speclet-loop` on a complete plan authorizes it, without requiring redundant confirmation. Creating or switching worktrees still requires the separate consultation in loop.

Do not create a fourth design document: requirements in spec, approach in plan, progress/evidence in tasks. Do not read, migrate, or delete project files from the legacy workflow.
