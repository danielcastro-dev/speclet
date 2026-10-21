# Speclet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![skills.sh](https://img.shields.io/badge/skills.sh-danielcastro--dev%2Fspeclet-black)](https://skills.sh)
[![Compatible with](https://img.shields.io/badge/Agentes-Claude%20Code%20%7C%20Codex%20%7C%20Cursor%20%7C%20Antigravity-purple)]()

Kit personal portátil de ingeniería de software y desarrollo guiado por especificaciones (**Spec-Driven Development / SDD**) para agentes de IA (Claude Code, OpenAI Codex, Antigravity, Cursor, Windsurf).

Diseñado para instalarse en cualquier máquina en 30 segundos y contar de inmediato con un flujo estricto de calidad, arquitectura limpia, TDD y entrega sin *AI-slop*.

---

## ⚡ Instalación Express (PC nueva en 1 minuto)

### Opción 1: Con npx skills (Recomendado)

Utiliza el gestor universal de skills para agentes ([skills.sh](https://skills.sh)):

```bash
# Global para todos tus agentes en el sistema (Codex, Claude Code, Cursor, etc.):
npx skills add danielcastro-dev/speclet -g

# O solo para el proyecto actual (.agents/skills/):
npx skills add danielcastro-dev/speclet
```

---

### Opción 2: Prompt para que tu LLM lo instale por ti

Copia y pega este prompt en el chat de tu agente en cualquier máquina nueva:

```text
Instala y configura las skills de Speclet en este entorno:

1. Ejecuta en terminal:
   npx -y skills add danielcastro-dev/speclet -g -y
   (o a nivel de proyecto: npx -y skills add danielcastro-dev/speclet -y)

2. Confirma las skills disponibles:
   - Speclet Core: speclet-rules, speclet-draft, speclet-plan, speclet-loop, speclet-review, speclet-archive, speclet-jira
   - Ingenieria independiente: pr, merge-risk, handoff, readable-code, systematic-debugging, test-driven-development, verification-before-completion, production-monitoring
   - Modos auxiliares: ponytail, caveman

3. Avisame cuando este listo para comenzar con $speclet-draft (o $speclet-rules si el proyecto es nuevo).
```

---

## 🔄 1. Flujo Spec-Driven Development (SDD)

El desarrollo guiado por especificaciones elimina el "vibe coding": ningún agente escribe código productivo sin antes acordar los requisitos, planificar la arquitectura mínima y aislar el trabajo en un Git worktree.

### Diagrama del ciclo de vida

```text
  speclet-rules (invariantes de repo y BD)
         │
         ▼
   speclet-draft (aclaración de requerimientos -> spec.md)
         │
         ▼
   speclet-plan (arquitectura mínima y focos de revisión -> plan.md + tasks.md)
         │
         ▼
   speclet-loop (TDD en git worktree consultado + commits atómicos por tarea)
         │
         ├─────────────────────────────────────────┐
         ▼                                         ▼
   speclet-review (auditoría manual 3D)          pr (/pr) (apertura GitHub/GitLab)
         │                                         │
         │                                         ▼
         │                                  merge-risk (auditoría pre-merge)
         │                                         │
         └────────────────────┬────────────────────┘
                              ▼
                       speclet-archive (limpieza y registro histórico)
                              │
                              ▼
                       speclet-jira (traspaso con evidencia real)
```

### Principios del flujo

1. **Markdown puro:** Sin JSONs rígidos ni burocracia de herramientas externas; las especificaciones viven en `.speclet/`.
2. **Selección múltiple:** El agente aclara dudas con preguntas concretas y opciones en lugar de asumir a ciegas.
3. **Worktrees aislados:** Cada cambio corre en su propio árbol de trabajo de Git consultado previamente.
4. **TDD obligatorio:** Rojo -> Verde -> Refactor antes de dar por buena cualquier tarea.
5. **Evidencia antes de afirmaciones:** Ninguna tarea se cierra sin el comando de verificación real y su salida exitosa en terminal.
6. **Revisión económica y humana:** `speclet-loop` nunca lanza subagentes revisores automáticamente; la revisión es un acto consciente del desarrollador.

---

## 🧠 2. Speclet Core (El motor de especificaciones)

Módulos diseñados para estructurar y ejecutar cambios controlados:

| Skill | Invocación | Propósito |
| :--- | :--- | :--- |
| **`speclet-rules`** | `$speclet-rules` | Inspecciona el stack y genera `.speclet/rules.md` con las invariantes del repo (reutilización de helpers, PK/FK e índices de BD). |
| **`speclet-draft`** | `$speclet-draft` | Entrevista interactiva para acordar requisitos y redactar `spec.md`. |
| **`speclet-plan`** | `$speclet-plan` | Desglosa la arquitectura mínima y las tareas atómicas con tests en `tasks.md`. |
| **`speclet-loop`** | `$speclet-loop` | Ejecuta las tareas en git worktree con TDD y commits atómicos sin reviewers automáticos. |
| **`speclet-review`** | `$speclet-review` | Auditoría manual e integral del diff contra la rúbrica 3D (completitud, corrección y coherencia). |
| **`speclet-archive`** | `$speclet-archive` | Mueve cambios terminados a `.speclet/archive/` para mantener el árbol despejado. |
| **`speclet-jira`** | `$speclet-jira` | Redacta tickets de Jira o mensajes de cierre basados en la evidencia real. |

---

## 🛠️ 3. Skills de Ingeniería y Productividad

Herramientas independientes que funcionan tanto dentro del flujo SDD como de forma autónoma en el día a día:

### Entrega, Auditoría y Transición
| Skill | Invocación | Propósito |
| :--- | :--- | :--- |
| **`pr`** | `$pr` (o `/pr`) | Prepara y abre el PR en GitHub (`gh`) o GitLab (`glab`) con formato escaneable en 30 segundos (resumen visual, evidencia de tests y Merge Danger), respetando la rama base. |
| **`merge-risk`** | `merge-risk` | Evalúa el riesgo de mergear una rama o PR contra 5 dimensiones ponderadas (alineación, blast radius, verificación, reversibilidad y observabilidad) con veredicto conciso (`low`, `medium`, `high`). |
| **`handoff`** | `/handoff` | Compacta la sesión en un documento markdown portátil en `/tmp` con decisiones, punteros y skills sugeridas para que otro agente, harness o colega continúe sin fricción. |

### Calidad y Arquitectura de Código
| Skill | Propósito | Regla central |
| :--- | :--- | :--- |
| **`readable-code`** | Código lineal de arriba a abajo, guard clauses (early returns), módulos profundos y carpetas estructuradas. | La comprensión humana y la lectura secuencial priman sobre métricas ciegas de complejidad ciclomática. |
| **`test-driven-development`** | Desarrollo guiado por pruebas (TDD). | Escribe el test primero, comprueba que falle y luego implementa lo mínimo. |
| **`systematic-debugging`** | Aislamiento metódico de causa raíz ante bugs o fallos de CI. | Prohibido proponer código sin investigación previa comprobable. |
| **`verification-before-completion`** | Verificación con evidencia fresca antes de commits. | Prohibido afirmar éxito sin ejecutar el comando y validar salida en el turno. |
| **`production-monitoring`** | Observabilidad en producción: OpenTelemetry, trazas, logs estructurados, métricas y SLOs. | La observabilidad es fundacional desde el día uno, no un agregado posterior. |

---

## 🎭 4. Modos Auxiliares (Personalidad del Agente)

| Modo | Propósito |
| :--- | :--- |
| **`ponytail`** | Desarrollador senior pragmático: el menor cambio completo que resuelve el problema, sin sobreingeniería ni código especulativo. |
| **`caveman`** | Respuestas concisas y directas al grano en español, eliminando el relleno conversacional sin perder rigor técnico. |

---

## 📁 Estructura del Repositorio

```text
speclet/
├── bin/
│   └── cli.js                     # CLI ligero para listar, prompt o instalar skills
├── skills/
│   ├── speclet-rules/             # Inicialización de reglas de repo y DB
│   ├── speclet-draft/             # Definición guiada de requerimientos
│   ├── speclet-plan/              # Planificación técnica con casos límite
│   ├── speclet-loop/              # Ejecución autónoma, TDD y commits
│   ├── speclet-review/            # Revisión integral manual
│   ├── speclet-archive/           # Archivado histórico y limpieza
│   ├── speclet-jira/              # Traspaso y tickets con evidencia
│   ├── pr/                        # Generación y apertura de PR humano (/pr)
│   ├── merge-risk/                # Auditoría de riesgo pre-merge (Warp/Matt Pocock)
│   ├── handoff/                   # Compactación y traspaso de sesión portátil (Matt Pocock)
│   ├── readable-code/             # Código lineal, guard clauses y carpetas
│   ├── systematic-debugging/      # Investigación de causa raíz (Superpowers)
│   ├── test-driven-development/   # Ciclo TDD (Superpowers)
│   ├── verification-before-completion/ # Puerta de evidencia previa al commit (Superpowers)
│   ├── production-monitoring/     # Observabilidad, OTEL y métricas en producción
│   ├── ponytail/                  # Pragmatismo senior (Dietrich Gebert)
│   └── caveman/                   # Chat conciso (Julius Brussee)
├── tests/
│   └── workflow.test.js           # Invariantes de pruebas automatizadas
├── templates/
│   └── rules.example.md           # Plantilla de invariantes de repo y DB
├── package.json
├── LICENSE
└── README.md
```

---

## 📜 Créditos y Atribuciones

Este repositorio representa el flujo de trabajo personal de **[Daniel Castro](https://github.com/danielcastro-dev)**, publicado bajo licencia **MIT**.

Incluye e integra componentes desarrollados por la comunidad de software libre:

- **Superpowers (`systematic-debugging`, `test-driven-development`, `verification-before-completion`)**:  
  Creados por **Jesse Vincent** ([obra/superpowers](https://github.com/obra/superpowers)) bajo Licencia MIT.  
  *Nota:* Estas skills son propiedad intelectual de sus autores originales y se incorporan como dependencias recomendadas.

- **Matt Pocock Skills (`handoff`, `/pr`)**:  
  Conceptos de handoff portátil y estructura humana de PR creados por **Matt Pocock** ([mattpocock/skills](https://github.com/mattpocock/skills)) bajo Licencia MIT.

- **Merge Risk (`merge-risk`)**:  
  Inspirado en el concepto original de *Merge Danger* de **Matt Pocock** y adaptado de la implementación de **Warp** ([warpdotdev/common-skills](https://github.com/warpdotdev/common-skills)) bajo Licencia MIT.

- **Production Monitoring (`production-monitoring`)**:  
  Skill de observabilidad y monitoreo en producción basado en estándares OpenTelemetry y prácticas SRE.

- **Ponytail (`ponytail`)**:  
  Creado por **Dietrich Gebert** ([DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)) bajo Licencia MIT.

- **Caveman (`caveman`)**:  
  Creado por **Julius Brussee** ([JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)) bajo Licencia MIT / Apache 2.0.

- **Inspiraciones adicionales**:  
  Inspirado en el concepto de especificaciones vivas de **OpenSpec** ([Fission-AI/openspec](https://github.com/Fission-AI/openspec)).
