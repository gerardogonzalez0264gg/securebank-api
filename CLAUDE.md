# CLAUDE.md · SecureBank API

> Contexto para la IA que edite este repo. Léelo completo antes de tocar código o docs.
> Proyecto académico de DevSecOps (trabajo grupal). Idioma de todo: **español**.
> Última revisión completa: 2026-11-25 sobre `main` (30 tests pasan con `pytest`).

---

## 1. Qué es el proyecto

**Caso hipotético.** SecureBank no es una API real. La Sesión 1 plantea los **9 fallos** que tendría una API
bancaria sin seguridad (ver §4A), y cada sesión (S2–S13) aplica la herramienta o el control que los corregiría *si
la API existiera*. El código de `src/` es un ejemplo mínimo para que las herramientas tengan algo sobre qué correr.
**No propongas construir funcionalidades de una API real** (`/transfer`, MFA, cuentas, etc.) como pendientes: el
avance se mide por los controles y entregables del curso, no por las features.

- **Stack:** Python 3.11 + Flask 3.1, bcrypt, PyJWT, gunicorn, SQLite. Node solo se usa para el job `build` del CI (de relleno).
- **Contenedor:** `docker/Dockerfile.v1` (inseguro a propósito), `docker/Dockerfile.v2` (endurecido, el que se usa en DAST), `docker/Dockerfile.s13` (alpine de relleno para S13). No hay Dockerfile en la raíz.
- **CI:** `.github/workflows/ci.yml` (secret-scan → build/sast/sca/coverage → dast → gate OPA), `iac.yml` (Checkov + Terraform), `supply-chain.yml` (GHCR + Syft + Cosign).
- **Material del curso:** `material-curso/` (las 13 presentaciones `.pptx`, en `.gitignore`). Leerlas con `zipfile` + regex sobre `ppt/slides/slide*.xml`.
- **Rama de trabajo:** `feature/*` → PR a `develop` → PR a `main`. Nunca push directo a `main` (ver `docs/sesion-02-repos/POL-REPO-001.md`).
- **Resumen público del estado:** `README.md` (secciones "Los 9 fallos", "Qué arregla cada sesión", "Detalles pendientes"). Si cambias un estado aquí, cámbialo también allá.

## 2. Cómo debe trabajar la IA (reglas)

1. **Trabaja por problema, no por archivo.** Cada cambio debe colgar de un problema de la sección 4. Si no encaja, propón agregarlo a la lista.
2. **Al terminar un cambio, actualiza este archivo y el README:** marca el check `[x]`, ajusta "Estado" y la tabla de archivos del problema. Es la fuente de verdad del avance.
3. **No inventes avance.** Marca `[x]` solo si el código/documento existe en el repo. Si es a medias, usa `[~]`. Si falta, `[ ]`.
4. **Nunca pongas secretos en el código** (R.01). Todo va por variables de entorno (`src/config.py`). Los ejemplos en docs usan placeholders tipo `${DB_PASSWORD}`.
5. **Mantén los patrones seguros ya aplicados:** consultas parametrizadas, `shell=False` + lista blanca, `_safe_eval` con AST, bcrypt, plantillas Jinja con autoescape, `require_owner`, JWT con `algorithms=["HS256"]`. No los reemplaces por atajos.
6. **Commits en Conventional Commits** (`feat:`, `fix:`, `docs:`, `ci:`, `test:`). Un problema por PR cuando se pueda.
7. **Cada control nuevo lleva evidencia:** un test en `tests/` y/o una nota en `docs/`. Sin evidencia no cuenta como resuelto.
8. **Estilo:** código simple y corto, comentarios en español, sin dependencias nuevas salvo que haga falta (fijar versión exacta en `requirements.txt`).
9. Si algo es ambiguo (número de clase, responsable, fecha), **pregunta o deja `TODO(equipo)`**, no lo supongas.

## 3. Mapa del repo

