---
name: speclet-rules
description: Initialize or update repository rules and invariants in .speclet/rules.md. Inspects project stack and conventions to establish non-negotiable standards for database keys/indexes, Ponytail logic reuse, and architecture.
license: MIT
metadata:
  workflow: speclet
  phase: configuration
---

# Speclet Rules

Initialize or customize the project rules file (`.speclet/rules.md`) to establish persistent invariants for all subsequent Speclet phases (`speclet-draft`, `speclet-plan`, `speclet-loop`).

## Language and Communication Rules

- **Always speak, ask questions, and interact with the user in Spanish.**
- **Write `.speclet/rules.md` in Spanish.**
- Preserve standard technical terms in English ("log", "health", "endpoint", "middleware", "worktree", "payload", "token", etc.).

## 1. Inspect Existing State

1. Check if `.speclet/rules.md`, `rules.md`, or `.speclet/constitution.md` already exists.
2. If it exists, read it and summarize current rules. Ask the user whether to update, append, or replace specific sections.
3. If it does not exist, inspect the repository:
   - Language and runtime (Node, TypeScript, Python, Go, Rust, etc.).
   - Database / ORM / data layer (PostgreSQL, MySQL, SQLite, Prisma, Drizzle, SQLAlchemy, etc.).
   - Existing helper/utility structure (`utils/`, `helpers/`, `services/`, `lib/`).
   - Testing framework and linting/formatting tools.

## 2. Clarify Key Decisions (Short Round)

If the project stack leaves open choices, ask 1 to 2 concise multiple-choice questions in Spanish using `ask_question`:
- **Database & Keys:** E.g., UUIDv7 vs auto-incremental integers, soft-delete vs hard-delete.
- **Helper & Reuse Policy:** E.g., where shared helpers should live, naming conventions.
- **Architecture / API:** E.g., response envelope format, logging standards.

If conventions are already obvious from the codebase or template, propose them directly without unnecessary questions.

## 3. Generate `.speclet/rules.md`

Ensure directory `.speclet/` exists. Write `.speclet/rules.md` containing:

```markdown
# Reglas del Proyecto (rules.md)

Este archivo define las reglas arquitectónicas, de modelado de datos y convenciones de código **no negociables** para este repositorio.
Los agentes y desarrolladores deben consultar y respetar estas directrices en `speclet-draft`, `speclet-plan` y `speclet-loop`.

## 1. Código y Reutilización (Ponytail & readable-code)
- No duplicar lógica: antes de escribir una función nueva, verificar si ya existe un helper o servicio equivalente.
- Extraer helpers limpios y testeables solo si un patrón se usa en más de un lugar; no crear micro-wrappers innecesarios.
- Flujo lineal (Human-First): código de arriba a abajo con guard clauses y early returns; prohibido el troceado artificial por métricas de complejidad ciclomática.
- Simplicidad y tipado estricto sin sobreingeniería.

## 2. Arquitectura de Carpetas (Brownfield-First & Anti-Flat-Dumping)
- En proyectos existentes (Brownfield), respetar estrictamente las carpetas y convenciones actuales del repo.
- En código nuevo (Greenfield), prohibido el flat dumping: separar capas en `routes/`, `services/`, `db/models/`, `utils/`, `tests/`.

## 3. Base de Datos y Persistencia
- Primary Keys (PK) consistentes e inmutables.
- Foreign Keys (FK) explícitas con restricciones de integridad referencial.
- Índices obligatorios en columnas FK, campos de búsqueda frecuente y filtros WHERE habituales.
- Operaciones multitabla siempre dentro de transacciones atómicas.

## 4. APIs, Seguridad y Observabilidad
- Formato uniforme de respuestas y códigos HTTP semánticos.
- Prohibido loguear contraseñas, tokens JWT o credenciales sensibles.
- Health checks funcionales y estructuración de logs.

## 5. Testing y Calidad
- Pruebas antes de commits (TDD / evidencia real comprobada).
```

## 4. Output

Confirm creation or update in Spanish with a clickable link to `[rules.md](file:///.speclet/rules.md)`. Explain that `speclet-draft`, `speclet-plan`, and `speclet-loop` will now automatically honor these invariants.
