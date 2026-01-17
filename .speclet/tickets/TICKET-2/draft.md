# Draft: Ticket-aware consolidate paths

**Status:** Defined  
**Date:** 2026-01-17  
**Branch:** fix/consolidate-ticket-paths  
**Ticket:** TICKET-2

---

## User Description

> Make `speclet-consolidate` work in ticket workflows where drafts live under `.speclet/tickets/TICKET-N/`.

---

## Clarifying Questions

1. How should the consolidate skill locate the draft when `activeTicket` is used?
   A. Require `--target-draft` and document it ⭐ Recommended — explicit and low magic
   B. Auto-detect `activeTicket` from config and derive the path
   C. Support both (auto-detect if config exists, otherwise require `--target-draft`)

   **Answer:** C (assumed)

2. Should the consolidate skill update ticket-local artifacts (e.g., `tickets/TICKET-N/draft.md`), or continue writing to root `.speclet/draft.md`?
   A. Update ticket-local draft when activeTicket is set ⭐ Recommended — consistent with ticket workflow
   B. Always update root draft

   **Answer:** A (assumed)

---

## Proposed Scope

### Included

- Update consolidate instructions to handle ticket paths via `--target-draft` or `activeTicket` pathing.
- Document expected behavior in `.speclet/GUIDE.md`.

### Non-Goals (Out of Scope)

- Changing the speclet-council output format.
- Adding new config fields beyond `activeTicket`.

---

## Files to Modify

| File | Changes | Complexity |
| ---- | ------- | ---------- |
| `.opencode/skill/speclet-consolidate/SKILL.md` | Document ticket-aware pathing | 🟡 |
| `.speclet/GUIDE.md` | Add ticket-path guidance for consolidate | 🟡 |

---

## Stories (Draft)

1. **STORY-1: Ticket-aware consolidate guidance** — Document how consolidate resolves draft paths in ticket workflows (auto-detect `activeTicket` when available; otherwise require `--target-draft`).

---

## Pending Questions

1. Confirm whether auto-detect of `activeTicket` is allowed, or require `--target-draft` always.
