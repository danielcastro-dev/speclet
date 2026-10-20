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
