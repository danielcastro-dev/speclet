---
name: merge-risk
description: Assess the risk of merging a pull request or branch before merge. Evaluates alignment, impact/blast radius, verification, rollback cost, and error detection with weighted scoring.
license: MIT
metadata:
  workflow: delivery
  phase: review
  credits:
    derived_from: "warpdotdev/common-skills"
    original_concept: "Matt Pocock / Dex Horthy"
    url: "https://github.com/warpdotdev/common-skills/tree/main/.agents/skills/merge-risk"
---

# Merge Risk (`merge-risk`)

Use when assessing the risk of merging a pull request or branch into `main`/target branch. Evaluates blast radius, reversibility, test verification, error detection, and scope creep with weighted scoring.

## Language and Communication Rules

- **Always speak, explain, and interact with the user in Spanish.**
- **Present category findings in Spanish** (or repo convention), preserving standard engineering terms (*"blast radius"*, *"one-way door"*, *"two-way door"*, *"drive-by"*).
- Be direct, succinct, and anti-AI-slop: bullet points, no conversational filler.

---

## Output Format

```markdown
**Merge risk: <low | medium | high>**

**<categoría>:** <veredicto>
- <detalle conciso de los gaps o riesgos detectados con enlaces a archivos si aplica>
```

---

## Evaluation Categories & Low-Risk Criteria

1. **Alignment / Alineación (`poor ⚠️` / `decent 👀` / `good ✅`):**
   - El código se alinea estrictamente con la descripción del PR y el ticket origen (Jira/Issue).
   - Sin cambios "de contrabando" (*drive-bys*) o supuestos no documentados.

2. **Impact & Blast Radius (`large ⚠️` / `medium 👀` / `small ✅`):**
   - El alcance está acotado y lejos de caminos críticos.
   - Las áreas sensibles conllevan alto riesgo sin importar el tamaño del diff: **auth, permisos, pagos, PII/datos sensibles, secretos, migraciones de base de datos, actualización de dependencias y cambios de infraestructura**.
   - Señalar cualquier cambio que ensanche accesos, debilite validaciones o loguee datos sensibles.

3. **Verification / Verificación (`poor ⚠️` / `decent 👀` / `good ✅`):**
   - El comportamiento está verificado con evidencia irrefutable (tests automáticos, exit code 0, o screenshots antes/después en UI).
   - Casos borde cubiertos con tests discriminantes o documentados con razonamiento técnico.

4. **Rollback Cost / Costo de Revertir (`high ⚠️` / `medium 👀` / `low ✅`):**
   - Puertas de una vía (*one-way door*): cambios destructivos, alteración de esquemas sin compatibilidad hacia atrás o eliminación de datos = alto riesgo.
   - Puertas de dos vías (*two-way door*): cambios fácilmente reversibles con `git revert` = bajo riesgo.

5. **Error Detection / Observabilidad (`poor ⚠️` / `decent 👀` / `good ✅` / `N/A ✅`):**
   - Si el cambio falla en producción, ¿existen logs estructurados, métricas o alertas que avisen al equipo antes de que los usuarios lo reporten?
   - Identificar errores tragados (*swallowed errors*) o fallbacks silenciosos que oculten fallos.

---

## Scoring System (Internal Calculation)

Verdicts:
- ⚠️ = 3
- 👀 = 2
- ✅ = 1

Weights:
- **Impact** = 2x
- **Verification** = 2x
- **Rollback cost** = 1.5x
- **Error detection** = 1x
- **Alignment** = 1x

**Formula:**
`Score = Σ(veredicto × peso) / Σ(pesos)` (Suma de pesos = 7.5)

- **Low risk:** Score < 1.5
- **Medium risk:** 1.5 ≤ Score < 2.25
- **High risk:** Score ≥ 2.25

*Mantén el cálculo numérico interno; presenta únicamente el veredicto final (`low`, `medium` o `high`) y los bullets explicativos por categoría.*
