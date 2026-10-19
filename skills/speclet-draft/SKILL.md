---
name: speclet-draft
description: Leer el proyecto y acordar requisitos mediante preguntas de selección múltiple antes de crear un spec.md breve. Usar al definir un cambio no trivial o iniciar Speclet; no para consultas, revisiones ni arreglos directos de un archivo.
license: MIT
metadata:
  workflow: speclet
  phase: definition
---

# Speclet Draft

Definir **qué cambia y cómo sabremos que funciona**. No implementar ni elegir una arquitectura antes de entender el problema.

## Forma de trabajar

- Cargar expresamente las skills instaladas `ponytail` y `caveman` leyendo sus `SKILL.md`. Ponytail orienta simplicidad y reutilización; Caveman abrevia sólo el chat en español. Esta activación prestada termina al salir de Speclet; respetar un modo previo activado expresamente por el usuario. Documentos, preguntas, comandos y errores mantienen lenguaje normal y datos exactos. No activar plugins, hooks o proxies.
- Reutilizar código y dependencias existentes. Descartar extras especulativos, conservando el comportamiento y las verificaciones solicitadas.
- Leer políticas existentes sólo cuando sean pertinentes. No exigir ni generar manuales, catálogos centrales, baseline.md o project-context.md.

## Primero: entender el proyecto

Antes de formular preguntas de requisitos, hacer una pasada de lectura dirigida: instrucciones aplicables, manifiestos, estructura del área afectada, puntos de entrada, consumidores, pruebas y convenciones existentes. Seguir el comportamiento relevante, sin recorrer todo el repositorio por rutina ni ejecutar servicios para preparar la entrevista.

Resumir brevemente qué existe, dónde encaja el cambio y qué decisiones siguen abiertas. Sustentar los hechos importantes con rutas del proyecto. No preguntar al usuario por tecnologías, archivos o comportamientos que esta inspección pueda resolver. Si no hay proyecto accesible, explicitar ese límite y preguntar sólo por el contexto necesario.

## Después: selección múltiple en rondas cortas

- Presentar entre una y tres preguntas por ronda, únicamente si sus respuestas cambian alcance, comportamiento, aceptación o riesgos relevantes.
- Preferir selección múltiple: entre dos y cuatro opciones reales, con una recomendación y una frase que explique su consecuencia o tradeoff. No inventar opciones de relleno ni forzar una elección cuando hace falta una respuesta abierta.
- Usar la herramienta de preguntas estructuradas disponible en el entorno. Si no hay una adecuada, numerar las preguntas y marcar opciones A/B/C para permitir respuestas como `1B, 2A`.
- Preguntar en español y con frases completas, incluso con Caveman activo. Aceptar respuestas libres e híbridas; las opciones orientan, no limitan la decisión del usuario.
- Incorporar cada respuesta antes de la siguiente ronda. No repetir preguntas contestadas ni convertir recomendaciones en aprobaciones del usuario.
- Si el cambio ya está definido, resumirlo y confirmar sólo la aprobación que falte; no fabricar una entrevista. La lectura previa sigue siendo necesaria.

## Documento

Resolver la raíz Git y un nombre descriptivo estable. Escribir únicamente `.speclet/changes/<nombre>/spec.md` en español. Si se entrega una ruta, usarla. Si el nombre pertenece a otro trabajo, pedir identificar el cambio antes de sobrescribirlo.

Los documentos son locales: excluir el nuevo directorio mediante el exclude local que resuelva `git rev-parse --git-path info/exclude`, sin editar `.gitignore` versionado ni desversionar documentos existentes. Si este cambio ya tiene documentos versionados, señalar el conflicto antes de modificarlos. Sin Git se puede acordar el spec; la ejecución necesitará un repositorio.

Usar una estructura breve:

```markdown
# Nombre del cambio
Estado: Borrador

## Objetivo y alcance
Resultado observable, comportamiento actual y cambio solicitado.
Fuera de alcance: extras que se excluyen.

## Comportamiento y aceptación
- AC-01: Dado ..., cuando ..., entonces ...
- AC-02: Error o límite relevante y resultado esperado.

## Decisiones y pendientes
Decisiones confirmadas, evidencia pertinente y preguntas materiales.

## Aprobación
Pendiente; registrar la aprobación real cuando exista.
```

Los AC describen resultados observables, no "funciona", "es seguro" ni pasos de implementación. Separar hechos del código, decisiones y desconocidos; citar rutas que sostengan decisiones materiales.

Actualizar el mismo documento durante la conversación. No crear brainstorm, draft, research o informes adicionales. Marcar Aprobado sólo con autorización real; una autorización explícita que ya cubre ese diseño no necesita otra confirmación equivalente.

## Límites y salida

- No leer, convertir, mover ni borrar JSON, manuales o historial del workflow anterior. Usar exclusivamente el nuevo directorio de cambio.
- No crear worktrees, cambiar de rama, instalar dependencias ni editar código en esta fase.
- Si faltan decisiones materiales, mantener Borrador y preguntar. Si está aprobado, proponer `$speclet-plan` con la ruta, sin implementar automáticamente.
- Los riesgos de datos, errores, concurrencia o reintentos se traducen en AC cuando corresponda; no en auditorías generales.
