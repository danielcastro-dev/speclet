# Memoria de Agentes en Oh-My-OpenCode

## Análisis Detallado

Basado en el análisis del Oracle especialista en arquitectura de sistemas, este documento explica cómo funciona la memoria y el contexto en los agentes especializados de oh-my-opencode.

## Resumen Clave

Los subagentes en oh-my-opencode **no tienen memoria duradera por sí mismos**. Lo que parece ser "memoria" es simplemente el historial de la sesión de OpenCode más el contexto que se inyecta en cada invocación.

## Configuración Actual

Los agentes configurados en `C:\Users\Usuario\.config\opencode\oh-my-opencode.json` son:

- **sisyphus** (orchestrator principal)
- **frontend-ui-ux-engineer** (desarrollo frontend)
- **document-writer** (escritura técnica)
- **multimodal-looker** (análisis visual)

## Comportamiento de Memoria

### 1. Memoria entre Invocaciones (Misma Sesión)

- ❌ **Sin memoria automática**: Cada vez que llamas a `@oracle` o cualquier otro subagente, comienza completamente fresco
- ❌ **Sin contexto compartido**: Las invocaciones múltiples del mismo subagente no comparten contexto automáticamente
- ✅ **Memoria del agente principal**: El agente principal Sisyphus sí mantiene memoria de la conversación principal

**Ejemplo:**
```
Usuario: Ask @oracle about architecture
// @oracle responde sin conocimiento previo

Usuario: Ask @oracle to refine that architecture
// @oracle no recuerda la conversación anterior
```

### 2. Tareas en Segundo Plano (`background_task`)

- ❌ **Sin continuidad**: Cada llamada a `background_task(agent="oracle", ...)` crea una nueva sesión hija completamente nueva
- ❌ **Sin memoria entre tareas**: No hay continuidad entre diferentes llamadas de background task
- ✅ **Memoria temporal**: Solo tienen memoria dentro de su propia sesión mientras se ejecutan

**Ejemplo:**
```bash
background_task(agent="oracle", prompt="Review this design")  // Sesión 1
background_task(agent="oracle", prompt="Refine that design") // Sesión 2 (sin contexto de Sesión 1)
```

### 3. Memoria entre Sesiones de OpenCode

- ❌ **Sin persistencia automática**: No hay persistencia automática entre diferentes sesiones de OpenCode
- ❌ **Todo se reinicia**: Todo se reinicia cuando comienzas una nueva sesión
- ✅ **Recuperación manual**: Puedes recuperar contexto manualmente usando las herramientas de `session_*`

### 4. Compartir Contexto

**¿Qué reciben los subagentes:**
- ✅ El prompt que les envías explícitamente
- ✅ Inyección de contexto del sistema (reglas de directorio, hooks, etc.)
- ❌ El historial completo de la conversación principal (no se copia automáticamente)
- ✅ Su propio historial de mensajes (si reutilizas el mismo `session_id`)

**¿Qué NO reciben:**
- ❌ Contexto previo de otras llamadas al mismo subagente
- ❌ Historial de conversaciones con otros subagentes
- ❌ Memoria de sesiones anteriores de OpenCode

## Implicaciones Prácticas

### Para tener "memoria" entre llamadas:

#### 1. Reutilizar IDs de Sesión
```javascript
// Llamada síncrona con sesión continua
call_omo_agent(
  subagent_type="oracle",
  run_in_background=false,
  session_id="oracle-session-1",  // Mismo ID para mantener continuidad
  prompt="Refina el diseño anterior"
)
```

#### 2. Incluir Contexto Explícitamente
```javascript
// Siempre incluye el contexto necesario
background_task(
  agent="oracle",
  prompt=`Basado en el diseño anterior [describir diseño],
         ahora refina este nuevo aspecto: [nuevo aspecto]`
)
```

#### 3. Usar Archivos para Persistencia
```bash
# Guardar decisiones importantes
echo "Decisión de arquitectura: microservicios" > architecture-decisions.md
# Recuperar en llamadas futuras
cat architecture-decisions.md
```

#### 4. Usar Herramientas de Sesión
```javascript
# Buscar conversaciones anteriores
session_search("arquitectura oracle")

# Leer sesión específica
session_read("ses_abc123", include_todos=true)
```

## Estrategias Recomendadas

### Para Consultas Iterativas
1. **Usa modo síncrono** con `session_id` fijo
2. **Crea una "sesión de consulta dedicada"** por tipo de tarea
3. **Documenta decisiones** en archivos del proyecto

### Para Tareas Paralelas
1. **Asume sin continuidad** entre background tasks
2. **Incluye todo el contexto** en cada prompt
3. **Usa archivos temporales** para compartir resultados entre tareas

### Para Trabajo a Largo Plazo
1. **Establece patrones de naming** para sesiones reutilizables
2. **Crea archivos de estado** del proyecto
3. **Usa `session_*` herramientas** para recuperar decisiones importantes

## Edge Cases y Excepciones

### Cuándo el modelo "sin memoria" se rompe:
- Implementas un mecanismo personalizado de resumen de contexto
- Reutilizas explícitamente `session_id`s
- Construyes una capa de "rehidratación" de contexto

### Prácticas Avanzadas
```javascript
// Patrón de sesión de Oracle persistente
const ORACLE_SESSION = "oracle-architecture-session";

function consultOracle(prompt) {
  return call_omo_agent({
    subagent_type: "oracle",
    run_in_background: false,
    session_id: ORACLE_SESSION,
    prompt: prompt
  });
}
```

## Conclusión

Los subagentes en oh-my-opencode son diseñados intencionalmente como **stateless** (sin estado). Este diseño proporciona:

✅ **Control preciso** sobre el contexto compartido
✅ **Evita memoria no deseada** o contaminación de contexto
✅ **Permite paralelización** sin conflictos de estado
✅ **Predecibilidad** en el comportamiento de los agentes

El costo es que debes ser **explícito** sobre el contexto que necesitas compartir entre llamadas, pero este tradeoff resulta en sistemas más manejables y predecibles.

---

**Nota:** Este análisis se basa en el código fuente de oh-my-opencode y las capacidades documentadas de OpenCode. El comportamiento puede evolucionar con futuras actualizaciones.