```
src/
  app.py                  create_app(): blueprints, /health, cabeceras de seguridad (CSP, HSTS, XFO, nosniff)
  config.py               Settings desde env: JWT_SECRET (≥32), JWT_TTL_MINUTES (1-60), DATABASE_URL
  auth/auth.py            hash_password / verify_password (bcrypt)
  auth/tokens.py          issue_token / decode_token (HS256 fijo, exp y sub obligatorios)
  auth/middleware.py      require_auth (401) y require_owner (403 + log securebank.audit)
  users/users.py          POST /login (SQL parametrizado, entrega access_token), GET /users/<id> (BOLA protegido)
                          OJO: usa env SECUREBANK_DB, no DATABASE_URL
  accounts/view.py        GET /welcome (plantilla con autoescape)
  transfers/calc.py       POST /rate (evaluador AST seguro, sin eval)
  transfers/export.py     GET /export?f= (lista blanca, subprocess sin shell)
tests/
  conftest.py             secretos efímeros para pytest
  unit/                   test_transfers_auth_views.py, test_consolidate_findings.py
  security/test_bola.py   401 sin token, 403 a recurso ajeno, cabeceras
  policy/fixtures/        green.json, red.json, debate-482.json (entradas del gate)
policy/                   security-policy-v1.rego + _test.rego (20 tests OPA) + README
scripts/                  consolidate_findings.py (une reportes → findings.json), gate.sh (OPA, exit 0/1/2)
config/security-context.json   criticidad, exposición y mitigaciones declaradas (alimenta el gate)
lab/dast/seed.py          siembra alice=100, bob=101 (claves por env)
docker-compose.dast.yml   entorno efímero para ZAP (v2, read_only, cap_drop ALL, tmpfs)
docker/                   Dockerfile.v1, Dockerfile.v2, Dockerfile.s13, REPORT.md (Trivy v1 vs v2)
infra/terraform/          stack AWS (67 recursos: VPC, EC2, RDS, S3, KMS, IAM OIDC, CloudTrail, ALB, ECR)
k8s/hardened/             deployment.hardened.yaml + hardening.notes.md
docs/                     README.md (ÍNDICE de todos los archivos por sesión), architecture.md, img/Flujo.png
  sesion-01-ciclo/        ciclo-devsecops.md
  sesion-02-repos/        POL-REPO-001.md (política R.01–R.07, roles, matriz)
  sesion-03-threat-model/ threat-model.md
  sesion-04-ci/           pipeline.md
  sesion-05-sast/         sast-before/after.sarif.zip
  sesion-08-dast/         README.md, reporte-dast.md, plan-mitigacion.md
  sesion-09-quality-gates/README.md
  sesion-11-iac/          checkov-after.json
  sesion-13-supply-chain/ reporte-s13.md, supply_chain_analisis.md, captura, sbom.zip
.github/                  workflows/{ci,iac,supply-chain}.yml, CODEOWNERS
.gitleaks.toml, .pre-commit-config.yaml, .gitignore, .dockerignore
material-curso/           presentaciones .pptx de las 13 sesiones (en .gitignore, no se versiona)
(no existen todavía: reports/, docs/SECRETS.md, .env.example, checkov-before.json)
```

**Regla de orden:** la evidencia de una sesión nueva va en `docs/sesion-XX-tema/` y se agrega al índice
`docs/README.md`. Excepción: rutas que exige la rúbrica del curso → `docker/` (S10), `k8s/hardened/` (S12),
`reports/` (S6), `docs/SECRETS.md` (S7), `.github/workflows/iac.yml` (S11). Esas no se mueven.

Variables de entorno para arrancar: `JWT_SECRET`, `DATABASE_URL` (y opcionales `JWT_TTL_MINUTES`, `SECUREBANK_DB`).

---

## 4A. Los 9 fallos deliberados de la Sesión 1 (slide 2)

| # | Fallo | OWASP (slide 12) | Sesiones | Problemas | Estado |
|---|---|---|---|---|---|
| 1 | Credenciales en el código | A02 · A07 | S5, S7 | P01, P08 | [x] |
| 2 | Dependencias vulnerables | A06 | S6, S10, S13 | P09 | [x] |
| 3 | SQL Injection | A03 | S5 | P07 | [x] |
| 4 | Autorización insuficiente | A01 | S3, S8 | P04, P06 | [x] |
| 5 | Contenedor corriendo como root | A05 | S10, S12 | P10 | [x] |
| 6 | Secretos en variables inseguras | A02 | S7, S11, S12 | P08, P13 | [x] |
| 7 | Configuraciones cloud deficientes | A05 | S11, S12 | P14 | [~] |
| 8 | Ausencia de monitoreo y trazabilidad | A09 | S3, S11 | P03 | [~] |

