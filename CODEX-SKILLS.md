# Codex Skills - Guía de Configuración

## Compatibilidad OpenAI Codex

Speclet ahora soporta **OpenAI Codex** además de OpenCode. Los skills se instalan automáticamente en ambas ubicaciones.

## Ubicaciones de Skills

### Local (Repositorio)
Cuando ejecutas el instalador, los skills se copian a:

```
tu-proyecto/
├── .opencode/skill/        # Para OpenCode
│   ├── speclet-draft/
│   ├── speclet-spec/
│   ├── speclet-council/
│   ├── speclet-ticket/
│   └── speclet-learn/
│
└── .codex/skills/          # Para OpenAI Codex
    ├── speclet-draft/
    ├── speclet-spec/
    ├── speclet-council/
    ├── speclet-ticket/
    └── speclet-learn/
```

**Cuándo se usan:**
- Cuando trabajas dentro del proyecto (`.opencode/skill/` y `.codex/skills/`)
- Disponibles para el repositorio y submódulos

### Global (Usuario)

Para instalar skills globalmente en tu usuario:

**Linux/macOS:**
```bash
# Copiar skills a ~/.codex/skills
cp -r .codex/skills/* ~/.codex/skills/
```

**Windows:**
```powershell
# Copiar skills a %USERPROFILE%\.codex\skills
Copy-Item -Path .\.codex\skills\* -Destination "$env:USERPROFILE\.codex\skills" -Recurse -Force
```

### Sistema (Admin)

Para instalar skills a nivel de sistema (requiere permisos de administrador):

**Linux/macOS:**
```bash
# Copiar skills a /etc/codex/skills (requiere sudo)
sudo cp -r .codex/skills/* /etc/codex/skills/
```

**Windows (Como Administrador):**
```powershell
# Copiar a C:\ProgramData\Codex\skills
Copy-Item -Path .\.codex\skills\* -Destination "C:\ProgramData\Codex\skills" -Recurse -Force
```

## Orden de Búsqueda de Skills

OpenAI Codex busca skills en este orden:

1. **Repositorio Local** (`$CWD/.codex/skills/`) ← **Donde Speclet instala**
2. **Directorio Padre** (`$CWD/../.codex/skills/`)
3. **Raíz del Repositorio** (`$REPO_ROOT/.codex/skills/`)
4. **Usuario** (`~/.codex/skills/`)
5. **Sistema** (`/etc/codex/skills/`)
6. **Builtin** (Incluidos con Codex)

## Estructura de un Skill Speclet

Cada skill tiene la siguiente estructura:

```
speclet-draft/
├── SKILL.md              # Metadata e instrucciones del skill
├── scripts/              # Scripts ejecutables (opcional)
└── references/           # Documentación (opcional)
```

### Formato del SKILL.md

```markdown
---
name: speclet-draft
description: Generate a structured draft for a feature with clarifying questions
metadata:
  short-description: Feature draft generator
---

## Purpose

Generate a comprehensive draft specification for a feature...

## How to Use

1. Describe the feature you want to implement
2. Clarifying questions will help refine the requirements
3. Output will be saved to .speclet/draft.md

## Instructions

[Instrucciones detalladas para el agente]
```

## Usando Skills con OpenAI Codex

### Invocación Explícita

En la terminal o IDE de Codex, usa:

```bash
# Usar un skill específico
$ /speclet-draft Feature: add user authentication

# O seleccionar de una lista
$ /skills
```

### Invocación Implícita

Codex puede decidir automáticamente usar un skill basado en el contexto:

```bash
$ Necesito crear un draft para una nueva API REST
# Codex usará automáticamente speclet-draft si es apropiado
```

### En VS Code

Si tienes Codex instalado en VS Code:

1. Abre el panel de Codex
2. Escribe `$` para ver skills disponibles
3. Selecciona `$speclet-draft` o similar
4. Describe tu tarea

## Configuración de Codex

### Habilitar/Deshabilitar Skills

Edita `~/.codex/config.toml`:

```toml
# Deshabilitar un skill sin borrarlo
[[skills.config]]
path = "/path/to/.codex/skills/speclet-draft"
enabled = false
```

Luego reinicia Codex.

### Orden de Prioridad

Para cambiar el orden en que aparecen en el selector:

```toml
[[skills.priority]]
path = "/path/to/.codex/skills/speclet-draft"
order = 1

[[skills.priority]]
path = "/path/to/.codex/skills/speclet-spec"
order = 2
```

## Diferencias: OpenCode vs Codex

| Característica | OpenCode | Codex |
|---|---|---|
| **Ubicación Local** | `.opencode/skill/` | `.codex/skills/` |
| **Ubicación Usuario** | `~/.config/opencode/agent/` | `~/.codex/skills/` |
| **Archivo Metadata** | `SKILL.md` (OpenCode format) | `SKILL.md` (Agent Skills spec) |
| **Modelos Soportados** | Configurable | GPT-4, etc. |
| **Invocación** | `/skill-name` | `/skill-name` o `$skill-name` |

## Instalación Manual en Codex

Si necesitas instalar skills manualmente:

**Paso 1: Crear directorio**
```bash
mkdir -p ~/.codex/skills
```

**Paso 2: Copiar skill**
```bash
cp -r speclet-draft ~/.codex/skills/
```

**Paso 3: Reiniciar Codex**
```bash
# El skill aparecerá después de reiniciar
codex restart
```

## Troubleshooting

### Skill no aparece en Codex

1. Verifica que exista `SKILL.md` en la carpeta del skill
2. Verifica que `SKILL.md` tenga `name` y `description`
3. Reinicia Codex: `codex restart`
4. Verifica en `~/.codex/config.log`

### Error de permiso en `.codex/skills`

```bash
# Asegurar permisos correctos
chmod -R 755 ~/.codex/skills
chmod 644 ~/.codex/skills/*/SKILL.md
```

### Skill aparece pero no funciona

1. Verifica que el archivo `SKILL.md` tenga sintaxis YAML válida
2. Verifica que las instrucciones sean claras
3. Revisa logs: `tail -f ~/.codex/logs/codex.log`

## Integración con CI/CD

Para instalar skills en tu pipeline CI/CD:

```bash
# GitHub Actions
- name: Install Speclet Skills
  run: |
    mkdir -p .codex/skills
    cp -r ./skills/* .codex/skills/
```

```yaml
# GitLab CI
install-skills:
  script:
    - mkdir -p .codex/skills
    - cp -r ./skills/* .codex/skills/
```

## Notas Importantes

- ✅ Speclet instala automáticamente en **ambas** ubicaciones (.opencode/skill/ y .codex/skills/)
- ✅ Los skills son **compatibles** entre OpenCode y Codex
- ✅ Puedes usar **ambos** sistemas simultáneamente
- ✅ Los skills se buscan en **orden de prioridad** (local primero)
- ✅ Cambios en SKILL.md requieren **reinicio** de Codex/OpenCode

## Recursos

- [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)
- [Agent Skills Specification](https://agentskills.io/specification)
- [Codex Quickstart](https://developers.openai.com/codex/quickstart)
