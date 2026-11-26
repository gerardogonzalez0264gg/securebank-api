# Reporte DAST · SecureBank API (Sección 1)

Grupo: `TODO(equipo)` · Integrantes: `TODO(equipo)`

> **Cómo usar este documento:** los resultados de la tabla 2 deben salir de **tu ejecución real** de ZAP. Los hallazgos listados abajo son los **esperados según el checklist de la clase**; confírmalos o descártalos con tu `report.json` antes de entregar. Exporta a PDF (2–3 páginas) como `reporte-dast-<grupo>.pdf`.

## 1. Datos de la ejecución

| Campo | Valor |
|---|---|
| Fecha y hora del scan (UTC) | `TODO(equipo)`: copiar `@generated` del `report.json` del run real (la tabla 2 es ilustrativa, 2026-11-25) |
| Versión de ZAP | `2.16.1` (imagen `zaproxy/zap-stable:2.16.1`; verifica con `zap-baseline.py --help`) |
| Objetivo | `http://localhost:8080` (SecureBank, `docker-compose.dast.yml`) |
| Modo | Baseline (pasivo) |
| Commit evaluado | `TODO(equipo)`: SHA del run del job `dast` |

Comando exacto:

```bash
docker run --rm --network=host -v "$PWD/zap-out:/zap/wrk/:rw" \
  zaproxy/zap-stable:2.16.1 zap-baseline.py \
  -t http://localhost:8080 -r report.html -J report.json -w report.md -I
```

## 2. Tabla de hallazgos

> ⚠️ **Resultado ilustrativo, no es un scan real.** Se armó a partir de las cabeceras que hoy envía `src/app.py` (CSP, X-Frame-Options, HSTS, nosniff, Referrer-Policy, Cache-Control) y de lo que ZAP Baseline 2.16 suele reportar en ese caso. Antes de entregar hay que reemplazarlo por los datos del `report.json` del job `dast`.

### 2.1 Antes de la corrección (API sin cabeceras ni ownership check)

Resumen: High 0 · Medium 3 · Low 2 · Informational 1 · + BOLA manual

| # | Severidad | ZAP id | CWE | URL | Descripción | Evidencia |
|---|---|---|---|---|---|---|
| 1 | Medium | 10038 | CWE-693 | `http://localhost:8080/health` | Content Security Policy (CSP) Header Not Set | Respuesta sin `Content-Security-Policy` |
| 2 | Medium | 10020 | CWE-1021 | `http://localhost:8080/health` | Missing Anti-clickjacking Header | Sin `X-Frame-Options` ni `frame-ancestors` |
| 3 | Medium | — | CWE-319 | `http://localhost:8080/` | Strict-Transport-Security ausente (aplica detrás del ALB con HTTPS) | Sin `Strict-Transport-Security` |
| 4 | Low | 10021 | CWE-693 | `http://localhost:8080/health` | X-Content-Type-Options Header Missing | Sin `X-Content-Type-Options: nosniff` |
| 5 | Low | 10036 | CWE-497 | `http://localhost:8080/health` | Server Leaks Version Information via "Server" HTTP Response Header | `Server: gunicorn` |
| 6 | Informational | 10049 | CWE-524 | `http://localhost:8080/health` | Storable and Cacheable Content | Sin `Cache-Control: no-store` |
| 7 | Manual (High) | — | CWE-639 | `GET /users/101` | **BOLA** (API1:2023): ver sección 4 | Token de Alice → 200 con los datos de Bob |

### 2.2 Después de la corrección (estado actual de `main`)

Resumen: High 0 · Medium 1 · Low 2 · Informational 1

| # | Severidad | ZAP id | CWE | URL | Descripción | Evidencia |
|---|---|---|---|---|---|---|
| 1 | Medium | 10055 | CWE-693 | `http://localhost:8080/health` | CSP: Failure to Define Directive with No Fallback (`form-action` no hereda de `default-src`) | `Content-Security-Policy: default-src 'none'; frame-ancestors 'none'` |
| 2 | Low | 10036 | CWE-497 | `http://localhost:8080/health` | Server Leaks Version Information via "Server" HTTP Response Header | `Server: gunicorn` |
| 3 | Low | 90004 | CWE-693 | `http://localhost:8080/health` | Insufficient Site Isolation Against Spectre Vulnerability | Sin `Cross-Origin-Resource-Policy` |
| 4 | Informational | 10049 | CWE-524 | `http://localhost:8080/health` | Non-Storable Content | `Cache-Control: no-store` (comportamiento esperado) |

Los hallazgos 1–4 del "antes" quedan cerrados por `SECURITY_HEADERS` en `src/app.py` y BOLA queda cerrado por `require_owner`. Los Medium y Low restantes tienen su fila en [plan-mitigacion.md](plan-mitigacion.md).

## 3. Screenshots

- Dashboard del reporte HTML (resumen de alertas)
- Top 3 hallazgos High/Medium con su evidencia

## 4. Verificación manual de BOLA

ZAP Baseline es pasivo y no prueba autorización entre usuarios; se verifica a mano con dos cuentas:

```bash
TOKEN=$(curl -s -d "username=alice" -d "password=$SEED_ALICE_PW" http://localhost:8080/login | jq -r .access_token)
curl -i -H "Authorization: Bearer $TOKEN" http://localhost:8080/users/100   # esperado: 200
curl -i -H "Authorization: Bearer $TOKEN" http://localhost:8080/users/101   # esperado: 403 (200 = vulnerable)
```

| Versión | `GET /users/101` con token de Alice | Resultado |
|---|---|---|
| Antes (sin ownership check, ver diagnóstico en README.md) | 200 + `{"id":101,"username":"bob","balance":98000.0,...}` (ilustrativo) | Vulnerable |
| Después (`require_owner`) | 403 `{"error":"forbidden"}` | Corregido (`pytest tests/security`: 6 passed) |

## 5. Adjuntos

- `zap-out/report.json` (insumo de la Sesión 9 · Quality Gates)
- `zap-out/report.html`
