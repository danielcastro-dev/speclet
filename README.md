# Speclet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![skills.sh](https://img.shields.io/badge/skills.sh-danielcastro--dev%2Fspeclet-black)](https://skills.sh)
[![Compatible with](https://img.shields.io/badge/Agentes-Claude%20Code%20%7C%20Codex%20%7C%20Cursor%20%7C%20Antigravity-purple)]()

Flujo personal de desarrollo guiado por especificaciones para agentes de IA (Claude Code, OpenAI Codex, Antigravity, Cursor, Windsurf).

Diseñado para ser directo, ligero, centrado en Markdown y sin sobreingeniería.

---

## Filosofia

- **Markdown puro**: Sin esquemas JSON rígidos ni metadatos innecesarios.
- **Seleccion multiple**: Preguntas cortas con opciones concretas para pair programming agil.
- **Worktrees consultados**: Desarrollo aislado en ramas limpias sin tocar main sin autorizacion.
- **Verificacion con evidencia**: Pruebas antes de commits ("evidence before assertions").
- **Simplicidad**: Menor cambio completo posible, eliminando relleno conversacional.

---

## Como instalar

### Opcion 1: Con npx skills (Recomendado)

Utiliza el gestor universal de skills para agentes ([skills.sh](https://skills.sh)):

```bash
# Global para todos tus agentes (Codex, Claude Code, Cursor, etc.):
npx skills add danielcastro-dev/speclet -g

# O solo para el proyecto actual (.agents/skills/):
npx skills add danielcastro-dev/speclet
```

---

### Opcion 2: Prompt para que tu LLM lo instale por ti

Copia y pega este prompt en el chat de tu agente:

```text
Instala y configura las skills de Speclet en este entorno:

1. Ejecuta en terminal:
   npx -y skills add danielcastro-dev/speclet -g -y
   (o a nivel de proyecto: npx -y skills add danielcastro-dev/speclet -y)

2. Confirma las skills disponibles:
   - Speclet Core: speclet-draft, speclet-plan, speclet-loop, speclet-jira
   - Ingenieria independiente: systematic-debugging, test-driven-development, verification-before-completion, production-monitoring
   - Modos auxiliares: ponytail, caveman

3. Avisame cuando este listo para comenzar con $speclet-draft.
```

---

## Flujo de trabajo

```text
  speclet-draft         speclet-plan          speclet-loop          speclet-jira
  (Definicion)    ──>  (Plan tecnico)   ──>   (Ejecucion)     ──>    (Entrega)
       │                     │                     │                     │
       ▼                     ▼                     ▼                     ▼
    spec.md               plan.md               tasks.md              Ticket o
  (Criterios AC)      (Focos/Limites)       (Commits locales)        mensaje PR
```

1. **`$speclet-draft`**: Analiza el proyecto y aclara requisitos mediante preguntas breves de seleccion multiple antes de redactar `spec.md`.
2. **`$speclet-plan`**: Convierte el spec aprobado en un plan tecnico minimo (`plan.md`) y lista de tareas ejecutables (`tasks.md`), incorporando focos de revision y casos limite con tests obligatorios.
3. **`$speclet-loop`**: Ejecuta las tareas con worktree consultado, ciclo TDD, revision independiente por subagente, resolucion agil de dudas tecnicas menores ("Rulings, not stalls") y commits locales.
4. **`$speclet-jira`** *(Opcional)*: Prepara la historia o reporte de entrega basado en la evidencia y commits reales.

---

## Catalogo de Skills

### Speclet Core

| Skill | Invocacion | Proposito |
| :--- | :--- | :--- |
| **`speclet-draft`** | `$speclet-draft` | Aclara requisitos mediante opciones multiples y genera `spec.md`. |
| **`speclet-plan`** | `$speclet-plan` | Define arquitectura minima, casos limite y tareas en `tasks.md`. |
| **`speclet-loop`** | `$speclet-loop` | Ejecuta de forma autonoma con TDD, revision independiente y commits atomicos. |
| **`speclet-jira`** | `$speclet-jira` | Genera tickets o reportes de cierre con evidencia real. |

---

### Habilidades de Ingenieria Independientes

Skills autonomas para calidad, depuracion y monitoreo en produccion:

| Skill | Proposito | Regla central |
| :--- | :--- | :--- |
| **`systematic-debugging`** | Aislamiento de causa raiz ante bugs o fallos de CI. | Prohibido proponer codigo sin investigacion de causa raiz previa. |
| **`test-driven-development`** | Desarrollo guiado por pruebas (TDD). | Escribe el test primero, comprueba que falle y luego implementa lo minimo. |
| **`verification-before-completion`** | Verificacion con evidencia fresca antes de commits. | Prohibido afirmar exito sin ejecucion del comando y salida exit 0 en el turno. |
| **`production-monitoring`** | Observabilidad en produccion, OpenTelemetry, trazas, logs estructurados, metricas y SLOs. | La observabilidad es fundacional desde el dia uno, no un agregado posterior. |

---

### Modos Auxiliares

| Skill | Proposito |
| :--- | :--- |
| **`ponytail`** | Desarrollador senior pragmatico: el menor cambio que resuelve el problema por completo, sin sobreingenieria ni codigo especulativo. |
| **`caveman`** | Respuestas concisas y directas al grano en espanol, eliminando el relleno conversacional sin perder rigor tecnico. |

---

## Estructura del repositorio

```text
speclet/
├── bin/
│   └── cli.js                     # CLI ligero para listar o instalar skills
├── skills/
│   ├── speclet-draft/             # Definicion guiada de requerimientos
│   ├── speclet-plan/              # Planificacion tecnica con casos limite
│   ├── speclet-loop/              # Ejecucion autonoma, TDD y revision
│   ├── speclet-jira/              # Traspaso y tickets con evidencia
│   ├── systematic-debugging/      # Investigacion de causa raiz (Superpowers)
│   ├── test-driven-development/   # Ciclo TDD (Superpowers)
│   ├── verification-before-completion/ # Puerta de evidencia previa al commit (Superpowers)
│   ├── production-monitoring/     # Observabilidad, OTEL y metricas en produccion
│   ├── ponytail/                  # Pragmatismo senior (Dietrich Gebert)
│   └── caveman/                   # Chat conciso (Julius Brussee)
├── package.json
├── LICENSE
└── README.md
```

---

## Creditos y Atribuciones

Este repositorio representa el flujo de trabajo personal de **[Daniel Castro](https://github.com/danielcastro-dev)**, publicado bajo licencia **MIT**.

Incluye e integra componentes desarrollados por la comunidad de software libre:

- **Superpowers (`systematic-debugging`, `test-driven-development`, `verification-before-completion`)**:  
  Creados por **Jesse Vincent** ([obra/superpowers](https://github.com/obra/superpowers)) bajo Licencia MIT.  
  *Nota:* Estas skills son propiedad intelectual de sus autores originales y se incorporan como dependencias independientes recomendadas.

- **Production Monitoring (`production-monitoring`)**:  
  Skill de observabilidad y monitoreo en produccion basado en estandares OpenTelemetry, SRE y patrones de observabilidad para servicios distribuidos.

- **Ponytail (`ponytail`)**:  
  Creado por **Dietrich Gebert** ([DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)) bajo Licencia MIT.

- **Caveman (`caveman`)**:  
  Creado por **Julius Brussee** ([JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)) bajo Licencia MIT / Apache 2.0.

- **Inspiraciones**:  
  Inspirado en el catalogo de skills de **Matt Pocock** ([mattpocock/skills](https://github.com/mattpocock/skills)) y el concepto de especificaciones vivas de **OpenSpec** ([Fission-AI/openspec](https://github.com/Fission-AI/openspec)).
