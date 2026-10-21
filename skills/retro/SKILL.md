---
name: retro
description: Conduct a retrospective on a coding session to improve the agent's environment, automated checks, and guardrails.
argument-hint: "ID o ruta de la sesión a analizar (opcional, por defecto la actual)"
disable-model-invocation: true
license: MIT
metadata:
  workflow: continuous-improvement
  phase: retrospective
  credits:
    author: Matt Pocock
    url: "https://github.com/mattpocock/skills/blob/main/skills/engineering/retro/SKILL.md"
---

# Retro (`/retro`)

Realiza una retrospectiva tras una sesión de programación con el agente. El objetivo es **mejorar el entorno del repositorio** (chequeos automatizados, guardrails, linters y punteros de navegación) para que las futuras sesiones sean más rápidas y libres de errores.

`retro` no modifica el código fuente de tu aplicación; propone mejoras en la configuración y herramientas del repo. **No aplica cambios automáticamente: solo propone y espera tu selección.**

## Language and Communication Rules

- **Always speak, explain, and interact with the user in Spanish.**
- Presenta las propuestas y candidatos en español, manteniendo la terminología técnica estándar (*"guardrail"*, *"linter"*, *"hook"*, *"no-op"*, *"navigation pointer"*).

---

## Proceso de Retrospectiva

1. **Lectura de la sesión:**
   - Lee el historial o logs de la sesión especificada (por defecto, la sesión actual en curso o los logs más recientes en el equipo).
   - Identifica momentos de fricción: búsquedas lentas de archivos, errores recurrentes, herramientas costosas o falta de visibilidad.

2. **Categorización de candidatos:**
   Clasifica los problemas detectados en las siguientes áreas de mejora:

   - **Chequeos automatizados (`Automated checks`):**
     ¿El agente cometió un error mecánico (import no permitido, patrón deprecated, error de tipado o violación de convención de archivos)?
     *Regla de oro:* Un error mecánico se resuelve con un **chequeo determinista** (regla de ESLint/linter, tipo estricto, script en `package.json` o test automatizado), **nunca** con prosa ni recordatorios en texto. Si el comando ya existía en el repo pero no estaba conectado en pre-commit o CI, el hallazgo es conectarlo.
   - **Punteros de navegación (`Navigation pointers`):**
     ¿El agente dio múltiples vueltas o lanzó decenas de búsquedas para encontrar un archivo o módulo clave?
     *Solución:* Proponer un puntero directo de 1 línea en `.speclet/rules.md` o en las instrucciones base señalando la ubicación canónica de ese módulo.
   - **Estándares del revisor (`Coding standards`):**
     ¿Fue un error de criterio humano o consistencia que un linter no puede capturar?
     *Solución:* Añadir la regla a la rúbrica de revisión (`rules.md` o pautas de review), **no** al prompt del agente implementador. El revisor tiene bajo estrés de contexto porque solo lee el diff.
   - **Limpieza de No-Ops (`No-ops`):**
     ¿Hay instrucciones en las reglas o prompts que no modifican el comportamiento del modelo o quedaron obsoletas?
     *Solución:* Proponer su eliminación para liberar espacio en la ventana de contexto.
   - **Economía de herramientas (`Tool economy`):**
     ¿El agente ejecutó comandos pesados, ineficientes o que arrojaron salidas de miles de líneas innecesarias?
     *Solución:* Sugerir comandos con filtros (`--stat`, `grep`, `--depth 1`) o herramientas más livianas.
   - **Acceso a información (`Information access`):**
     ¿El agente carecía de logs del servidor local, variables de entorno de prueba o salidas de depuración?
     *Solución:* Proponer volcar logs a un archivo temporal o habilitar accesos de solo lectura a métricas.
   - **Guardrails ausentes (`Missing guardrails`):**
     Si el repositorio carece de pre-commit hooks o trabajo de CI que valide linting y tests antes de mergear, repórtalo como un hallazgo crítico.

3. **Presentación de candidatos:**
   - Presenta las propuestas ordenadas por **severidad e impacto**.
   - Para cada candidato, indica:
     * **Momento exacto:** En qué punto de la sesión ocurrió el problema.
     * **Tipo:** Chequeo automatizado, Puntero de navegación, Estándar de revisión, etc.
     * **Propuesta concreta:** El cambio exacto a realizar (ej: snippet de linter, script de package.json, o línea a añadir en `rules.md`).
   - Pregunta al usuario: *"¿Cuál de estos candidatos deseas que implementemos?"*.
