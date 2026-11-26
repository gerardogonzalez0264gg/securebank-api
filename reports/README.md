# reports/ · Entregables de la Sesión 6 (SCA y SBOM)

| Archivo | Qué es |
|---|---|
| [securebank-sbom.cdx.json](securebank-sbom.cdx.json) | SBOM **CycloneDX 1.5** con 18 componentes (directos y transitivos), su versión, PURL y licencia |
| [securebank-vulns.json](securebank-vulns.json) | CVE detectados con CVSS 3.1, componente, versión afectada y corregida, semáforo y decisión |
| [securebank-vulns.html](securebank-vulns.html) | El mismo reporte en formato legible, con el inventario del SBOM |

## Resultado

| Momento | Paquetes auditados | Avisos | Critical | High | Medium | Low | Decisión |
|---|---|---|---|---|---|---|---|
| Antes (`PyJWT==2.10.1`) | 16 | 17 | 1 | 6 | 9 | 1 | **BLOCK** (CVE-2026-102268, CVSS 9.1) |
| Después (`PyJWT==2.15.0`) | 16 | 0 | 0 | 0 | 0 | 0 | **DEPLOY** |

Los 17 avisos distintos de OSV/PyPI son 16 CVE + 1 GHSA sin CVE (`GHSA-pxh4-856f-4h89`). pip-audit muestra 22 porque algunos aparecen dos veces con distintos rangos de versión corregida. pip-audit audita 16 paquetes; el SBOM lista 18 componentes porque también incluye `pip` y `packaging` del entorno. CVE-2025-45768 está **disputado** y afecta solo hasta la 2.10.1 inclusive (además, `src/config.py` exige `JWT_SECRET` de 32 caracteres o más). Todos afectan solo a PyJWT; ninguna otra dependencia tiene CVE conocidos. La corrección fue subir `PyJWT` a `2.15.0` en [requirements.txt](../requirements.txt), y con eso los 30 tests siguen pasando.

## Política CVSS (semáforo)

| Semáforo | Rango | Acción |
|---|---|---|
| BLOQUEO | CVSS ≥ 9.0 | El pipeline falla y no se despliega |
| APPROVAL | 7.0 – 8.9 | Se despliega solo con aprobación del Lead de seguridad |
| REGISTRO | < 7.0 | Se registra y se corrige en el sprint |

Es coherente con el gate de la Sesión 9: con `config/security-context.json` sin mitigaciones declaradas, el gate no tolera SCA Critical (`max_sca_critical := 0`) y acepta como máximo 2 SCA High.

## Cómo se generaron (2026-11-25)

Se generaron con datos reales, ejecutando las herramientas sobre `requirements.txt`:

```bash
# 1. Entorno limpio solo con las dependencias del proyecto
python -m venv .venv-sca && .venv-sca/bin/pip install -r requirements.txt

# 2. SBOM CycloneDX 1.5 (incluye transitivas, PURL y licencias)
pip install cyclonedx-bom==9.0.0
cyclonedx-py environment --spec-version 1.5 --output-reproducible \
  --output-format JSON -o reports/securebank-sbom.cdx.json .venv-sca/bin/python

# 3. Vulnerabilidades (base PyPI / OSV)
pip install pip-audit==2.10.1
pip-audit -r requirements.txt -f json -o vulns.json --desc

# 4. CVSS 3.1 de cada aviso: https://api.osv.dev/v1/vulns/<GHSA-...>
#    (vector -> puntaje base con la fórmula de CVSS 3.1)
```

La versión automática de estos pasos está **comentada** en el job `sca` de [ci.yml](../.github/workflows/ci.yml). Si se descomenta, el pipeline regenera esta carpeta en cada push, que es lo que evalúa la rúbrica ("los artefactos deben salir del pipeline").
