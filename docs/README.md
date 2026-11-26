# Índice del repositorio por sesión

Todos los archivos versionados de SecureBank API, ordenados según la sesión del curso que los pide o los usa. SecureBank es un **caso hipotético**: el código de `src/` existe solo para que las herramientas de seguridad tengan algo sobre qué correr. El estado de cada fallo está en el [README principal](../README.md).

## Base del proyecto (transversal)

| Archivo | Qué es |
|---|---|
| [README.md](../README.md) | Portada: los 9 fallos, qué arregla cada sesión, pendientes y flujo de ramas |
| [docs/CHECKLIST.md](CHECKLIST.md) | Checklist ítem por ítem de cada presentación (S1–S13) contra el repo: qué cumple y qué falta |
| [docs/architecture.md](architecture.md) | Arquitectura hipotética: componentes, módulos, red cloud, límites de confianza y superficie de ataque |
| [docs/img/Flujo.png](img/Flujo.png) | Diagrama del flujo de ramas Git que usa el README |
| [requirements.txt](../requirements.txt) | Dependencias Python con versión exacta (flask, bcrypt, gunicorn, PyJWT, pytest, pytest-cov) |
| [package.json](../package.json) · [package-lock.json](../package-lock.json) | Proyecto Node mínimo que usa el job `build` (de relleno, viene de S4) |
| [.gitignore](../.gitignore) | Excluye `.env`, llaves, estado de Terraform y `material-curso/` |

### Código de ejemplo (`src/`)

| Archivo | Qué hace | Sesión que lo endurece |
|---|---|---|
| [src/app.py](../src/app.py) | `create_app()`: registra blueprints, `/health` y cabeceras de seguridad | S8 |
| [src/config.py](../src/config.py) | Lee secretos desde env y falla si faltan o son débiles | S7 |
| [src/auth/auth.py](../src/auth/auth.py) | Hash y verificación de contraseñas con bcrypt (antes MD5) | S5 |
| [src/auth/tokens.py](../src/auth/tokens.py) | Emite y valida JWT (HS256 fijo, `exp` y `sub` obligatorios) | S8 |
| [src/auth/middleware.py](../src/auth/middleware.py) | `require_auth` (401) y `require_owner` (403 + log de auditoría) | S8 |
| [src/users/users.py](../src/users/users.py) | `POST /login` con SQL parametrizado y `GET /users/<id>` protegido contra BOLA | S5, S8 |
| [src/accounts/view.py](../src/accounts/view.py) · [templates/welcome.html](../src/accounts/templates/welcome.html) | `GET /welcome` con autoescape de Jinja (antes XSS) | S5 |
| [src/transfers/calc.py](../src/transfers/calc.py) | `POST /rate` con evaluador AST (antes `eval`) | S5 |
| [src/transfers/export.py](../src/transfers/export.py) | `GET /export` con lista blanca y `shell=False` (antes command injection) | S5 |
| `src/*/README.md` | Descripción de cada módulo y su relación con el threat model | S3 |

## S1 · Introducción a DevSecOps

| Archivo | Qué es |
|---|---|
| [sesion-01-ciclo/ciclo-devsecops.md](sesion-01-ciclo/ciclo-devsecops.md) | **Entregable:** diagrama del ciclo de 8 fases con herramienta y responsable por fase |

## S2 · Git y repositorios seguros

| Archivo | Qué es |
|---|---|
| [sesion-02-repos/POL-REPO-001.md](sesion-02-repos/POL-REPO-001.md) | **Entregable:** política de repositorios seguros (R.01–R.07, roles, matriz y excepciones) |
| [.github/CODEOWNERS](../.github/CODEOWNERS) | Revisores obligatorios (hoy solo globales) |

## S3 · Threat Modeling

| Archivo | Qué es |
|---|---|
| [sesion-03-threat-model/threat-model.md](sesion-03-threat-model/threat-model.md) | **Entregable:** STRIDE T01–T10, DFD con fronteras de confianza y Security Stories SS01–SS10 |

## S4 · CI/CD

| Archivo | Qué es |
|---|---|
| [.github/workflows/ci.yml](../.github/workflows/ci.yml) | **Entregable:** pipeline principal. Crece en cada sesión: secret-scan → build → sast/sca/coverage → dast → gate |
| [sesion-04-ci/pipeline.md](sesion-04-ci/pipeline.md) | Explicación del pipeline y de sus etapas |

