---
name: speclet-loop
description: Ejecutar las tareas Markdown de un cambio Speclet aprobado, con worktree consultado, pruebas, revisión independiente y commit local por tarea. Continuar hasta terminar o encontrar un bloqueo real; no usar para planificar ni ejecutar el workflow JSON anterior.
license: MIT
metadata:
  workflow: speclet
  phase: implementation
---

# Speclet Loop

Implementar el cambio aprobado y demostrarlo. `tasks.md` conserva el avance; pruebas y diff demuestran el comportamiento.

## Entrada y autorización

1. Resolver `.speclet/changes/<nombre>/` desde la ruta indicada. Sin ruta, elegir el único cambio no terminado con spec, plan y tareas; si hay varios, pedir elegir. No importar estado anterior. Si sólo existe ese estado, indicar que se requiere un cambio nuevo.
2. Leer los tres Markdown e instrucciones aplicables. Requerir spec aprobado, decisiones materiales resueltas y autorización para ejecutar el plan. La petición explícita de ejecutar este loop sobre ese plan cuenta como autorización; no pedir otra confirmación equivalente.
3. Cargar `ponytail` y `caveman` leyendo sus entrypoints instalados. Ponytail orienta código y revisión; Caveman abrevia sólo el chat en español. La activación prestada termina al salir de Speclet, sin apagar modos previos activados expresamente por el usuario. Documentos, commits, preguntas y errores mantienen lenguaje normal y datos exactos.

## Worktree primero, consultado siempre

Antes de crear un worktree o cambiar de checkout, proponer ruta y rama concretas y preguntar. **No hacerlo mientras la respuesta esté pendiente.** Aprobar el plan no sustituye esta elección. Si el usuario ya autorizó ese worktree para este trabajo, comprobarlo y reutilizarlo sin volver a preguntar. Si lo rechaza, no escribir código hasta acordar otro checkout.

Inspeccionar estado Git, rama, raíz y worktrees existentes. Aplicar la guarda de submódulos (`git rev-parse --show-superproject-working-tree` 2>/dev/null): si devuelve una ruta, estamos dentro de un submódulo y no en un checkout aislado ni en la raíz principal; tratarlo en consecuencia para no romper la estructura del superproyecto. No cambiar a la fuerza, limpiar cambios ajenos ni asumir una base main. Usar la base acordada o la rama actual indicada en el plan. Las tareas comparten el worktree autorizado del cambio.

Al crearlo, llevar sólo los tres Markdown locales y aplicar la exclusión local de Speclet. No copiar secretos, dependencias ni builds automáticamente. Contrastar documentos existentes antes de reemplazarlos. Si falta preparación autorizada, declarar el requisito.

## Basal y selección

- Antes de editar código, ejecutar una vez los comandos pertinentes detectados del proyecto. Registrar comando, señal decisiva y exit code en la verificación de `plan.md`, sin otro reporte.
- Distinguir fallos heredados, entorno y regresiones propias. Un fallo heredado no es una prueba aprobada ni autoriza arreglar código ajeno. Si bloquea un gate exigido, detenerse salvo excepción explícita y documentada del usuario.
- Seleccionar la primera tarea pendiente con dependencias completas. Mantener una tarea activa por worktree y señalarla en `tasks.md` para poder retomar.
- Al reanudar, contrastar avance con archivos y commits reales. No repetir tareas cerradas ni confiar en evidencia de un diff que cambió.

## Implementar y verificar

Hacer el menor cambio completo: reutilizar código y preservar contratos, validación y manejo de errores. Ajustar consumidores, pruebas y fixtures afectados; no aprovechar para refactorizar áreas ajenas.

Ejecutar las verificaciones de la tarea y comprobar sus AC. Las regresiones y la lógica no trivial necesitan pruebas discriminantes; una edición trivial no exige una batería artificial. Si una rama crítica lo justifica, alterar temporalmente una condición y comprobar que la prueba falla; restaurar y verificar antes de revisar o hacer commit. No desactivar pruebas ni presentar mocks como evidencia de proveedores reales.

Comprobaciones sólo cuando correspondan al cambio:

