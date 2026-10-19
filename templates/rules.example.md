# Reglas del Proyecto (rules.md)

Este archivo define las reglas arquitectónicas, de modelado de datos y convenciones de código **no negociables** para este repositorio.
Los agentes y desarrolladores deben consultar y respetar estas directrices en `speclet-draft`, `speclet-plan` y `speclet-loop`. Puede generarse o actualizarse mediante `$speclet-rules`.

---

## 1. Código y Reutilización (Filosofía Ponytail)

- **No duplicar lógica:** Antes de escribir una función o algoritmo nuevo, inspeccionar si ya existe un helper, servicio o utilidad equivalente en el proyecto.
- **Extraer helpers limpios:** Si un patrón o cálculo se utiliza en dos o más lugares, extraer un helper reutilizable, bien tipado y testeable, en vez de copiar y pegar código.
- **Simplicidad ante todo:** No introducir abstracciones prematuras ni librerías externas si se puede resolver limpiamente con las dependencias existentes.
- **Tipado estricto:** Prohibido el uso de tipos genéricos sin verificar (`any` o casts ciegos).

---

## 2. Base de Datos y Persistencia

- **Primary Keys (PK):** Todas las tablas/entidades deben contar con PK inmutable (`UUIDv7` o entero autoincremental según el stack).
- **Foreign Keys (FK) e Integridad:**
  - Toda relación entre entidades debe tener FK explícita a nivel de base de datos.
  - Definir la acción de borrado (`ON DELETE RESTRICT` o `CASCADE` según corresponda al dominio).
- **Índices obligatorios:**
  - Crear índices en todas las columnas utilizadas como FK.
  - Crear índices compuestos en combinaciones frecuentes de filtros `WHERE` o cláusulas de ordenación (`ORDER BY`).
  - Justificar cualquier escaneo secuencial en tablas con más de 10.000 registros.
- **Transaccionalidad:** Cualquier operación que modifique más de una tabla debe ejecutarse dentro de una transacción atómica (`BEGIN/COMMIT/ROLLBACK`).
- **Auditoría:** Todas las tablas de negocio deben incluir `created_at` y `updated_at` automáticos.

---

## 3. APIs, Red y Seguridad

- **Contrato de API uniforme:** Todo endpoint debe responder con un esquema consistente de payload (ej: `{ success: true, data: ... }` o `{ success: false, error: { code, message } }`).
- **Seguridad y Redacción:**
  - Nunca loguear contraseñas, tokens JWT, tarjetas de crédito ni variables de entorno sensibles.
  - Sanitizar o redactar payloads en middlewares de logging.
- **Manejo de Errores y Health:**
  - No silenciar excepciones (`catch (e) {}` vacío).
  - Incluir endpoints de `/health` o `/ready` que verifiquen dependencias críticas (DB, colas).

---

## 4. Testing y Verificación

- Seguir TDD: Escribir o identificar la prueba que falla antes de dar por concluida la implementación.
- La evidencia manda: Ninguna tarea se marca como completada sin comando de verificación real y su salida exitosa.