> P02 y P05 (y la parte de transferencias de P03) son features de una API real: quedan **fuera de alcance** por ser un caso hipotético. Sus controles ya están definidos en `docs/sesion-03-threat-model/threat-model.md`.
| 9 | Pipeline CI/CD sin controles | A08 | S2, S4, S5, S6, S8, S9, S13 | P11, P12, P15 | [~] |

## 4. Checklist de problemas

Leyenda: `[x]` resuelto con evidencia · `[~]` parcial · `[ ]` pendiente.
Los IDs `T##` vienen de `docs/sesion-03-threat-model/threat-model.md`; `SS##` son sus Security Stories.

### Resumen rápido

| # | Check | Problema | Fallo S1 | Amenaza / Story | Clases | Dónde se ataca |
|---|---|---|---|---|---|---|
| P01 | [~] | Credenciales filtradas / login débil | 1 | T01 · SS06 | S3, S7 | `src/auth/auth.py`, `src/users/users.py` |
| P02 | [ ] | Manipulación del monto en transferencias | 4 | T02 · SS02 | S3, S8 | falta `POST /transfer` |
| P03 | [ ] | Repudio / sin auditoría ni monitoreo | 8 | T03 · SS05 | S3, S11 | solo log de BOLA; CloudTrail en Terraform |
| P04 | [~] | BOLA (acceso a recursos ajenos) | 4 | T04 · SS01 | S3, S8 | `src/auth/middleware.py`, `GET /users/<id>` |
| P05 | [ ] | DoS contra el login (sin rate limit) | — | T05 · SS07 | S3 | `src/users/users.py` |
| P06 | [~] | JWT manipulado / sin validar | 4 | T06 · SS08 | S3, S8 | `src/auth/tokens.py`, `middleware.py` |
| P07 | [x] | Inyecciones y código inseguro | 3 | T07 · SS03 | S5 | `users.py`, `calc.py`, `export.py`, `view.py`, `auth.py` |
| P08 | [~] | Secretos en el código/repo | 1, 6 | T08 · SS04 | S7, S2 | `config.py`, `.gitleaks.toml`, pre-commit, CI |
| P09 | [~] | Dependencias vulnerables (SCA/SBOM) | 2 | T09 · SS09 | S6 | `requirements.txt`, job `sca` |
| P10 | [x] | Contenedor con privilegios excesivos | 5 | T10 · SS10 | S10, S12 | `docker/Dockerfile.v2`, `docker-compose.dast.yml` |
| P11 | [~] | Pipeline CI/CD y quality gate | 9 | — | S4, S5, S8, S9 | `ci.yml`, `policy/`, `config/security-context.json` |
| P12 | [~] | Gobierno del repositorio | 9 | POL-REPO-001 | S2 | `docs/sesion-02-repos/POL-REPO-001.md`, `CODEOWNERS` |
| P13 | [~] | Kubernetes endurecido | 5, 6 | — | S12 | `k8s/hardened/` |
| P14 | [~] | Infraestructura cloud (IaC) | 7 | — | S11 | `infra/terraform/`, `iac.yml` |
| P15 | [~] | Supply chain (firma y SBOM de imagen) | 9, 2 | — | S13 | `supply-chain.yml`, `docker/Dockerfile.s13` |

---

### P01 · Credenciales filtradas / login débil `[~]`
- **Hecho:** bcrypt (`hash_password`/`verify_password`, hash inválido → `False`); error genérico 401; `/login` entrega JWT.
- **Falta:** MFA, política de contraseñas, bloqueo por intentos (P05).

