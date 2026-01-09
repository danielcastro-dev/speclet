# Speclet

Lightweight spec-driven development workflow for LLM-assisted coding sessions.

## What is Speclet?

Speclet is a structured workflow for developing features with AI assistants (Claude, GPT, etc.). It provides:

- **Phased approach**: Draft (markdown) → Spec (JSON) → Implementation → Archive
- **Tiered complexity**: Scale documentation based on task size
- **Context persistence**: Decisions and patterns survive across sessions
- **Atomic commits**: 1 story = 1 commit
- **Trackable progress**: JSON specs with `passes: true/false` for each story

## Quick Start

### Installation

```bash
# Clone the templates
git clone https://github.com/danielcastro-dev/speclet.git /tmp/speclet

# Copy to your project
mkdir -p .speclet/templates .speclet/tickets .speclet/archive
cp /tmp/speclet/GUIDE.md .speclet/
cp /tmp/speclet/loop.md .speclet/
cp /tmp/speclet/templates/* .speclet/templates/

# Install skills (OpenCode format)
mkdir -p .opencode/skill
cp -r /tmp/speclet/skills/* .opencode/skill/

# Add to .gitignore (optional)
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
├── .opencode/skill/          # OpenCode skills location
│   ├── speclet-draft/SKILL.md
│   ├── speclet-spec/SKILL.md
│   └── speclet-loop/SKILL.md
├── .speclet/
│   ├── GUIDE.md              # LLM instructions (permanent)
│   ├── DECISIONS.md          # Architecture decisions (permanent)
│   ├── loop.md               # Manual loop instructions
│   ├── templates/            # Templates for docs
│   │   ├── draft.md
│   │   ├── spec.json
│   │   ├── spec-lite.json
│   │   ├── progress.md
│   │   └── ticket.md
│   ├── tickets/              # Backlog
│   └── archive/              # Completed specs
└── ... your code
```

## Usage

### Using Skills (Recommended)

Speclet provides three skills compatible with OpenCode and Claude:

| Skill | Command | Purpose |
|-------|---------|---------|
| **speclet-draft** | `Use the speclet-draft skill for [feature]` | Generate draft.md with clarifying questions |
| **speclet-spec** | `Use the speclet-spec skill` | Convert draft to spec.json |
| **speclet-loop** | `Use the speclet-loop skill` | Implement one story autonomously |

#### Complete Workflow with Skills

```
# Step 1: Create draft with clarifying questions
Use the speclet-draft skill for "add user authentication"

# Step 2: Convert to executable spec
Use the speclet-spec skill

# Step 3: Implement (repeat until COMPLETE)
Use the speclet-loop skill
```

#### Installing Skills

Skills use OpenCode/Claude compatible format (`SKILL.md` with frontmatter).

```bash
# Option 1: Copy to project (OpenCode)
mkdir -p .opencode/skill
cp -r /tmp/speclet/skills/* .opencode/skill/

# Option 2: Copy to global config (OpenCode)
cp -r /tmp/speclet/skills/* ~/.config/opencode/skill/

# Option 3: Claude compatible
mkdir -p .claude/skills
cp -r /tmp/speclet/skills/* .claude/skills/
```

### Manual Mode (without skills)

#### Starting a New Session

Tell your LLM:

```
Read .speclet/GUIDE.md

Context: [describe your problem in 1-2 sentences]

Let's start with Phase 0.
```

### Autonomous Loop Mode

Once you have a `spec.json`, you can run Speclet in autonomous loop mode:

```
Read .speclet/loop.md and execute one iteration.
```

Keep sending the same prompt until you see `✅ COMPLETE`. Each iteration:
1. Picks the highest priority story where `passes: false`
2. Implements it
3. Runs quality checks
4. Commits and updates `passes: true`
5. Appends to progress.md

This is inspired by [snarktank/ralph](https://github.com/snarktank/ralph) autonomous agent pattern.

### Continuing a Session

```
Read .speclet/GUIDE.md, spec.json and progress.md

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
| **1: Draft** | Clarify requirements | `draft.md` (markdown) |
| **2: Spec** | Detailed plan with stories | `spec.json` (JSON) |
| **3: Implementation** | Code + atomic commits | `progress.md` |
| **4: Close** | Document decisions | `DECISIONS.md` |

## Tiers (Complexity Scaling)

| Tier | Time | Documentation | Example |
|------|------|---------------|---------|
| **1** | < 15 min | Commit only | Fix typo, add field |
| **2** | 15-60 min | spec-lite.json | Bug fix, small feature |
| **3** | > 1 hour | Full flow | Multi-story feature |

## Key Concepts

### Hybrid Format: Markdown + JSON

| Phase | Format | Why |
|-------|--------|-----|
| **Draft** | Markdown | Human collaboration, Q&A, legible |
| **Spec** | JSON | Execution tracking, parseable, `passes: true/false` |
| **Progress** | Markdown | Learnings, context for future sessions |

### spec.json Structure

```json
{
  "feature": "Task Priority System",
  "branch": "feature/task-priority",
  "date": "2024-01-15",
  "summary": "Add priority levels to tasks",
  "nonGoals": ["No priority-based notifications"],
  "functionalRequirements": [
    "FR-1: Add priority field to tasks table",
    "FR-2: Display priority badge on task cards"
  ],
  "stories": [
    {
      "id": "STORY-1",
      "title": "Add priority field to database",
      "description": "Add priority column with default 'medium'",
      "files": ["migrations/001_add_priority.sql"],
      "acceptanceCriteria": [
        "Column created with enum: high, medium, low",
        "Default is 'medium'",
        "Build/typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### Lettered Questions for Fast Clarification

During the draft phase, ask questions with lettered options:

```
1. What is the primary goal?
   A. Improve user experience
   B. Fix existing bug
   C. Add new functionality
   D. Other: ___

2. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
```

Users respond quickly: **"1C, 2A"**

### Story Sizing Rule

**If you cannot describe the change in 2-3 sentences, it's too big. Split it.**

✅ **Right-sized:**
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic

❌ **Too big (split these):**
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### Story Order: Dependencies First

1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views

### Verifiable Acceptance Criteria

Each criterion must be checkable, not vague.

✅ **Good:** "Filter dropdown has options: All, Active, Completed"  
❌ **Bad:** "Works correctly", "Good UX"

**Always include:**
- `Build/typecheck passes` (every story)
- `Verify in browser` (UI stories)

### Non-Goals Section

Every spec must define what it will NOT do. Critical for preventing scope creep.

### Tracking Progress

After completing each story, update spec.json:
```json
{
  "id": "STORY-1",
  "passes": true,  // ← Update this
  "notes": "Used existing Badge component"  // ← Optional learnings
}
```

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
Completed specs moved here: `archive/2024-01-15-feature-name/`

## Golden Rules

### ✅ DO
- Atomic commits (1 story = 1 commit)
- Build before push
- Push immediately
- Update `passes: true` after each story
- Document architectural decisions
- Size stories correctly (2-3 sentences max)
- Use lettered options for questions

### ❌ DON'T
- Commit `.speclet/` files (add to .gitignore)
- Refactor while fixing bugs
- Implement without confirming understanding
- Ignore build errors
- Use vague acceptance criteria ("works correctly")

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
- **[Ralph pattern](https://ghuntley.com/ralph/)**: Story sizing, JSON tracking, verifiable criteria

The key insight: **LLMs work better with structured context**. Speclet provides that structure while staying lightweight.

## License

MIT
