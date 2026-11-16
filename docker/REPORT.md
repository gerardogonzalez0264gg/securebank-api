# Reporte comparativo · securebank:v1 vs securebank:v2-secure

Sesión 10 · Seguridad de Contenedores y Docker

## 1. Salida de Trivy

### securebank:v1
```

Report Summary

┌──────────────────────────────────────────────────────────────────────────────┬────────────┬─────────────────┬─────────┐
│                                    Target                                    │    Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ securebank:v1 (ubuntu 26.04)                                                 │   ubuntu   │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/package.json                                                             │  node-pkg  │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/bcrypt-5.0.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/blinker-1.9.0.dist-info/METADATA      │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/click-8.5.1.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/flask-3.1.3.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/gunicorn-27.0.1.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/iniconfig-2.3.1.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/itsdangerous-2.2.0.dist-info/METADATA │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/jinja2-3.1.6.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/markupsafe-3.0.4.dist-info/METADATA   │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/pluggy-1.7.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/pygments-2.21.0.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/pytest-9.2.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/werkzeug-3.1.9.dist-info/METADATA     │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/bin/pebble                                                               │  gobinary  │        0        │    -    │
└──────────────────────────────────────────────────────────────────────────────┴────────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)

```

### securebank:v2-secure
```
PEGAR_AQUI_TRIVY_V2
```

Un primer escaneo de v2 con el tag original `python:3.11.9-slim-bookworm` dio 173 hallazgos HIGH/CRITICAL (11 CRITICAL), incluidos 3 de `setuptools`. Por eso se actualizó el tag y se quitó `setuptools`.

## 2. Tabla comparativa

| Métrica | securebank:v1 | securebank:v2-secure | Mejora |
|---|---|---|---|
| Vulnerabilidades (HIGH + CRITICAL) | 0 | 50 (0 CRITICAL) | sin mejora hoy (ver nota) |
| Tamaño de la imagen | 381 MB | 219 MB | ↓ 43 % |
| Paquetes instalados | 135 | 88 | ↓ 35 % |
| Usuario de ejecución | root | appuser (uid 10001) | mínimo privilegio |
| Puertos expuestos | 22 | 8000 | acorde al servicio |

**Nota:** v1 usa `ubuntu:latest`, que ese día traía Ubuntu 26.04 recién parcheado, por eso salió en 0. Es un resultado puntual y no reproducible, porque `latest` cambia sin aviso. v2 bajó de 173 a 50 hallazgos frente a su primer escaneo. De esas 50, solo 3 tienen parche disponible (`--ignore-unfixed`); las otras 47 no tienen corrección publicada.

**Por qué cambia cada métrica:**
- Tamaño y paquetes: la base slim y `--no-install-recommends` instalan menos cosas.
- Usuario: v2 usa `USER appuser`, así que un compromiso no da root.
- Puertos: la API solo habla HTTP, no necesita SSH (22).

## 3. Cambios aplicados al Dockerfile

| Cambio | Por qué |
|---|---|
| `ubuntu:latest` → `python:3.11.17-slim-trixie` | Base mínima con tag fijo, reproducible. |
| `USER appuser` (uid 10001) | Mínimo privilegio. |
| `COPY . .` → `COPY src ./src` + `.dockerignore` | No copia `.env`, `.git` ni tests. |
| `EXPOSE 22` → `EXPOSE 8000` | SSH no hace falta en una API HTTP. |
| `--no-install-recommends`, `--no-cache-dir` | Menos paquetes y menos peso. |
| `pip uninstall -y setuptools` | No se usa y traía 3 CVEs HIGH. |
| `tini` + `gunicorn` | Manejo de señales y servidor apto para producción. |

## 4. Evidencia

Comandos usados: `docker build`, `docker images securebank`, `docker run --rm <imagen> whoami`, `docker inspect`, `trivy image --severity HIGH,CRITICAL <imagen>`.

## 5. Conclusión y riesgos residuales

v2-secure aplica las buenas prácticas de la sesión: corre sin root, expone solo su puerto, tiene tag fijo y es más liviana. Fijar un tag no basta: hay que actualizarlo.

Riesgos que quedan:
- 50 vulnerabilidades HIGH de Debian: 47 sin parche publicado y 3 con parche.
- El escaneo de v1 es una foto de ese día, no una garantía.
- No se usa `--read-only` ni `--cap-drop=ALL`.
- La imagen no está firmada.
- Los secretos van por variable de entorno, sin gestor de secretos.
- Falta un job de Trivy en el CI.