### P02 · Manipulación del monto en transferencias `[ ]`
- **Estado real:** **no existe `POST /transfer`** (es el caso de la demo de la S1). En `transfers/` solo están `/rate` y `/export`.
- **Plan:** `POST /transfer` con `@require_auth`, cuenta de origen del `sub` del token (403 + log si no), monto `Decimal` > 0 con tope, destino válido, auditoría (P03). Tests en `tests/security/`.

### P03 · Repudio / sin auditoría ni monitoreo `[ ]`
- **Hecho:** `securebank.audit` registra intentos BOLA (`middleware.py`); CloudTrail y flow logs declarados en `infra/terraform/logging.tf` y `network.tf`.
- **Falta:** auditoría de transferencias (quién, cuenta, monto, fecha, IP, resultado), configurar logging en `create_app`, alertas. Sin secretos en logs (`repr=False`).

### P04 · BOLA `[~]`
- **Hecho:** `require_owner` compara `token.sub` con el id del recurso (admin como excepción) y deja log; `GET /users/<id>`; `tests/security/test_bola.py` (401/403/enumeración).
- **Falta:** endpoints de cuentas y saldos, migrar IDs a UUID (plan de mitigación S8), aplicar a `/transfer`.

### P05 · DoS contra el login `[ ]`
- **Plan:** límite por IP y por usuario, 429 y log.
- **Ojo:** `config/security-context.json` declara `rate_limiting` y `waf` como si existieran, y eso relaja el gate (ver P11).

### P06 · JWT manipulado `[~]`
- **Hecho:** `config.py` exige un secreto de ≥ 32 caracteres sin placeholders y TTL de 1–60; `tokens.py` fija HS256 y exige `exp` y `sub`; `require_auth` rechaza tokens inválidos con 401.
- **Falta:** leer el rol desde la BD (hoy `require_owner` confía en `role` del token), rotación de la clave.

### P07 · Inyecciones y código inseguro `[x]`
- **Evidencia:** SARIF antes/después (10 → 0) en `docs/sesion-05-sast/`, tests en `tests/unit/test_transfers_auth_views.py`.

| Archivo | Hallazgo antes | Solución |
|---|---|---|
| `src/users/users.py` | SQL armado con strings | `WHERE username = ?` |
| `src/transfers/calc.py` | `eval` | `_safe_eval` con `ast` |
| `src/transfers/export.py` | `shell=True` | `shell=False` + lista blanca |
| `src/accounts/view.py` | HTML a mano (XSS) | `render_template` con autoescape |
| `src/auth/auth.py` | MD5 | bcrypt |

- **Menor:** `/export` responde 500 si no existe `reports/daily.txt` (`check=True` sin manejo).

### P08 · Secretos en el código `[~]`
- **Hecho:** `config.py` por env y falla cerrada; Gitleaks con regla propia, pre-commit y job `secret-scan` (historial completo); secretos efímeros enmascarados en el job `dast`; `.gitignore` y `.dockerignore`.
- **Falta:** `docs/SECRETS.md` (6 secciones S7), `.env.example` (referenciado pero inexistente), gestor real (Vault), rotación cada 90 días.

### P09 · Dependencias vulnerables (SCA/SBOM) `[~]`
- **Hecho:** versiones exactas; job `sca` (Trivy 0.69.3 con checksum) → `sca.json` evaluado por el gate.
- **Falta (S6):** `reports/securebank-sbom.cdx.json` y `reports/securebank-vulns.html/.json` generados por el pipeline, con semáforo CVSS.

### P10 · Contenedor con privilegios excesivos `[x]`
- **Hecho:** `Dockerfile.v2` (slim con tag fijo, uid 10001, `COPY src`, `EXPOSE 8000`, tini + gunicorn, 381 → 219 MB); `docker-compose.dast.yml` con `read_only`, `cap_drop: ALL`, `no-new-privileges`.
- **Residual:** CVEs de Debian sin parche (REPORT.md), falta Trivy de imagen en CI.

