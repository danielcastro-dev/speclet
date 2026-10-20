#!/usr/bin/env node

/**
 * Speclet CLI - Herramienta de instalacion rapida de skills para agentes de IA
 * https://github.com/danielcastro-dev/speclet
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const SKILLS_DIR = path.join(__dirname, '..', 'skills');

const AGENT_PATHS = {
  codex: path.join(os.homedir(), '.codex', 'skills'),
  claude: path.join(os.homedir(), '.claude', 'skills'),
  antigravity: path.join(os.homedir(), '.gemini', 'config', 'skills'),
  project: path.join(process.cwd(), '.agents', 'skills')
};

const LLM_PROMPT = `Instala y configura las skills de Speclet en este entorno:

1. Ejecuta en terminal:
   npx -y skills add danielcastro-dev/speclet -g -y
   (o a nivel de proyecto: npx -y skills add danielcastro-dev/speclet -y)

2. Confirma las skills disponibles:
   - Speclet Core: speclet-rules, speclet-draft, speclet-plan, speclet-loop, speclet-review, speclet-archive, speclet-jira
   - Ingenieria independiente: systematic-debugging, test-driven-development, verification-before-completion, production-monitoring
   - Modos auxiliares: ponytail, caveman

3. Avisame cuando este listo para comenzar con $speclet-draft.`;

function getSkills() {
  if (!fs.existsSync(SKILLS_DIR)) return [];
  return fs.readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => {
      const skillName = dirent.name;
      const skillMd = path.join(SKILLS_DIR, skillName, 'SKILL.md');
      let description = '';
      if (fs.existsSync(skillMd)) {
        const content = fs.readFileSync(skillMd, 'utf8');
        const match = content.match(/description:\s*([^\n\r]+)/);
        if (match) description = match[1].replace(/^['"]|['"]$/g, '').trim();
      }
      return { name: skillName, description };
    });
}

function copyDirRecursive(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDirRecursive(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

function printBanner() {
  console.log(`
┌────────────────────────────────────────────────────────┐
│  Speclet - Skills de desarrollo guiado por specs       │
│  https://github.com/danielcastro-dev/speclet           │
└────────────────────────────────────────────────────────┘`);
}

function listSkills() {
  const skills = getSkills();
  console.log('\nSkills disponibles en el repositorio:\n');
  skills.forEach(s => {
    console.log(`  • \x1b[36m${s.name}\x1b[0m`);
    if (s.description) console.log(`    ${s.description}\n`);
  });
}

function installLocal(targetPath) {
  const skills = getSkills();
  console.log(`\nInstalando ${skills.length} skills en: ${targetPath}...`);
  fs.mkdirSync(targetPath, { recursive: true });
  for (const s of skills) {
    const src = path.join(SKILLS_DIR, s.name);
    const dest = path.join(targetPath, s.name);
    copyDirRecursive(src, dest);
    console.log(`  [OK] ${s.name}`);
  }
  console.log('\nInstalacion completada con exito.');
}

function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  printBanner();

  if (command === '--prompt' || command === 'prompt') {
    console.log('\nPrompt para LLM (copiar y pegar en tu agente):\n');
    console.log('──────────────────────────────────────────────────────');
    console.log(LLM_PROMPT);
    console.log('──────────────────────────────────────────────────────\n');
    return;
  }

  if (command === '--list' || command === 'list' || command === 'ls') {
    listSkills();
    return;
  }

  if (command === '--install' || command === 'install') {
    const target = args[1] || AGENT_PATHS.project;
    installLocal(target);
    return;
  }

  console.log(`
Uso:
  npx skills add danielcastro-dev/speclet       # Instalacion estandar via npx skills
  npx danielcastro-dev/speclet --prompt         # Muestra el prompt para que tu LLM lo instale
  npx danielcastro-dev/speclet --list           # Lista todas las skills disponibles
  npx danielcastro-dev/speclet --install        # Copia las skills en .agents/skills/ del proyecto
  npx danielcastro-dev/speclet --install <path> # Copia las skills en una ruta personalizada

Opciones de instalacion rapida:
  • Global con npx skills:
    npx -y skills add danielcastro-dev/speclet -g -y

  • Solo este proyecto:
    npx -y skills add danielcastro-dev/speclet -y
`);
}

main();
