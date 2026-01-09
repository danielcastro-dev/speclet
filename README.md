# Speclet

Lightweight spec-driven development workflow for LLM-assisted coding sessions.

## What is Speclet?

Speclet is a structured workflow for developing features with AI assistants (Claude, GPT, etc.). It provides:

- **Phased approach**: Draft → Spec → Implementation → Archive
- **Tiered complexity**: Scale documentation based on task size
- **Context persistence**: Decisions and patterns survive across sessions
- **Atomic commits**: 1 story = 1 commit

## Quick Start

### Installation

```bash
# Clone the templates
git clone https://github.com/danielcastro-dev/speclet.git /tmp/speclet

# Copy to your project
mkdir -p .speclet
cp /tmp/speclet/GUIDE.md .speclet/
cp -r /tmp/speclet/templates .speclet/

# Add to .gitignore (optional - keeps planning files out of repo)
echo ".speclet/" >> .gitignore
# OR keep only DECISIONS.md tracked
echo ".speclet/*" >> .gitignore
echo "!.speclet/DECISIONS.md" >> .gitignore
```

### Manual Installation

1. Create `.speclet/` folder in your project root
2. Copy `GUIDE.md` into `.speclet/`
3. Copy `templates/` folder into `.speclet/`
4. Create `DECISIONS.md` from template

### Project Structure

```
your-project/
├── .speclet/
│   ├── GUIDE.md              # LLM instructions (permanent)
│   ├── DECISIONS.md          # Architecture decisions (permanent)
│   ├── templates/            # Templates for docs
│   │   ├── draft.md
│   │   ├── spec.md
│   │   ├── spec-lite.md
│   │   ├── progress.md
│   │   └── ticket.md
│   ├── tickets/              # Backlog (create as needed)
│   └── archive/              # Completed specs (create as needed)
└── ... your code
```

## Usage

### Starting a New Session

Tell your LLM:

```
Read .speclet/GUIDE.md

Context: [describe your problem in 1-2 sentences]

Let's start with Phase 0.
```

### Continuing a Session

```
Read .speclet/GUIDE.md, spec.md and progress.md

Continue where we left off.
```

### Working on a Ticket

```
Read .speclet/tickets/TICKET-XXX.md

Implement this ticket.
```

## Workflow Phases

| Phase | Purpose | Artifact |
|-------|---------|----------|
| **0: Bootstrap** | Setup branch, verify build | - |
| **1: Draft** | Clarify requirements | `draft.md` |
| **2: Spec** | Detailed plan with stories | `spec.md` |
| **3: Implementation** | Code + atomic commits | `progress.md` |
| **4: Close** | Document decisions | `DECISIONS.md` |

## Tiers (Complexity Scaling)

| Tier | Time | Documentation | Example |
|------|------|---------------|---------|
| **1** | < 15 min | Commit only | Fix typo, add field |
| **2** | 15-60 min | Spec Lite | Bug fix, small feature |
| **3** | > 1 hour | Full flow | Multi-story feature |

## Key Files

### `GUIDE.md` (Permanent)
Complete LLM instructions including:
- Workflow by phases
- Templates for all documents
- Golden rules and anti-patterns
- Decision documentation criteria

### `DECISIONS.md` (Permanent)
Architectural decisions that affect future code:
```markdown
## 2024-01-15: Use Fuse.js for fuzzy search

- **Decision:** Use Fuse.js with threshold 0.4
- **Context:** Need fuzzy search, threshold 0.3 too strict, 0.5 too permissive
- **Alternatives discarded:** Exact search, Algolia (overkill)
- **Applies to:** Any future search implementations
```

### `tickets/` (Backlog)
Bugs and features waiting to be worked on. Use `templates/ticket.md`.

### `archive/` (History)
Completed specs moved here with date prefix: `2024-01-15-feature-name.md`

## Golden Rules

### ✅ DO
- Atomic commits (1 story = 1 commit)
- Build before push
- Push immediately
- Document architectural decisions

### ❌ DON'T
- Commit `.speclet/` files (add to .gitignore)
- Refactor while fixing bugs
- Implement without confirming understanding
- Ignore build errors

## Success Metrics

| Metric | Target |
|--------|--------|
| Broken builds | 0 |
| Reverts | 0 |
| Commits/hour | 3-4 |
| Questions/story | ≤2 |

## Customization

### Keep Decisions in Git

If you want `DECISIONS.md` version-controlled:

```bash
echo ".speclet/*" >> .gitignore
echo "!.speclet/DECISIONS.md" >> .gitignore
```

### Different Folder Name

Replace `.speclet/` with your preferred name in `GUIDE.md` and update paths.

### Language

Templates are in English. Fork and translate as needed.

## Philosophy

Speclet is inspired by:
- **Spec-Driven Development**: Specification before code
- **BDD**: Acceptance criteria, Gherkin-style scenarios
- **ADR (Architecture Decision Records)**: Documenting decisions
- **Session-based workflows**: Optimized for LLM context windows

The key insight: **LLMs work better with structured context**. Speclet provides that structure while staying lightweight.

## License

MIT
