# Sesión 8 · DAST y Seguridad de APIs

Proyecto SecureBank API · Módulo IV (pruebas dinámicas) · Requiere Sesiones 5–7 (Secret Scanning, SAST, SCA).

## Objetivo

Automatizar pruebas dinámicas de seguridad (DAST) contra SecureBank API **en ejecución**, usando OWASP ZAP dentro del pipeline, y corregir la vulnerabilidad BOLA (API1:2023) en `GET /users/{id}`.

## Qué se agrega al repositorio

| Archivo | Para qué sirve |
|---|---|
| `docker-compose.dast.yml` | Entorno efímero de test (imagen `docker/Dockerfile.v2`, BD en tmpfs, sin root) |
| `lab/dast/seed.py` | Siembra a Alice (id=100) y Bob (id=101); contraseñas por variable de entorno |
| `src/auth/tokens.py` | Emisión y validación de JWT (HS256, `exp` obligatorio, algoritmo fijo) |
| `src/auth/middleware.py` | `require_auth` (¿quién eres?) y `require_owner` (¿es tuyo este recurso?) |
| `src/users/users.py` | `GET /users/<id>` protegido con ownership check; `/login` ahora entrega `access_token` |
| `src/app.py` | `GET /health` y cabeceras de seguridad (CSP, HSTS, X-Frame-Options, nosniff) |
| `tests/security/test_bola.py` | Verifica `/users/otro_id → 403` y las cabeceras |
| `.github/workflows/ci.yml` | Nuevo job `dast` (tests de seguridad → entorno efímero → ZAP Baseline → reportes) |
| `docs/sesion-08-dast/reporte-dast.md` | Entregable, sección 1 |
| `docs/sesion-08-dast/plan-mitigacion.md` | Entregable, sección 2 |

## Laboratorio (local)

```bash
export JWT_SECRET=$(openssl rand -base64 48)
export SEED_ALICE_PW=$(openssl rand -hex 12) SEED_BOB_PW=$(openssl rand -hex 12)

docker compose -f docker-compose.dast.yml up -d --build
curl http://localhost:8080/health            # {"status":"ok"}

mkdir -p zap-out && chmod 777 zap-out
docker run --rm --network=host -v "$PWD/zap-out:/zap/wrk/:rw" \
  zaproxy/zap-stable:2.16.1 zap-baseline.py \
  -t http://localhost:8080 -r report.html -J report.json -w report.md -I

docker compose -f docker-compose.dast.yml down -v
```

Nota: `-I` evita que el job falle por advertencias. Los umbrales de pass/fail se definen en la Sesión 9 (Quality Gates), que consumirá `report.json`.

## Diagnóstico BOLA (ejercicio guiado)

**Síntoma:** Alice (id=100) envía `GET /users/101` con su propio token y recibe los datos de Bob.

**Causa:** el handler confunde *autenticado* con *autorizado*. Valida el token, pero nadie compara `token.sub` con el `id` del recurso. Además, los IDs son secuenciales y adivinables.

Código vulnerable (equivalente Flask del ejemplo de la clase, que estaba en Express):

```python
@bp.route("/users/<int:user_id>")
@require_auth                      # solo comprueba que hay token válido
def get_user(user_id):
    return jsonify(db.find_user(user_id))   # devuelve CUALQUIER usuario
```

Corrección aplicada en este repo (`src/users/users.py`):

```python
@bp.route("/users/<int:user_id>", methods=["GET"])
@require_owner("user_id")          # sub == user_id, o rol admin; si no, 403 + audit log
def get_user(user_id):
    ...
```

Refuerzos: (1) chequeo centralizado en middleware, (2) registro de intentos con id ajeno (`securebank.audit`), (3) test automatizado que espera 403, (4) pendiente: migrar a UUID para IDs no adivinables.

## Limitaciones a tener presentes

- **ZAP Baseline es pasivo.** Detecta cabeceras ausentes, cookies inseguras y configuraciones, pero **no confirma BOLA por sí solo**: eso exige probar con dos usuarios autenticados. Por eso la verificación de BOLA es el test `tests/security/test_bola.py` (y la petición manual de la slide 9), no el reporte de ZAP.
- **El crawler no ve una API sin enlaces.** Con una API JSON, Baseline puede descubrir pocos endpoints. Para cobertura real, el siguiente paso es `zap-api-scan.py` con una especificación OpenAPI (Full Scan/API Scan en nightly o release).
- El job `dast` modifica `.github/workflows/`: según POL-REPO-001 (R.02, R.06 y matriz §4) necesita 2 aprobaciones, una de seguridad.

## Relación con el Threat Model

| Amenaza | Control de esta sesión |
|---|---|
| T04 · Exposición de información de otra cuenta | `require_owner` + test BOLA (SS01) |
| T06 · Elevación de privilegios mediante JWT manipulado | Algoritmo fijo, `exp` y `sub` obligatorios (SS08) |
| A05 · Security Misconfiguration (OWASP Top 10) | Cabeceras de seguridad + escaneo ZAP en cada PR |