- **Datos/transacciones:** parametrización, conexión/transacción correctas, rollback y concurrencia según el contrato afectado.
- **Errores:** conservar contrato público, correlación y redacción de secretos; distinguir fallos confirmados de resultados inciertos.
- **Red/reintentos:** deadlines e intentos acotados; no repetir efectos no idempotentes sin deduplicación probada. No añadir circuit breakers, infraestructura ni manuales innecesarios.

Una verificación fallida o no ejecutada no equivale a éxito. Registrar la limitación y mantener pendiente la tarea si falta evidencia requerida.

## Delegación y revisión independiente

El orquestador conserva decisiones, integración, estado y commits. Delegar implementación/investigación sólo cuando aporte valor. Máximo tres hijos directos, sin subdelegación y heredando la configuración de la sesión, sin fijar modelos o esfuerzos antiguos. Un solo escritor por worktree; revisores sin ediciones ni commits.

Después de verificar cada tarea, encargar **una revisión independiente** a un subagente con contexto autocontenido:

- Objetivo, AC, tarea activa, rutas del spec/plan/tareas y restricciones pertinentes.
- Base y diff exactos, incluidos archivos nuevos, y consumidores que debe leer.
- Comandos y resultados observados, sin presentarlos como prueba suficiente de corrección.
- Pedido de revisar aceptación y calidad: hallazgo, archivo/línea, impacto y comprobación. Solicitar un veredicto explícito y breve; no un archivo de reporte.

Contrastar hallazgos con el código antes de aceptarlos. La revisión detecta incumplimiento, bugs reales y pruebas insuficientes; no exige refactors ajenos por preferencias del revisor. Aplicar el principio **"Rulings, not stalls"**: ante discrepancias técnicas menores, preferencias estilísticas o ambigüedades sin riesgo destructivo ni fallo de AC/contratos, el orquestador emite un dictamen técnico fundado, lo asienta en las notas de `tasks.md` y continúa la ejecución sin atascar el loop.

Corregir hallazgos aceptados y bloqueantes; repetir pruebas afectadas y revisión del nuevo diff. Máximo **dos rondas de corrección por tarea**, después de la revisión inicial. Si persiste un bloqueo real no subsanable mediante dictamen, registrarlo y detener el loop con la tarea pendiente. Las notas no bloqueantes pueden quedar justificadas.

Si no hay revisión independiente disponible, declarar la limitación y detenerse antes del commit. No sustituirla silenciosamente por auto-revisión ni marcar aprobación ficticia. No generar informes de revisión, inventarios JSON ni diarios obligatorios.

## Commit y avance

Sólo después de verificación y revisión aprobadas:

1. Examinar el diff y stagear únicamente archivos de la tarea, con sus pruebas/fixtures necesarios. No incluir cambios ajenos ni `.speclet/**`.
2. Hacer un commit local por tarea con el estilo del repositorio y descripción breve en español. Añadir clave Jira sólo si existe; no inventarla. No hacer commits vacíos.
3. En `tasks.md`, registrar comandos/exit codes, AC comprobados, veredicto, notas relevantes (incluyendo dictámenes técnicos emitidos si los hubo) y SHA. Marcar `[x]` sólo entonces y quitar el marcador de tarea activa.
4. Continuar sin preguntar "¿continúo?". Una tarea satisfecha por un commit previo puede cerrarse sólo tras verificar evidencia y revisión; citarlo sin fabricar otro.

Si falla el commit, mantener la tarea pendiente y explicar el fallo; no repetir implementación ya verificada. Cualquier cambio posterior al código revisado invalida esa revisión.

## Cierre

Ejecutar la verificación de integración prevista. Si el cambio cruza componentes o contratos, encargar además una revisión independiente del conjunto; no duplicar revisiones completas para un cambio mecánico. Si falla el cierre, registrar el bloqueo en tasks y no declarar terminado ni deshacer commits válidos automáticamente.

Actualizar el estado global a Terminado sólo tras cerrar correctamente. Responder con resultado, commits, pruebas y limitaciones reales. Ofrecer los comandos listos de integración/cierre post-merge con verificación (merge, eliminación de worktree/rama y comandos de verificación) listos para copiar o ejecutar a pedido, sin forzar su ejecución interactiva. No crear diario, handoff, mensajes Jira/MR ni auditorías adicionales. Push, PR, merge, despliegues y publicaciones necesitan una petición que los autorice; no ejecutarlos automáticamente ni forzar prompts interactivos para realizarlos.
