---
name: speclet-jira
description: Prepare concise Jira stories or completion messages from a request or Speclet Markdown change, only when requested. Does not implement code or automatically publish to Jira.
license: MIT
metadata:
  workflow: speclet
  phase: optional-handoff
---

# Speclet Jira

Draft a clear user story or communicate completion results with verifiable evidence. This step is entirely optional: Speclet Loop does not generate Jira handoffs by default.

## Language and Communication Rules

- **Always speak, ask questions, and interact with the user in Spanish.**
- **Write Jira stories, summaries, and completion messages in Spanish.**
- Preserve standard technical terms in English ("log", "health", "endpoint", "middleware", "token", "payload", "pipeline", etc.). Do not translate technical jargon awkwardly.

## Input

- Use the user request and specified change path. Read `spec.md` and only the necessary parts of `plan.md` and `tasks.md`.
- If multiple candidate changes exist, ask the user to pick one. Without Speclet context, draft the story directly from the request without forcing the workflow to initialize.
- Load `caveman` to keep Spanish chat concise. Borrowed activation ends upon exiting Speclet; respect any mode previously activated by the user. Draft tickets and questions in natural language.
- Ask only for information that changes the recipient, scope, or acceptance criteria. Do not force an interview, Jira key, or frontend/backend split when unnecessary.

## Story or Completion Message

For a new story: concrete title, problem/desired outcome, scope, and observable criteria. Split frontend/backend only when independent deliverables exist. Do not copy internal planning details that do not benefit the reader.

For a completion handoff: implemented behavior, executed tests, commit list, and genuine pending items. Distinguish completed, blocked, and unverified work. Verify evidence; a checked box does not prove that a test passed.

## Output and Boundaries

Deliver text in chat by default. Write to a file only when an explicit path is requested. Do not create handoff directories, MR messages, or extra reports automatically.

Drafting does not authorize publishing. Use tools to create or update tickets only when the user explicitly requests it and the destination is clear. Never post secrets or sensitive operational data.

Do not read, convert, move, or delete documents from legacy workflows.
