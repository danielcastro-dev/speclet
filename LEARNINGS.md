# Aprendizajes: Implementación de Speclet Council y Background Agents

Este documento detalla los desafíos técnicos, errores cometidos y soluciones aplicadas durante la creación del sistema de revisión adversarial `speclet-council`.

## 1. El Desafío de los Background Agents

El objetivo era ejecutar 4 modelos de lenguaje en paralelo para criticar un `draft.md`. Inicialmente, el sistema se bloqueaba o devolvía errores de "worker not found".

### Descubrimiento Clave
La herramienta `background_task` de `oh-my-opencode` no es mágica; requiere una infraestructura de concurrencia explícita en el archivo de configuración global.

**Lección:** Un agente puede tener la herramienta, pero si el "pool" de trabajadores no está definido en el `oh-my-opencode.json`, las tareas se quedan en un limbo infinito (`running` sin progreso).

## 2. En qué fallé (Errores Cometidos)

*   **Asumir Concurrencia por Defecto:** Intenté lanzar tareas sin verificar si el usuario tenía configurado el límite de tareas paralelas.
*   **Ignorar la Regla del Idioma:** Las herramientas de `background_task` y `call_omo_agent` en este plugin exigen **Prompts en Inglés**. Al incluir contenido del `draft.md` (en español) dentro del prompt de la tarea background, el agente se confundía o fallaba al procesar las instrucciones del sistema.
*   **Condiciones de Carrera (Race Conditions):** Intenté que múltiples agentes escribieran en el mismo archivo (`draft.md`) simultáneamente. Esto causó errores de validación de OpenCode ("You must read the file before overwriting").
*   **Tool Sprawl:** Inicialmente usé `background_task`, pero descubrí que `call_omo_agent(run_in_background=true)` es más robusto para este flujo ya que permite mapear `session_id` de forma más limpia.

## 3. Cómo lo hice funcionar (Soluciones)

### A. Configuración de Infraestructura
Se inyectó un bloque de concurrencia en la configuración global para habilitar el paralelismo real:
```json
"background_task": {
  "defaultConcurrency": 5,
  "providerConcurrency": { "google": 10, "openai": 5 }
}
```

### B. El Protocolo de "Append Seguro"
Para solucionar el error de "leer antes de escribir" en ejecuciones paralelas:
1.  **Aislamiento**: Cada revisor genera su crítica en memoria/sesión.
2.  **Sincronización**: Sisyphus (el agente principal) espera a que todos terminen.
3.  **Escritura Atómica**: Se usa Bash (`cat <<EOF >> file.md`) para anexar al final del archivo. Bash gestiona el puntero del archivo de forma atómica, evitando que OpenCode bloquee la operación por falta de un `Read` previo.

### C. Registro de Especialistas
Se definieron agentes con roles específicos en el `json` de configuración para que el consejo tuviera personalidades distintas:
*   `plan-reviewer-opus`: Arquitectura.
*   `plan-reviewer-sonnet`: Claridad.
*   `plan-reviewer-gemini`: Casos Edge.
*   `plan-reviewer-gpt`: Implementabilidad.

## 4. Conclusión para Futuros Desarrollos

Para que un sistema de agentes paralelos sea estable en OpenCode:
1.  **Define la concurrencia** en el config global.
2.  **Habla en Inglés** con las herramientas de background (aunque el output sea en otro idioma).
3.  **Usa Bash para Appends** si esperas que múltiples procesos toquen el mismo archivo.
4.  **Centraliza la Síntesis**: No dejes que los subagentes peleen por el archivo principal; deja que uno solo (el orquestador) consolide los resultados.

---
*Documento generado por Antigravity (Sisyphus) tras la implementación exitosa de speclet-council.*