## S5 · SAST

| Archivo | Qué es |
|---|---|
| [sesion-05-sast/README.md](sesion-05-sast/README.md) | **Entregable:** resumen, tabla OWASP, diff de cada corrección y justificación del job |
| [sesion-05-sast/sast-before.sarif.zip](sesion-05-sast/sast-before.sarif.zip) | **Entregable:** Semgrep antes de corregir (10 hallazgos) |
| [sesion-05-sast/sast-after.sarif.zip](sesion-05-sast/sast-after.sarif.zip) | **Entregable:** Semgrep después de corregir (0 hallazgos) |
| [tests/unit/test_transfers_auth_views.py](../tests/unit/test_transfers_auth_views.py) | Tests que demuestran cada corrección (eval, export, XSS, bcrypt, config) |

## S6 · SCA y SBOM

| Archivo | Qué es |
|---|---|
| Job `sca` en [ci.yml](../.github/workflows/ci.yml) | Trivy sobre las dependencias → `sca.json` (lo evalúa el gate) |
| [reports/securebank-sbom.cdx.json](../reports/securebank-sbom.cdx.json) | **Entregable:** SBOM CycloneDX 1.5 (18 componentes, PURL, licencias) |
| [reports/securebank-vulns.html](../reports/securebank-vulns.html) · [.json](../reports/securebank-vulns.json) | **Entregable:** 17 avisos con CVSS y semáforo; corrección PyJWT → 0 CVE |
| [reports/README.md](../reports/README.md) | Cómo se generaron y política CVSS |
| [tests/security/test_dependencias.py](../tests/security/test_dependencias.py) | Test de pip-audit (comentado: necesita red y la herramienta) |

## S7 · Gestión de secretos

| Archivo | Qué es |
|---|---|
| [.gitleaks.toml](../.gitleaks.toml) | Reglas de Gitleaks + regla propia `securebank-hardcoded-password` |
| [.pre-commit-config.yaml](../.pre-commit-config.yaml) | Hook que corre Gitleaks antes de cada commit |
| Job `secret-scan` en [ci.yml](../.github/workflows/ci.yml) | Escanea todo el historial y falla si encuentra un secreto |
| [SECRETS.md](SECRETS.md) | **Entregable:** inventario, alternativas, Gitleaks, rotación, respuesta y evidencia (§1–§6) |
| [.env.example](../.env.example) | Plantilla de variables de entorno sin valores reales |

## S8 · DAST y seguridad de APIs

| Archivo | Qué es |
|---|---|
| [sesion-08-dast/README.md](sesion-08-dast/README.md) | Guía del laboratorio ZAP y diagnóstico de BOLA |
| [sesion-08-dast/reporte-dast.md](sesion-08-dast/reporte-dast.md) | **Entregable (sección 1):** reporte ZAP (tabla antes/después ilustrativa, a reemplazar por el scan real) |
| [sesion-08-dast/plan-mitigacion.md](sesion-08-dast/plan-mitigacion.md) | **Entregable (sección 2):** plan por hallazgo con responsable, plazo y verificación |
| [docker-compose.dast.yml](../docker-compose.dast.yml) | Entorno efímero: imagen v2, `read_only`, `cap_drop: ALL`, BD en tmpfs |
| [lab/dast/seed.py](../lab/dast/seed.py) | Crea a Alice (100) y Bob (101) con contraseñas por variable de entorno |
| [tests/security/test_bola.py](../tests/security/test_bola.py) | Verifica 401 sin token, 403 a un recurso ajeno y las cabeceras de seguridad |
| [tests/conftest.py](../tests/conftest.py) | Secretos efímeros para pytest |

## S9 · Quality Gates y Policy as Code

