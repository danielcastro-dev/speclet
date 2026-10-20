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
- **Review manual y económico**: `speclet-loop` nunca invoca reviewers; `speclet-review` verifica el cambio entero cuando el usuario lo solicita.
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
   - Speclet Core: speclet-rules, speclet-draft, speclet-plan, speclet-loop, speclet-review, speclet-archive, speclet-jira
   - Ingenieria independiente: systematic-debugging, test-driven-development, verification-before-completion, production-monitoring, readable-code
   - Modos auxiliares: ponytail, caveman

3. Avisame cuando este listo para comenzar con $speclet-draft (o $speclet-rules si el proyecto es nuevo).
```

---

## Flujo de trabajo

```text
  speclet-rules (opcional) -> speclet-draft -> speclet-plan -> speclet-loop
                                                         |
                                                   Implementado
                                                         |
                                                (solo si lo pides)
                                                         v
                                                   speclet-review
                                                         |
                                                  speclet-archive
```

1. **`$speclet-rules`** *(Opcional / Por repositorio)*: Inspecciona el stack y genera/actualiza `.speclet/rules.md` con las reglas de oro del repo (no duplicar lógica según Ponytail, claves PK/FK, índices obligatorios de BD y seguridad).
2. **`$speclet-draft`**: Analiza el proyecto respetando `rules.md` y aclara requisitos mediante preguntas breves de seleccion multiple antes de redactar `spec.md`.
3. **`$speclet-plan`**: Convierte el spec aprobado en un plan tecnico minimo (`plan.md`) y lista de tareas ejecutables (`tasks.md`). Respeta las invariantes del repo (reutilización de helpers, índices de BD) y fija focos de revisión con tests obligatorios.
4. **`$speclet-loop`**: Ejecuta todas las tareas con worktree consultado, TDD, tests y commits locales por tarea. No invoca subagentes ni reviewers automáticamente; termina con `Estado: Implementado`.
5. **`$speclet-review`** *(Opcional / Manual)*: Revisa el diff completo con rúbrica 3D (completitud, corrección y coherencia), usando como máximo un subagente económico si es posible seleccionar su modelo. Nunca corrige automáticamente.
6. **`$speclet-archive`**: Archiva el cambio implementado en `.speclet/archive/YYYY-MM-<nombre>/` y actualiza el índice cronológico para mantener `.speclet/changes/` despejado.
7. **`$speclet-jira`** *(Opcional)*: Prepara la historia o reporte de entrega basado en la evidencia y commits reales cuando se requiere traspaso.

---

## Reglas del Proyecto (`rules.md`)

Ejecuta `$speclet-rules` para generar o personalizar `.speclet/rules.md` (o `rules.md` en la raíz) con las directrices de tu repositorio:
- **Filosofía Ponytail & readable-code:** No duplicar lógica; si una función o patrón se repite, extraer un helper reutilizable. Código lineal de arriba a abajo con *guard clauses* (early returns), prohibiendo el troceado artificial de funciones por complejidad ciclomática.
- **Arquitectura de carpetas (Brownfield-first):** Respetar estrictamente la estructura actual del repositorio existente; en código nuevo, prohibido el *flat dumping* (separar rutas, servicios, db/modelos y utilidades).
- **Base de datos:** Reglas de Primary Keys, Foreign Keys explícitas con restricciones de integridad, e índices obligatorios en columnas de búsqueda o filtros WHERE frecuentes.
- **Arquitectura:** Esquema de respuestas de endpoints, redacción de tokens en logs y políticas de testing.

*Consulta la plantilla en [`templates/rules.example.md`](./templates/rules.example.md).*

---

## Catalogo de Skills

### Speclet Core

| Skill | Invocacion | Proposito |
| :--- | :--- | :--- |
| **`speclet-rules`** | `$speclet-rules` | Inicializa o actualiza `rules.md` con las reglas de oro del repo y de base de datos. |
| **`speclet-draft`** | `$speclet-draft` | Aclara requisitos mediante opciones multiples y genera `spec.md`. |
| **`speclet-plan`** | `$speclet-plan` | Define arquitectura minima, casos limite, reglas de DB/Ponytail y tareas en `tasks.md`. |
| **`speclet-loop`** | `$speclet-loop` | Ejecuta todas las tareas con TDD, tests y commits sin reviewers automáticos. |
| **`speclet-review`** | `$speclet-review` | Revisión integral manual del cambio completo, sin correcciones automáticas. |
| **`speclet-archive`** | `$speclet-archive` | Mueve cambios terminados a `.speclet/archive/` y actualiza el índice histórico. |
| **`speclet-jira`** | `$speclet-jira` | Genera tickets o reportes de cierre con evidencia real. |

---

### Habilidades de Ingenieria Independientes

Skills autonomas para calidad, depuracion y monitoreo en produccion:

| Skill | Proposito | Regla central |
| :--- | :--- | :--- |
| **`readable-code`** | Código lineal de arriba a abajo, guard clauses, funciones profundas y carpetas estructuradas. | La comprensión humana y la lectura secuencial priman sobre métricas ciegas de complejidad ciclomática. |
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
│   ├── speclet-rules/             # Inicializacion de reglas de repo y DB
│   ├── speclet-draft/             # Definicion guiada de requerimientos
│   ├── speclet-plan/              # Planificacion tecnica con casos limite
│   ├── speclet-loop/              # Ejecucion autonoma, TDD y commits
│   ├── speclet-review/            # Revision integral manual
│   ├── speclet-archive/           # Archivado historico y limpieza
│   ├── speclet-jira/              # Traspaso y tickets con evidencia
│   ├── systematic-debugging/      # Investigacion de causa raiz (Superpowers)
│   ├── test-driven-development/   # Ciclo TDD (Superpowers)
│   ├── verification-before-completion/ # Puerta de evidencia previa al commit (Superpowers)
│   ├── production-monitoring/     # Observabilidad, OTEL y metricas en produccion
│   ├── readable-code/             # Codigo lineal, guard clauses y carpetas
│   ├── ponytail/                  # Pragmatismo senior (Dietrich Gebert)
│   └── caveman/                   # Chat conciso (Julius Brussee)
├── tests/
│   └── workflow.test.js           # Invariantes de revisión manual
├── templates/
│   └── rules.example.md           # Plantilla de invariantes de repo y DB
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
