---
name: speclet-jira
description: Preparar historias o mensajes Jira breves desde un pedido o un cambio Speclet Markdown, sólo cuando se soliciten. No implementa código ni publica en Jira automáticamente.
license: MIT
metadata:
  workflow: speclet
  phase: optional-handoff
---

# Speclet Jira

Preparar una historia entendible o comunicar resultados con evidencia real. Es opcional: el loop no genera mensajes Jira por defecto.

## Entrada

- Usar el pedido y la ruta del cambio indicada. Leer `spec.md` y sólo lo necesario de `plan.md` y `tasks.md`.
- Si hay varios cambios candidatos, pedir elegir. Sin contexto Speclet, preparar la historia desde el pedido sin obligar a iniciar el workflow.
- Cargar expresamente `caveman` para abreviar sólo el chat en español. La activación prestada termina al salir de Speclet; respetar modos previos activados expresamente por el usuario. Redactar tickets y preguntas en lenguaje normal.
- Preguntar sólo por datos que cambien destinatario, alcance o aceptación. No imponer entrevista, clave Jira ni separación frontend/backend cuando no corresponda.

## Historia o mensaje

Para una historia nueva: título concreto, problema/resultado, alcance y criterios observables. Separar frontend/backend sólo si hay entregables independientes. No copiar detalles internos del plan que no ayuden al lector.

Para una entrega: comportamiento implementado, pruebas ejecutadas, commits y pendientes reales. Distinguir terminado, bloqueado y no verificado. Contrastar evidencia; una casilla marcada no demuestra que una prueba pasó.

## Salida y límites

Por defecto, entregar el texto en el chat. Escribir archivo sólo cuando se solicite una ruta. No generar directorios de handoff, mensajes MR ni otros informes automáticamente.

Redactar no autoriza publicar. Usar herramientas para crear o modificar tickets sólo cuando el usuario solicite esa acción y el destino sea claro. No enviar secretos ni información operativa sensible.

No leer, convertir, mover ni borrar documentos del workflow anterior.
