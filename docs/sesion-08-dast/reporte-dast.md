# Reporte DAST · SecureBank API (Sección 1)

Grupo: `<completar>` · Integrantes: `<completar>`

> **Cómo usar este documento:** los resultados de la tabla 2 deben salir de **tu ejecución real** de ZAP. Los hallazgos listados abajo son los **esperados según el checklist de la clase**; confírmalos o descártalos con tu `report.json` antes de entregar. Exporta a PDF (2–3 páginas) como `reporte-dast-<grupo>.pdf`.

## 1. Datos de la ejecución

| Campo | Valor |
|---|---|
| Fecha y hora del scan (UTC) | `<completar>` |
| Versión de ZAP | `2.16.1` (imagen `zaproxy/zap-stable:2.16.1`; verifica con `zap-baseline.py --help`) |
| Objetivo | `http://localhost:8080` (SecureBank, `docker-compose.dast.yml`) |
| Modo | Baseline (pasivo) |
| Commit evaluado | `<git rev-parse --short HEAD>` |

Comando exacto:

```bash
docker run --rm --network=host -v "$PWD/zap-out:/zap/wrk/:rw" \
  zaproxy/zap-stable:2.16.1 zap-baseline.py \
  -t http://localhost:8080 -r report.html -J report.json -w report.md -I
```

## 2. Tabla de hallazgos

Resumen del scan: High `<n>` · Medium `<n>` · Low `<n>` · Informational `<n>`

| # | Severidad | CWE | URL | Descripción | Evidencia |
|---|---|---|---|---|---|
| 1 | `<ZAP>` | CWE-693 | `<url>` | Content Security Policy (CSP) ausente | `<cabecera ausente / alerta ZAP>` |
| 2 | `<ZAP>` | CWE-1021 | `<url>` | X-Frame-Options ausente (clickjacking) | `<...>` |
| 3 | `<ZAP>` | CWE-319 | `<url>` | Strict-Transport-Security ausente | `<...>` |
| 4 | `<ZAP>` | CWE-16 | `<url>` | `X-Content-Type-Options` ausente | `<...>` |
| 5 | `<ZAP>` | CWE-1004 / CWE-614 | `<url>` | Cookie de sesión sin HttpOnly/Secure/SameSite (solo si la app emite cookies) | `<Set-Cookie>` |
| 6 | Manual | CWE-639 | `GET /users/{id}` | **BOLA** (API1:2023): ver sección 4 | petición manual |

Elimina las filas que tu scan no reporte y agrega las que aparezcan. Severidad, CWE y evidencia se copian del `report.json`.

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
| Antes (sin ownership check) | `<completar si reproduces la versión vulnerable>` | `<200 + datos de Bob>` |
| Después (`require_owner`) | 403 `{"error":"forbidden"}` | Corregido (`pytest tests/security`: 6 passed) |

## 5. Adjuntos

- `zap-out/report.json` (insumo de la Sesión 9 · Quality Gates)
- `zap-out/report.html`
