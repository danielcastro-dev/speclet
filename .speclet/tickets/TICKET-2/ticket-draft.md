# Ticket Draft: Consolidate path handling for ticket workflows

**Source:** `.speclet/draft.review.md` (Opus medium issue)

## Context

Opus flagged that `speclet-consolidate` assumes `.speclet/draft.md`, but ticket workflows move artifacts to `.speclet/tickets/TICKET-N/`. This can break consolidation when `activeTicket` is used.

## Proposed Outcome

- Consolidate skill should work with ticket-based paths or require `--target-draft` in ticket mode.
- Documentation should clarify the expected behavior.

## Acceptance Ideas

- Works with `activeTicket` workflow.
- Does not break non-ticket workflow.
