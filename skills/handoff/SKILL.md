---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "Para qué se utilizará la siguiente sesión?"
disable-model-invocation: true
license: MIT
metadata:
  workflow: handover
  phase: transition
  credits:
    author: Matt Pocock
    url: "https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md"
---

# Handoff (`/handoff`)

Compacta la conversación actual en un documento portátil de handoff para que un nuevo agente (o un colega) continúe el trabajo en otra sesión, otro directorio u otro harness (Codex, Antigravity, Claude Code, Cursor).

## Language and Communication Rules

- **Always speak, explain, and interact with the user in Spanish.**
- Redacta el documento de handoff en español (o el idioma del repositorio).

---

## Instrucciones

1. **Destino de la siguiente sesión:**
   - Si el usuario indicó para qué será la siguiente sesión, adapta el resumen y el enfoque estrictamente a ese objetivo.
   - Si no especificó un argumento, resume el trabajo en curso y clarifica los siguientes pasos inmediatos.

2. **Guardar en directorio temporal del sistema operativo:**
   - Guarda el archivo en `$TMPDIR`, o `/tmp` (`%TEMP%` en Windows), bajo el nombre `handoff-<timestamp>.md`.
   - **No guardes el archivo dentro del repositorio ni en el workspace de trabajo**, salvo petición explícita.
   - Entrega siempre la ruta absoluta del archivo generado al usuario.

3. **Estructura del documento:**
   - **Objetivo / Destino:** Qué se busca lograr en la siguiente sesión.
   - **Estado actual:** Resumen conciso de lo avanzado y lo que quedó en vuelo (*in flight*).
   - **Decisiones clave y contexto:** El *por qué* de las decisiones recientes para evitar que el siguiente agente las revierta.
   - **Punteros (no copias):** No copies archivos de código, specs, diffs ni planes enteros; referencia los artefactos por ruta de archivo (`file:///...`), SHA de git o URL del PR/issue.
   - **Skills sugeridas (`Suggested skills`):** Nombra explícitamente qué skills (`$speclet-loop`, `/pr`, `merge-risk`, `systematic-debugging`, etc.) debería invocar el siguiente agente.
   - **Redacción de secretos:** Elimina cualquier API key, token, contraseña o dato sensible antes de guardar.

4. **Instrucción de arranque:**
   - Termina el documento con un prompt listo para copiar y pegar en la nueva sesión:
     `"Lee el archivo de handoff en <ruta_absoluta> y continúa con <siguiente paso>."`