| Archivo | Qué es |
|---|---|
| [sesion-09-quality-gates/README.md](sesion-09-quality-gates/README.md) | Guía de la sesión y caso de debate #482 |
| [policy/security-policy-v1.rego](../policy/security-policy-v1.rego) | **Entregable:** la política (umbrales, KEV, contexto de riesgo, falla cerrada) |
| [policy/security-policy-v1_test.rego](../policy/security-policy-v1_test.rego) | 20 pruebas `opa test` |
| [policy/README.md](../policy/README.md) | **Entregable:** justificación de cada umbral |
| [scripts/consolidate_findings.py](../scripts/consolidate_findings.py) | Une Gitleaks, Semgrep, Trivy, ZAP y la cobertura en `findings.json` |
| [scripts/gate.sh](../scripts/gate.sh) | Ejecuta OPA y devuelve exit 0 (DEPLOY) o 1 (BLOCK) |
| [config/security-context.json](../config/security-context.json) | Criticidad y exposición; sin mitigaciones declaradas, porque el WAF y el rate limiting no existen |
| [tests/policy/fixtures/](../tests/policy/fixtures/) | `green.json` (pasa), `red.json` (bloquea), `debate-482.json` |
| [tests/unit/test_consolidate_findings.py](../tests/unit/test_consolidate_findings.py) | Pruebas del consolidador |

## S10 · Contenedores y Docker

| Archivo | Qué es |
|---|---|
| [docker/Dockerfile.v1](../docker/Dockerfile.v1) | Imagen insegura a propósito (root, `COPY .`, puerto 22) |
| [docker/Dockerfile.v2](../docker/Dockerfile.v2) | **Entregable:** imagen endurecida (slim con tag fijo, uid 10001, tini) |
| [docker/REPORT.md](../docker/REPORT.md) | **Entregable:** comparativo Trivy v1 vs v2 y riesgos residuales |
| [.dockerignore](../.dockerignore) | Deja fuera de la imagen los secretos, los tests, los docs y la infraestructura |

## S11 · IaC y Cloud Security

| Archivo | Qué es |
|---|---|
| [infra/terraform/](../infra/terraform/) | **Entregable:** stack AWS (VPC, EC2, RDS, S3, KMS, IAM con OIDC, CloudTrail, ALB, ECR) |
| [infra/README.md](../infra/README.md) | Cómo probarlo, variables del pipeline y checks omitidos con motivo |
| [.github/workflows/iac.yml](../.github/workflows/iac.yml) | **Entregable:** scan (Checkov) → validate → plan → apply con aprobación |
| [sesion-11-iac/checkov-after.json](sesion-11-iac/checkov-after.json) | **Entregable:** Checkov final (307 aprobados, 0 fallidos) |
| [sesion-11-iac/informe-iac.md](sesion-11-iac/informe-iac.md) | **Entregable:** informe técnico (before ilustrativo, top 5 hallazgos, prueba de bloqueo) |

## S12 · Kubernetes

| Archivo | Qué es |
|---|---|
| [k8s/hardened/deployment.hardened.yaml](../k8s/hardened/deployment.hardened.yaml) | **Entregable:** Deployment con los controles de securityContext, digest y `secretKeyRef` |
| [k8s/hardened/hardening.notes.md](../k8s/hardened/hardening.notes.md) | Hallazgos M1–M5 y explicación de cada cambio |

## S13 · Software Supply Chain

| Archivo | Qué es |
|---|---|
| [.github/workflows/supply-chain.yml](../.github/workflows/supply-chain.yml) | **Entregable:** build → digest → SBOM (Syft) → `cosign sign/attest/verify` |
| [docker/Dockerfile.s13](../docker/Dockerfile.s13) | Imagen alpine de prueba (ya no se usa: el workflow firma `Dockerfile.v2`) |
| [sesion-13-supply-chain/reporte-s13.md](sesion-13-supply-chain/reporte-s13.md) | Registro de lo hecho y de los problemas resueltos |
| [sesion-13-supply-chain/supply_chain_analisis.md](sesion-13-supply-chain/supply_chain_analisis.md) | **Entregable:** análisis de 1 página (firma, digest y admission controller) |
| [sesion-13-supply-chain/captura_verificar-firma.PNG](sesion-13-supply-chain/captura_verificar-firma.PNG) | Evidencia del bloqueo de `cosign verify` |
| [sesion-13-supply-chain/sbom.zip](sesion-13-supply-chain/sbom.zip) | SBOM CycloneDX generado por el pipeline |

## Carpetas reservadas

- [tests/integration/](../tests/integration/README.md): solo tiene un README. Está pensada para pruebas de integración y hoy no tiene tests.
