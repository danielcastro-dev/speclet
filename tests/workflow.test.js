const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const read = file => fs.readFileSync(path.join(__dirname, '..', file), 'utf8');

test('loop verifies tasks but never launches automatic reviewers', () => {
  const value = read('skills/speclet-loop/SKILL.md');
  assert.match(value, /Never launch a reviewer/);
  assert.match(value, /Do not spawn subagents automatically/);
  assert.match(value, /task's required verification passes/);
  assert.match(value, /Estado: Implementado/);
  assert.doesNotMatch(value, /After verifying each task, request \*\*an independent review\*\*/);
  assert.doesNotMatch(value, /If independent review is unavailable, declare the limitation and halt/);
});
test('review is user invoked, holistic, economical and non-mutating', () => {
  const value = read('skills/speclet-review/SKILL.md');
  assert.match(value, /explicitly invokes/);
  assert.match(value, /combined diff/);
  assert.match(value, /one read-only independent subagent/);
  assert.match(value, /Revisión en sesión; no independiente/);
  assert.match(value, /No verificado/);
  assert.match(value, /Do not modify source/);
});
test('archive supports implemented state and no review', () => {
  const value = read('skills/speclet-archive/SKILL.md');
  assert.match(value, /Estado: Implementado/);
  assert.match(value, /not an archive prerequisite/);
  assert.match(value, /Never invoke.*speclet-review/);
});
test('skill is present in distribution and catalog', () => {
  assert.match(read('bin/cli.js'), /speclet-review/);
  assert.match(read('README.md'), /speclet-review/);
  assert.match(read('skills/speclet-review/agents/openai.yaml'), /\$speclet-review/);
});
test('readable-code enforces linear flow, guard clauses and brownfield folder architecture', () => {
  const value = read('skills/readable-code/SKILL.md');
  assert.match(value, /Guard Clauses/);
  assert.match(value, /Linear Flow/);
  assert.match(value, /Brownfield Projects/);
  assert.match(value, /Anti-Flat-Dumping/);
  assert.match(read('bin/cli.js'), /readable-code/);
  assert.match(read('README.md'), /readable-code/);
});
test('pr formats PRs with /pr structure, explicit base branch, and supports github and gitlab', () => {
  const value = read('skills/pr/SKILL.md');
  assert.match(value, /Summary/);
  assert.match(value, /Evidence/);
  assert.match(value, /Merge Danger/);
  assert.match(value, /gh pr create --base/);
  assert.match(value, /glab mr create --target-branch/);
  assert.match(read('bin/cli.js'), /\bpr\b/);
  assert.match(read('README.md'), /\/pr\b/);
});
test('merge-risk evaluates PR merge risk across 5 weighted dimensions', () => {
  const value = read('skills/merge-risk/SKILL.md');
  assert.match(value, /Alignment/);
  assert.match(value, /Impact & Blast Radius/);
  assert.match(value, /Verification/);
  assert.match(value, /Rollback Cost/);
  assert.match(value, /Error Detection/);
  assert.match(value, /Score = Σ\(veredicto × peso\)/);
  assert.match(read('bin/cli.js'), /merge-risk/);
  assert.match(read('README.md'), /merge-risk/);
});
test('handoff creates portable transition document in temp directory without workspace pollution', () => {
  const value = read('skills/handoff/SKILL.md');
  assert.match(value, /handoff/);
  assert.match(value, /\$TMPDIR/);
  assert.match(value, /Suggested skills/);
  assert.match(read('bin/cli.js'), /handoff/);
  assert.match(read('README.md'), /handoff/);
  assert.match(read('skills/handoff/agents/openai.yaml'), /display_name: "Handoff"/);
});
test('retro evaluates session friction to propose automated checks and guardrails', () => {
  const value = read('skills/retro/SKILL.md');
  assert.match(value, /Automated checks/);
  assert.match(value, /Navigation pointers/);
  assert.match(value, /Coding standards/);
  assert.match(value, /No-ops/);
  assert.match(read('bin/cli.js'), /retro/);
  assert.match(read('README.md'), /retro/);
  assert.match(read('skills/retro/agents/openai.yaml'), /display_name: "Retro"/);
});
