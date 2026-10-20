---
name: speclet-archive
description: Archive an implemented Speclet change, retaining its Markdown artifacts and optional manual-review record; never auto-review.
license: MIT
metadata:
  workflow: speclet
  phase: cleanup
---

# Speclet Archive

Archive finished Speclet changes to keep `.speclet/changes/` clean while preserving historical specifications and evidence.

## Language and Communication Rules

- **Always speak, ask questions, and interact with the user in Spanish.**
- **Write archive index entries and messages in Spanish.**
- Preserve standard technical terms in English ("log", "health", "commit", "archive", "diff", etc.).

## 1. Input and Target Resolution

1. Look in `.speclet/changes/<name>/`. If a specific change path is provided, use it. Otherwise, look for changes where `tasks.md` has `Estado: Implementado` (or legacy `Estado: Terminado`).
2. If multiple completed changes exist, list them and ask the user in Spanish to pick.
3. If a change is still `Estado: Pendiente` or in progress, warn the user and do not archive unless explicitly requested ("forzar archivo").
4. Read any `## Revisión manual` record in `tasks.md`. If missing, pending, failed or stale relative to the reviewed HEAD, warn explicitly. **Review is advisory, not an archive prerequisite. Never invoke `$speclet-review` or spawn a reviewer automatically.**

## 2. Archiving Process

1. Determine the archive destination folder:
   `.speclet/archive/YYYY-MM-<name>/` (using current year and month, e.g., `.speclet/archive/2026-10-auth-jwt/`).
2. If the destination directory does not exist, create it.
3. Move `spec.md`, `plan.md`, and `tasks.md` (preserving any manual-review metadata within `tasks.md`) from `.speclet/changes/<name>/` to the archive directory.
4. If `.speclet/changes/<name>/` is now empty, remove the empty directory.
5. Update or create `.speclet/archive/INDEX.md` with a clean Markdown table / list entry:
   - Date: `YYYY-MM-DD`
   - Change: `<name>`
   - Summary: Brief objective extracted from `spec.md`
   - Commits: List of commit SHAs from `tasks.md`
   - Path: `[<name>](./YYYY-MM-<name>/)`

## 3. Output

Confirm to the user in Spanish that the change has been archived cleanly, display the destination and whether a current manual review exists, without inventing approval. Confirm that `.speclet/changes/` is ready for the next task.
