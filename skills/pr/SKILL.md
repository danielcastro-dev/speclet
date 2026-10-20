---
name: pr
description: Prepare and open human-readable Pull Requests (or GitLab MRs) using the /pr format (Visual Summary, Real Evidence, Merge Danger & Team Alerts). Anti-AI-slop, compatible with GitHub (gh) and GitLab (glab).
license: MIT
metadata:
  workflow: delivery
  phase: pull-request
---

# PR (`/pr`)

Create human-centric, high-signal Pull Requests (GitHub) or Merge Requests (GitLab) based on the **`/pr` format** (inspired by Matt Pocock and modern engineering blogs). Designed for fast reviews in small teams without corporate bloat, file dumps, or AI slop.

## Language and Communication Rules

- **Always speak, explain, and interact with the user in Spanish.**
- **Write PR/MR titles and descriptions in Spanish** (or the team's language convention).
- Preserve standard technical terms in English ("guard clause", "early return", "diff", "blast radius", "two-way door", "one-way door", "endpoint", "payload").

---

## The `/pr` Philosophy

1. **Writing code got cheap, reading it did not:** Teammates review 5-10 PRs a day. If they cannot understand the change and verify safety in 30 seconds, review latency kills team velocity.
2. **No AI Slop:** Never write filler like *"This pull request introduces comprehensive architectural enhancements..."*. Prohibit buzzwords (*delve, pivotal, seamless, tapestry*).
3. **No File Dumping:** Do not list every modified file; the platform already provides the *Files Changed* tab. Summarize **intent and behavior**.

---

## 1. Context Gathering

1. **Verify Branch:** Ensure you are on a feature branch, not directly on `main` or `master`.
2. **Determine Target Base Branch:**
   - Detect the base branch this feature branched from (check `plan.md`, git tracking branch, or default branch via `git remote show origin | grep 'HEAD branch'`).
   - If not obvious, ask or confirm with the user.
   - **Crucial:** Always carry this target `<base-branch>` forward so the PR is opened against the intended branch instead of blindly defaulting to the repo's main branch.
3. **Detect Forge (GitHub vs GitLab):**
   - Check remote URL: `git config --get remote.origin.url`
   - Detect if the repository is on GitHub (`github.com`) or GitLab (`gitlab.com` or custom self-hosted GitLab).
4. **Read Speclet Artifacts (if available):**
   - Extract intent and user problem from `spec.md`.
   - Extract executed test commands, exit codes, and commit SHAs from `tasks.md`.
5. **Inspect Git Diff:**
   - Run `git log <base-branch>..HEAD --oneline` to see branch commits.
   - Run `git diff <base-branch>...HEAD --stat` to grasp scope.

---

## 2. The `/pr` Structure

Generate the PR/MR description using these three mandatory sections:

```markdown
## 1. Summary
[1-2 sentences on what problem this solves + the smallest visual representation: 
a compact ASCII flow, component tree, or 2-3 bullets of intent. NO file lists.]

## 2. Evidence
[Irrefutable proof of working code: 
exact test command and exit code 0, console output of passing test, or curl response.]

## 3. Merge Danger & Notas para el equipo
- **Puerta:** Two-Way Door (fácil de revertir con git revert) o One-Way Door (migración de BD, cambio de contrato público).
- **Blast Radius:** Qué parte del sistema podría verse afectada si algo falla.
- **Notas de entorno local:** Advertir explícitamente si requiere `npm install`, nuevas variables en `.env`, o correr migraciones (`npm run db:migrate`).
```

---

## 3. Execution & Opening PR/MR

1. **Verify Working Tree:** Ensure all intended files are committed and tests are green.
2. **Push Branch:**
   ```bash
   git push -u origin <current-branch>
   ```
3. **Open PR/MR with the detected Forge CLI passing the base branch explicitly:**
   - **For GitHub (`gh` CLI):**
     ```bash
     gh pr create --base "<base-branch>" --title "<type>(<scope>): <concise description>" --body "<body>"
     ```
   - **For GitLab (`glab` CLI):**
     ```bash
     glab mr create --target-branch "<base-branch>" --title "<type>(<scope>): <concise description>" --description "<body>" --remove-source-branch
     ```
   - If CLI is not authenticated or unavailable, output the complete markdown ready to paste along with the direct URL printed by Git during push.
4. **Output:** Provide the clickable URL to the opened Pull/Merge Request in the chat.