### P11 · Pipeline CI/CD y quality gate `[~]`
- **Hecho:** `secret-scan`, `sast` (Semgrep 1.180.0), `sca`, `coverage`, `dast` (ZAP 2.16.1), `gate` (OPA 1.9.0, `if: always()`, KEV de CISA, 20 tests de política).
- **Falta / riesgos:**
  - `config/security-context.json` declara `waf` y `rate_limiting`, que no existen, y eso sube los límites del gate: SCA High pasa de 2 a 6 y SCA Critical de 0 a 3. Quitarlos hasta que existan.
  - El `build` sigue siendo Node de relleno.
  - `pull_request` solo cubre `main` y no `develop`.
  - Las acciones están fijadas por tag (`@v4`) y no por SHA.

### P12 · Gobierno del repositorio `[~]`
- **Hecho:** política escrita; `CODEOWNERS` con 4 dueños globales; flujo de ramas en el README.
- **Falta:** CODEOWNERS por carpeta (`src/auth/`, `.github/workflows/`, `config/`, `policy/`). Verificar a mano la protección de `main`, el MFA y los commits firmados.

### P13 · Kubernetes endurecido `[~]`
- **Hecho:** los 7 criterios de S12 en `deployment.hardened.yaml` (runAsNonRoot + uid 10001, readOnlyRootFilesystem, drop ALL, no privilege escalation, limits, digest, secretKeyRef), `automountServiceAccountToken: false`.
- **Falta:** el digest es de ejemplo (`9f2c000…`); inyecta `DB_PASSWORD`, pero la app exige `JWT_SECRET` y `DATABASE_URL` (no arrancaría); validar con kube-score/kubesec.

### P14 · Infraestructura cloud (IaC) `[~]`
- **Hecho:** Terraform (67 recursos, KMS, OIDC sin claves estáticas, CloudTrail); `iac.yml` scan → validate → plan → apply con environment `production`; Checkov 307/0/15 con skips justificados.
- **Falta (S11):** `checkov-before.json`, informe técnico PDF de 2–3 páginas, captura del pipeline bloqueando un CRITICAL.

### P15 · Supply chain `[~]`
- **Hecho:** `supply-chain.yml` hace push a GHCR, registra el digest, genera SBOM CycloneDX con Syft y ejecuta `cosign sign/attest/verify` keyless. Hay reporte, captura del bloqueo y análisis de 1 página.
- **Falta:**
  - Firma `Dockerfile.s13` (alpine + `echo`), no la API; debería construir `docker/Dockerfile.v2`.
  - El tag `:v1` se sobrescribe en cada push.
  - Corre en PRs con `packages: write`.

---

## 4B. Entregables del curso por sesión

Detalle ítem por ítem de cada presentación: `docs/CHECKLIST.md` (fuente del estado; mantener sincronizado con esta tabla y el README).

| Sesión | Tema | Entregable pedido | Check | Dónde está / qué falta |
|---|---|---|---|---|
| S1 | Intro DevSecOps | Diagrama del ciclo (8 fases, herramienta y rol) | [~] | `docs/sesion-01-ciclo/ciclo-devsecops.md` · falta PDF de 1 página |
| S2 | Git y repos seguros | POL-REPO-001 | [~] | `docs/sesion-02-repos/POL-REPO-001.md`, `CODEOWNERS` (falta por carpeta) |
| S3 | Threat Modeling | ≥10 amenazas + controles, DFD | [x] | `docs/sesion-03-threat-model/threat-model.md` (revisión al día: próxima 2027-02-25) |
| S4 | CI/CD | Pipeline v1.0, sin secretos, badge | [~] | `ci.yml`, `docs/sesion-04-ci/pipeline.md`, badge · falta captura del run verde/status check; pipeline.md desactualizado |
| S5 | SAST | SARIF antes/después + tabla OWASP + diff + URL | [~] | `docs/sesion-05-sast/README.md`; falta URL del run (👤) |
| S6 | SCA y SBOM | `reports/securebank-sbom.cdx.json` + `reports/securebank-vulns.html/.json` desde el pipeline | [~] | `reports/` con datos reales (PyJWT 2.10.1 → 2.15.0, 17 → 0 CVE); pasos del CI comentados en el job `sca` |
| S7 | Secretos | `docs/SECRETS.md` + Gitleaks hook/CI + evidencia | [~] | `docs/SECRETS.md` §1–§6, `.env.example`; falta ejecutar la prueba de bloqueo (§6) |
| S8 | DAST y APIs | Reporte ZAP (PDF) + `report.json` + plan de mitigación | [~] | Tabla ilustrativa antes/después + plan completo; falta el scan real y el PDF |
| S9 | Quality Gates | `.rego` + README + 2 casos | [x] | `policy/`, `scripts/gate.sh`, fixtures; `security-context.json` sin mitigaciones falsas |
| S10 | Docker | Dockerfile endurecido + comparativo Trivy | [~] | `docker/REPORT.md` §6; v2 con 50 HIGH (3 con parche, comentado en el Dockerfile) |
| S11 | IaC y Cloud | Terraform, `iac.yml`, Checkov antes/después, informe | [~] | `docs/sesion-11-iac/informe-iac.md` (before ilustrativo); falta `checkov-before.json` real y el PDF |
| S12 | Kubernetes | `k8s/hardened/deployment.hardened.yaml` | [~] | Secretos alineados con la app (M2); falta el digest real y kubesec |
| S13 | Supply chain | Build + digest, SBOM, Cosign, verify que bloquea, análisis | [~] | Ahora firma `docker/Dockerfile.v2` + tag por SHA; verify/deploy separados y Rekor comentados |

