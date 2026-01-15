# Draft: speclet-council

**Status:** ✅ Listo para implementación
**Fecha:** 2026-01-14
**Rama sugerida:** feature/speclet-council

---

## Descripción del Usuario

Crear una feature llamada `speclet-council` para el ecosistema speclet. Inspirado en `adversarial-spec` de Claude Code, que permite que múltiples LLMs debatan y critiquen un documento hasta llegar a consenso.

**Referencia:** https://github.com/zscole/adversarial-spec.git

**Idea principal:**
- Una vez que el usuario tiene un draft (de speclet-draft), puede invocar speclet-council
- Múltiples agents revisan el spec en paralelo usando background agents o subagents
- Cada agent critica desde su perspectiva (arquitectura, UX, seguridad, etc.)
- Las críticas se sintetizan hasta que todos los agents estén satisfechos
- El resultado es un spec que sobrevivió a revisión adversarial desde múltiples perspectivas

**Lo que debe pasar en práctica:**
- Requerimientos que parecían claros se cuestionan
- Manejo de errores faltante se detecta
- Gaps de seguridad surgen
- Scope creep se previene
- Un modelo dice "¿qué pasa con X?" y otro "el contrato API está incompleto"
- Claude añade "no definiste qué pasa cuando Y falla"
- Al momento que todos los modelos están de acuerdo, el spec es sólido

---

## Preguntas de Clarificación

### 1. Modelos que deben participar en el "consejo"

**Respuesta del usuario:** 1C - quiero crear agents como los de oh-my-opencode.json, algo como plan-reviewer-gpt, plan-reviewer-gemini

**Agentes específicos a crear (4 reviewers, uno por modelo en oh-my-opencode.json):**
- `plan-reviewer-opus` (usando `google/antigravity-claude-opus-4-5-thinking`) - Perspectiva: arquitectura y consistencia lógica
- `plan-reviewer-sonnet` (usando `google/antigravity-claude-sonnet-4-5-thinking`) - Perspectiva: claridad de documentación y completitud
- `plan-reviewer-gemini` (usando `google/antigravity-gemini-3-pro`) - Perspectiva: casos edge y escalabilidad
- `plan-reviewer-gpt` (usando `openai/gpt-5.2-codex`) - Perspectiva: implementabilidad y código realista

---

### 2. Cómo debería ejecutarse el consejo

**Respuesta del usuario:** 2A - usar background agents con `background_task()`

---

### 3. Qué tipo de críticas deben hacer los agentes

**Respuesta del usuario:** 3C - configurable: el usuario puede especificar qué tipo de crítica hace cada agente

---

### 4. Cómo se determina que el spec está "sólido"

**Respuesta del usuario:** 4D - configurable por el usuario (iteraciones máximas + criterio de aprobación)

---

### 5. Debería ser completamente automático o requiere aprobación humana

**Respuesta del usuario:** 5A - Flujo simple y directo:
1. Usuario invoca `speclet-council`
2. Se activan 4 reviewers en paralelo
3. Reviewers dejan críticas y recomendaciones
4. Se presentan las soluciones al usuario
5. Sin comandos extra, sin modo manual

---

### 6. Qué modelos específicos quieres para los reviewers

**Respuesta del usuario:** 6C - todos los modelos de oh-my-opencode.json (4 reviewers)

---

### 7. Cómo deberían configurarse estos agents en oh-my-opencode.json

**Respuesta del usuario:** 7B - agregar los reviewers como subagentes en la sección "agents" de oh-my-opencode.json

---

### 8. Qué permisos deben tener los agents reviewers

**Respuesta del usuario:** 8B - lectura + webfetch

---

## Decisiones Resueltas

### 9. Tipos de documentos a soportar
**Estado:** ✅ RESUELTO
**Respuesta:** C - Solo el `draft.md` de speclet

---

### 11. Cómo debe funcionar la síntesis de críticas
**Estado:** ✅ RESUELTO
**Respuesta:** B - Sisyphus hace la síntesis

---

### 13. Incluir "preserve-intent mode"
**Estado:** ✅ RESUELTO
**Respuesta:** B - Simplificado

---

### 14. Anti-laziness check
**Estado:** ✅ RESUELTO
**Respuesta:** Alternativa mejorada - En lugar de presionar por más críticas, cada reviewer debe listar qué aspectos específicos revisó antes de terminar.

---

## Alcance Propuesto

### Incluido

- Creación de **4 reviewers** especializados en oh-my-opencode.json.
- Nuevo skill `speclet-council` con flujo simple.
- Permisos configurados para reviewers (Solo Lectura + Webfetch).
- Políticas de seguridad webfetch.
- Persistencia de sesión en `.speclet/council-session.md`.
- Manejo de fallos robusto con retry y backoff.

---

## Historias de Usuario

1. **COUNCIL-1:** Configurar reviewers en oh-my-opencode.json.
2. **COUNCIL-2:** Implementar el skill `speclet-council`.
3. **COUNCIL-3:** Crear los prompts del sistema para los revisores.
4. **COUNCIL-4:** Implementar la lógica de síntesis y append seguro.
