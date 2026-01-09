---
name: speclet-learn
description: Generate explanatory lessons after completing speclet stories to develop mechanical coding fluency
license: MIT
compatibility: opencode
metadata:
  workflow: speclet
  audience: developers-learning
---

# Speclet Learn Skill

Genera lecciones explicativas después de cada story completada para desarrollar fluidez mecánica.

## What I Do

- Leo spec.json y encuentro la última story con `passes: true`
- Analizo los archivos modificados en esa story
- Genero una lección en `.speclet/lessons/STORY-X.md` con:
  - Decisiones técnicas (por qué X y no Y)
  - Conceptos explicados según complejidad detectada
  - Código anotado
  - Errores comunes
  - Ejercicio de práctica (10-15 min, sin LLM)

## When to Use Me

Después de completar stories con speclet-loop:

```
/speclet-learn
```

Ideal para tu rutina de 30 min de práctica antes del trabajo.

## Your Task

### Step 1: Find Last Completed Story

Lee `.speclet/spec.json` y encuentra la última story con `"passes": true`.

```bash
# Busca la story con passes: true y el priority más alto (última completada)
```

Si no hay stories con `passes: true`, responde:

```
❌ No hay stories completadas aún. Primero completa al menos una story con /speclet-loop.
```

### Step 2: Read Modified Files

Lee los archivos del campo `"files"` de esa story.

Analiza:
- Qué patrones se usaron
- Qué conceptos están presentes
- Nivel de complejidad

### Step 3: Detect Complexity

Clasifica cada concepto encontrado según la **Tabla de Complejidad**:

#### 🟢 Nivel Básico (explicación mínima: 1-2 líneas)

| Patrón | Ejemplo |
|--------|---------|
| Variables y tipos | `name: str = "valor"` |
| Condicionales | `if x > 0:` |
| Loops básicos | `for item in list:` |
| Funciones simples | `def foo(x): return x + 1` |
| Imports | `from x import y` |
| F-strings | `f"Hola {nombre}"` |
| Diccionarios/Listas | `data = {"key": "value"}` |

**Acción:** Mención breve. "Ya conoces esto."

#### 🟡 Nivel Intermedio (explicación media: 5-10 líneas + ejemplo)

| Patrón | Ejemplo |
|--------|---------|
| Clases | `class Product:` |
| Decoradores básicos | `@router.get("/")` |
| List/Dict comprehensions | `[x*2 for x in items]` |
| Type hints | `def foo(x: str) -> int:` |
| Context managers | `with open(file) as f:` |
| Excepciones | `try/except/finally` |
| Args/Kwargs | `def foo(*args, **kwargs):` |
| Properties | `@property` |

**Acción:** Explicar qué hace, por qué se usa, ejemplo comentado.

#### 🔴 Nivel Avanzado (explicación profunda: 10-20 líneas + múltiples ejemplos)

| Patrón | Ejemplo |
|--------|---------|
| Async/Await | `async def fetch():` |
| Decoradores personalizados | `def my_decorator(func):` |
| Closures | Función que retorna función |
| Generadores | `yield` |
| Metaclasses | `class Meta(type):` |
| Descriptors | `__get__`, `__set__` |
| Generic types | `List[T]`, `TypeVar` |
| Dependency Injection | `Depends()` |
| SQLAlchemy/SQLModel | Sesiones, queries, relaciones |

**Acción:** Explicar en profundidad: qué es, cómo funciona internamente, cuándo usarlo, errores comunes.

### Step 4: Generate Lesson

Crea `.speclet/lessons/STORY-X.md` con la estructura definida en la sección **Lesson Template**.

### Step 5: Confirm

Responde:

```
✅ Lección generada: .speclet/lessons/STORY-X.md

📚 Conceptos cubiertos:
- [Concepto 1] (🟢 básico)
- [Concepto 2] (🟡 intermedio)
- [Concepto 3] (🔴 avanzado)

⏱️ Ejercicio de práctica: [Descripción breve] (15 min, sin LLM)

Cuando termines el ejercicio, compara tu código con los archivos reales:
- [archivo1.py]
- [archivo2.py]
```