## 5. Siguientes pasos sugeridos (orden de impacto)

Primero los entregables del curso que faltan, después los detalles de los controles. Sin features de API real.

1. **S7:** `docs/SECRETS.md` (6 secciones) + `.env.example`.
2. **S6:** generar `reports/securebank-sbom.cdx.json` y `reports/securebank-vulns.html/.json` desde el job `sca`.
3. **S8:** completar `reporte-dast.md` con un scan real y exportar el PDF.
4. **S11:** `checkov-before.json`, informe de 2–3 páginas y captura del bloqueo.
5. **P11:** quitar `waf`/`rate_limiting` de `config/security-context.json`. Es una línea y deja de relajar el gate.
6. **P15:** firmar la imagen de `docker/Dockerfile.v2` en vez de alpine, tag por `github.sha` y sin push en PRs.
7. **P13:** alinear el `secretKeyRef` con `JWT_SECRET`/`DATABASE_URL` y usar un digest real.
8. **CI y repo:** `build` de Python en vez de Node, PR a `develop`, pinning por SHA, CODEOWNERS por carpeta.

## 6. Comandos útiles

```bash
# Instalar y probar
pip install -r requirements.txt
export JWT_SECRET="$(python -c 'import secrets;print(secrets.token_urlsafe(48))')"
export DATABASE_URL="sqlite:///securebank.db"
pytest -q                                   # 30 tests

# Ejecutar local
flask --app src.app run --port 8000

# Entorno DAST efímero
export SEED_ALICE_PW=$(openssl rand -hex 12) SEED_BOB_PW=$(openssl rand -hex 12)
docker compose -f docker-compose.dast.yml up -d --build
docker compose -f docker-compose.dast.yml down -v

# Quality gate (requiere opa y jq)
opa test policy/
scripts/gate.sh tests/policy/fixtures/green.json   # DEPLOY · exit 0
scripts/gate.sh tests/policy/fixtures/red.json     # BLOCK  · exit 1

# Contenedor endurecido
docker build -f docker/Dockerfile.v2 -t securebank:v2-secure .
docker run --rm securebank:v2-secure whoami        # appuser
trivy image --severity HIGH,CRITICAL securebank:v2-secure

# IaC
cd infra/terraform && terraform init -backend=false && terraform validate
checkov -d infra/terraform --framework terraform --compact

# Secretos
pip install pre-commit && pre-commit install
gitleaks detect --source . --config .gitleaks.toml --redact
```

## 7. Plantilla para agregar un problema nuevo

```markdown
### P## · <Título> `[ ]`
- **Docs:** <archivos de docs/ que lo describen>
- **Estado real:** <qué existe hoy en el código>
- **Cómo lo atacamos:** <control aplicado o plan>
- **Falta:** <lo pendiente>
```
Agregar la fila en el **Resumen rápido** de la sección 4, la columna "Fallo S1" y actualizar el `README.md`.
