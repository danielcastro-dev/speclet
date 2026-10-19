---
name: speclet-plan
description: Convertir un spec.md aprobado de Speclet en un plan técnico mínimo y tareas Markdown verificables. Usar después de acordar requisitos; no implementa código ni crea JSON o manuales.
license: MIT
metadata:
  workflow: speclet
  phase: planning
---

# Speclet Plan

Decidir **cómo construir el cambio** y dividirlo en tareas ejecutables sin inventar requisitos.

## Entrada y enfoque

Resolver `.speclet/changes/<nombre>/spec.md` desde la ruta indicada. Sin ruta, elegir el único spec aprobado cuyo cambio no esté terminado; si hay varios, preguntar. No seleccionar estado del workflow anterior.

Leer spec, instrucciones aplicables, implementaciones, consumidores, pruebas y comandos reales. Cargar `ponytail` y `caveman` desde sus entrypoints instalados: simplicidad para el enfoque y concisión sólo para el chat en español. La activación prestada termina al salir de Speclet, sin apagar un modo previo activado expresamente por el usuario. No abreviar documentos ni preguntas.

Si falta aprobación del spec, resolverla mediante `$speclet-draft`, sin inventarla. Reutilizar decisiones autorizadas y preguntar sólo por nuevas disyuntivas materiales. Investigar externamente cuando falte información necesaria o se haya solicitado.

## Plan técnico

Escribir `plan.md` junto al spec, sin repetir su aceptación:

```markdown
# Plan técnico
Spec: spec.md
Estado: Propuesto

## Enfoque y decisiones
Implementación mínima, reutilización y contratos afectados.

## Ejecución
Repositorio(s), base/rama conocida y worktree propuesto, sujeto a consulta.
Documentos Speclet locales; código y pruebas en commits por tarea.

## Verificación y riesgos
Comandos encontrados y comportamiento que validan; límites del entorno.
Riesgos pertinentes y mitigación; basal pendiente hasta ejecutarlo realmente.

## Focos de revisión y casos límite
Puntos críticos de inspección, casos límite (entradas vacías/extremas, fallos de borde o condiciones de error); cada uno vinculado obligatoriamente a tareas con tests en tasks.md.

## Aprobación
Autorización real existente o decisiones pendientes antes de ejecutar.
```

Precisar firmas, esquemas o secuencias donde la coordinación lo necesite. No crear abstracciones, dependencias u opciones para un futuro hipotético. Fijar los contratos de fallo necesarios dentro del plan y los AC, sin manuales independientes.

No instalar paquetes, crear worktrees, editar código ni mutar servicios durante la planificación. Ejecutar pruebas de lectura sólo si aclaran una incertidumbre; registrar únicamente evidencia real.

## Tareas ejecutables

Escribir `tasks.md` con estado global Pendiente y una lista ordenada por dependencias. Cada tarea produce un comportamiento o contrato comprobable:

```markdown
# Tareas
Estado: Pendiente
Tarea activa: ninguna

- [ ] T01 — Resultado concreto
  - Depende de: ninguna
  - Aceptación: AC-01 de spec.md / Foco o caso límite de plan.md
  - Archivos: rutas reales afectadas
  - Verificación: comando y resultado observable esperado
  - Evidencia, revisión y commit: pendientes
```

- Cada AC y cada foco de revisión o caso límite debe estar cubierto obligatoriamente por una tarea y verificación con tests. Registrar límites no verificables antes de ejecutar, sin prometer cobertura ficticia.
- Incluir pruebas junto al cambio; no tests que sólo reflejen la implementación o prueben que algo se ejecutó.
- Una tarea consumidora debe conocer los contratos que produce su dependencia cuando admitan varias interpretaciones.
- Dependencias y orden de la lista bastan: no imponer prioridades, quality budgets, sesiones, catálogos ni estados JSON.
- Si se actualiza un plan en curso, conservar tareas cerradas y su evidencia. Un cambio material de alcance necesita aprobación antes de ejecutar.
- Mantener los tres Markdown locales mediante la exclusión establecida por draft. No crear baseline, progress, reviews, diary o handoff separados.

## Salida

Entregar enlaces al plan/tareas y decisiones pendientes. La petición explícita de ejecutar `$speclet-loop` sobre un plan completo lo autoriza, sin otra confirmación equivalente. La creación o cambio de worktree sigue requiriendo la consulta separada del loop.

No crear un cuarto documento de diseño: requisitos en spec, enfoque en plan y avance/evidencia en tasks. No leer, migrar ni borrar documentos de proyectos del workflow anterior.
