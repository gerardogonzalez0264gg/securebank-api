# Security Policy v1.0 · SecurePipeline

Entregable de la Sesión 9: `security-policy-v1.rego` + este README. Motor: **OPA + Rego** (`import rego.v1`, OPA 1.9.0).

La política decide, en cada build, si SecureBank API puede avanzar (`DEPLOY`) o no (`BLOCK`). Es **medible** (números y booleanos), **automática** (el job `gate` falla con `exit 1`), **versionable** (vive en el repo y cambia por PR) y **auditable** (cada ejecución guarda `findings.json` + `gate-result.json`).

## Entrada y salida

| | Archivo | Origen |
|---|---|---|
| Entrada | `findings.json` | `scripts/consolidate_findings.py` (Gitleaks · Semgrep · Trivy · ZAP · coverage + `config/security-context.json`) |
| Salida | `data.securepipeline.gate.result` | `{allow, decision, deny[], limits, risk_context, meta}` |

## Umbrales y justificación

| Regla | Umbral | Justificación |
|---|---|---|
| Secrets | `= 0` | Un secreto filtrado se considera comprometido aunque se borre del código: queda en el historial (POL-REPO-001 R.01). No hay deuda aceptable. |
| Critical en código propio (SAST + DAST) | `= 0` | Explotación remota trivial o impacto total. En un banco no se acepta ninguna. |
| Critical en dependencias (SCA) | `= 0` sin compensating controls · `<= 3` con WAF **y** rate limiting | Deuda de terceros acotada solo si hay controles que la mitiguen. **Desvío respecto de la Sesión 9 (Critical = 0); ver «Decisiones a revisar».** |
| High en código propio (SAST + DAST) | `= 0` | Lo escribimos nosotros, así que lo corregimos nosotros. Aceptarlo sería deuda voluntaria. |
| High en dependencias (SCA) | base `2` en contexto estricto · `4` si no · `+4` con compensating controls (máx. 6 o 8) | Es deuda de terceros: a veces no hay parche disponible. Se tolera una cantidad acotada que crece cuando el activo es menos crítico/expuesto o está mitigado. |
| Medium (suma de scanners) | `<= 10` si hay exposición a Internet · `<= 15` si no | Evita la «fatiga de gate» (bloquear por ruido) sin dejar que se acumule deuda. Más estricto con exposición pública. |
| Coverage | `>= 80 %` | Sin pruebas, cualquier corrección futura es incierta. Hoy el repo mide ~99 %, así que el umbral deja margen real para detectar regresiones. |
| CVE en CISA KEV | `= 0` | Exploitability real: un Medium con exploit activo pesa más que un High teórico. |
| Scanner ausente | bloquea | **Falla cerrada:** si un reporte no llega, nunca se asume «0 hallazgos». |

## Criterios de riesgo (la política evalúa riesgo, no solo severidad)

Riesgo = Criticidad × Exposición × Exploitability ÷ Compensating controls. Los datos viven en `config/security-context.json`:

| Criterio | Campo | Efecto en la política |
|---|---|---|
| Contexto de negocio | `business_criticality` (`high`/`critical`) | Junto con la exposición, activa el contexto estricto |
| Exposición | `exposure_level` (`internet`) | Contexto estricto: SCA High base `2`, Medium `<= 10` |
| Exploitability real | `kev` (catálogo CISA) | Cualquier CVE listado bloquea |
| Compensating controls | `mitigations` (`waf` **y** `rate_limiting`) | Suman 4 al límite de SCA High y permiten hasta 3 SCA Critical |

Si el contexto no llega, se asume el más estricto. **Declarar un control que no existe es relajar el gate con una mentira:** por eso cualquier cambio a `config/security-context.json` debe aprobarlo el Lead de seguridad (R.02).

## Pruebas

```bash
opa fmt --diff policy/ && opa check --strict policy/
opa test policy/ -v          # 20 pruebas
```

Casos del entregable (`tests/policy/fixtures/`):

| Caso | Archivo | Resultado |
|---|---|---|
| Pasa | `green.json` | `DEPLOY` (exit 0) |
| Bloquea | `red.json` | `BLOCK` (exit 1): secreto, SAST Critical, SCA High, coverage |
| Debate #482 | `debate-482.json` | `BLOCK`: 3 High y 12 Medium sin compensating controls |

```bash
scripts/gate.sh tests/policy/fixtures/green.json   # exit 0
scripts/gate.sh tests/policy/fixtures/red.json     # exit 1
```

## Auditabilidad

Cada ejecución del job `gate` sube el artefacto `gate-evidence-<sha>` (90 días) con la entrada consolidada, la decisión, la regla violada y el commit/branch/build. La versión de la política queda en `policy_version` y en el historial de Git.

## Excepciones

La v1.0 no tiene waivers: no hay reglas «de aviso» ni bypass en el pipeline. Una excepción se tramita como PR a esta política, con motivo, riesgo y duración máxima de 30 días (POL-REPO-001 §5), aprobado por el Lead de seguridad y un Code Owner.

## Mapeo con la rúbrica

| Criterio | Dónde |
|---|---|
| Claridad (25 %) | Reglas `deny` con mensaje explícito y valores reales |
| Justificación de umbrales (25 %) | Tablas de este README |
| Pruebas automáticas (30 %) | `security-policy-v1_test.rego` (20) + `tests/unit/test_consolidate_findings.py` |
| Auditabilidad (20 %) | `result`, artefacto `gate-evidence-<sha>`, política versionada |

## Decisiones a revisar

`config/security-context.json` declara hoy `mitigations: ["waf", "rate_limiting"]`. Eso suma 4 High al límite y habilita hasta 3 SCA Critical. Antes de aceptarlo, verifica que ambos controles existan de verdad: en `infra/terraform/alb.tf` el WAF está explícitamente omitido (`checkov:skip=CKV2_AWS_28`, «pertenece a la etapa Operate»), y `src/` no implementa rate limiting. Mientras no estén desplegados, la declaración relaja el gate sin respaldo. Además, permitir SCA Critical contradice la regla de la Sesión 9 («Critical = 0»).

Regla práctica: si cambias umbrales en el `.rego`, actualiza `security-policy-v1_test.rego` en el mismo commit; `scripts/gate.sh` no decide con una política cuyos tests fallan.
