---
name: readable-code
description: Enforce human-first readable code, linear top-to-bottom flow, guard clauses, deep cohesive functions (preventing cyclomatic over-fragmentation), and structured folder architecture (anti-flat-dumping, brownfield-friendly).
license: MIT
metadata:
  workflow: engineering-standard
  focus: code-quality
---

# Readable Code (Human-First & Linear Code)

Prioritize **human comprehension and cognitive ergonomics over dogmatic metrics**. Code is read 10x more often than written; optimizing blindly for low cyclomatic complexity scores often destroys real-world readability.

## Language and Communication Rules

- **Always speak, explain, and interact with the user in Spanish.**
- **Code comments, PR notes, and review findings in Spanish.**
- Preserve standard technical terms in English ("guard clause", "early return", "shallow function", "deep module", "flat dumping", "happy path", "diff", "runtime").

---

## 1. Linear Flow (Top-to-Bottom Execution)

Code should read like a straightforward sequential recipe from top to bottom:

- **Single-pass reading:** A developer should understand the function's intent without constantly jumping back and forth between obscure closures, callbacks, or unrelated files.
- **Explicit stages:** Structure execution in obvious phases:
  1. Validate preconditions & inputs.
  2. Retrieve & transform data.
  3. Execute core business action / side effect.
  4. Return result.
- Avoid hidden state mutations in secondary helper functions. Keep inputs explicit and return values predictable.

---

## 2. Guard Clauses & Early Returns (No Arrow Anti-Pattern)

Flatten nested conditionals by failing fast:

- **Bail out early:** Handle error conditions, invalid inputs, and boundary cases at the very beginning of the function using early returns or throws (`if (!valid) return;`).
- **Unnested happy path:** The primary business logic (happy path) must stay at the root indentation level, never trapped inside 3 or 4 levels of nested `if { if { ... } }`.
- **No unnecessary `else` after `return`:**
  ```typescript
  // Preferred
  if (!user) {
    throw new NotFoundError("Usuario no encontrado");
  }
  return user.profile;

  // Rejected (adds needless visual nesting)
  if (!user) {
    throw new NotFoundError("Usuario no encontrado");
  } else {
    return user.profile;
  }
  ```

---

## 3. Deep Functions over Shallow Wrappers (Anti-Cyclomatic Trap)

Do not artificially shred cohesive code just to appease cyclomatic complexity linters:

- **The Shallow Function Trap:** Slicing a clear 30-line function into 8 tiny one-line functions (`isHeaderMissing`, `checkToken`, `formatString`) does not reduce complexity—it merely **scatters cognitive load across the entire codebase**.
- **Cohesive & Deep:** Favor functions that perform meaningful work behind a clean interface. A 30-line function with clear guard clauses and linear steps is vastly superior to a web of micro-indirections.
- **When to extract a helper:**
  - Extract only when logic contains **reusable domain calculations, math, or transformations used in multiple places**.
  - Do NOT extract a helper to wrap a single `if`, a single `slice()`, or an obvious native call that is only used once.

---

## 4. Folder Architecture (Brownfield-First, Anti-Flat-Dumping)

Organize files with clear, predictable architectural homes:

### Brownfield Projects (Existing Repositories)
- **Golden Rule:** **Always inspect and mirror existing repository conventions.**
- Never introduce an arbitrary folder structure that conflicts with the established codebase (e.g., do not force `src/modules/` if the project uses `app/controllers/` and `app/models/`).
- Place new files in the corresponding existing directories where their peers live.

### Greenfield Projects & New Modules (Anti-Flat-Dumping)
- **Strictly prohibit Flat Dumping:** Never dump routes, database queries, business services, and utilities into a single flat directory or project root.
- Use clean, standard layers:
  - **Transport / Entry:** `routes/`, `controllers/`, `api/`, `cli/` (handles HTTP/CLI input and status codes).
  - **Business Logic:** `services/`, `domain/` (pure business rules and transaction orchestration).
  - **Data Access:** `db/`, `models/`, `repositories/` (schemas, migrations, queries with required indexes).
  - **Shared Utilities:** `utils/`, `helpers/` (pure, tested, reusable functions).
  - **Tests:** `tests/` (mirroring structure) or colocated (`*.test.ts`).

---

## Review & Audit Checklist

Before accepting code or during review, verify:

1. **Can a developer follow this logic linearly in under 30 seconds?**
2. **Are error cases handled at the top with guard clauses?**
3. **Did we avoid shallow one-line helper functions created solely for complexity metrics?**
4. **Are files placed in meaningful semantic directories instead of a flat dump?**