---

## Lesson Template

Genera `.speclet/lessons/STORY-X.md` con esta estructura exacta:

```markdown
# Lección: STORY-X — [Título de la Story]

**Fecha:** YYYY-MM-DD
**Archivos:** [lista de archivos modificados]
**Complejidad detectada:** 🟢/🟡/🔴 [Nivel predominante] ([conceptos principales])

---

## Resumen

[2-3 oraciones: Qué se implementó y por qué importa]

---

## Decisiones Técnicas

### ¿Por qué [decisión 1]?

**Alternativas consideradas:**
1. [Alternativa A] → [Por qué no]
2. [Alternativa B] → [Por qué no]
3. **[Lo que elegimos]** → [Por qué sí] ✅

[Explicación de 3-5 líneas]

### ¿Por qué [decisión 2]?

[Mismo formato...]

---

## Conceptos Explicados

### [Concepto 1] (🟢/🟡/🔴)

[Explicación según nivel de complejidad]

```python
# Ejemplo de código comentado
```

### [Concepto 2] (🟢/🟡/🔴)

[Explicación según nivel...]

---

## Errores Comunes

### ❌ [Error 1]

```python
# MAL
[código incorrecto]

# BIEN
[código correcto]
```

**Por qué falla:** [Explicación breve]

### ❌ [Error 2]

[Mismo formato...]

---

## Ejercicio de Práctica

**Tiempo:** 10-15 minutos
**Regla:** SIN LLM. Solo docs oficiales si te trabas.

### El Reto

[Descripción clara del ejercicio relacionado con la story]

1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

**Archivo a crear:** `[path/to/exercise_file.py]` (no toques el código real)

---

### Hints (solo si te trabas)

<details>
<summary>Hint 1 (estructura general)</summary>

```python
# Esqueleto básico sin la lógica
```

</details>

<details>
<summary>Hint 2 (concepto clave)</summary>

[Pista sobre el concepto principal que necesitas]

</details>

<details>
<summary>Hint 3 (casi la respuesta)</summary>

```python
# Código más completo, falta un detalle
```

</details>

---

## Próximo Paso

Cuando termines (o después de 15 min intentando), compara con:
- `[archivo_real_1.py]`
- `[archivo_real_2.py]`

**Pregúntate:**
- ¿Qué hice diferente?
- ¿Por qué el código real eligió esa estructura?
- ¿Qué concepto me falta entender mejor?
```

---

## Language Rules

- **Código:** Siempre en inglés (variables, funciones, comentarios de código)
- **Explicaciones:** En español
- **Prioridad de profundidad:** Python > TypeScript (explicar más Python)

---

## Exercise Generation Rules

El ejercicio debe:

1. **Estar relacionado con la story** — Mismo dominio, conceptos similares
2. **Ser alcanzable en 10-15 min** — No más complejo que la story original
3. **Forzar práctica sin LLM** — El punto es desarrollar fluidez mecánica
4. **Tener 3 hints progresivos:**
   - Hint 1: Estructura general (esqueleto)
   - Hint 2: Concepto clave (pista conceptual)
   - Hint 3: Casi la respuesta (código parcial)
5. **NO incluir solución completa** — El usuario debe comparar con código real

### Ejemplos de Buenos Ejercicios

| Story Implementada | Ejercicio Propuesto |
|--------------------|---------------------|
| Endpoint GET /products | Crea POST /products con validación |
| Servicio de búsqueda | Agrega filtro por categoría |
| Modelo SQLModel | Agrega campo con relación FK |
| Componente React | Crea variante del mismo componente |

---

## What NOT To Do

- ❌ NO modifiques ningún archivo de código de producción
- ❌ NO agregues comentarios de enseñanza al código real
- ❌ NO incluyas soluciones completas a ejercicios
- ❌ NO expliques conceptos básicos en detalle (sé breve)
- ❌ NO generes lecciones para stories que no están completadas
- ❌ NO uses el skill automáticamente — solo cuando el usuario lo invoca
