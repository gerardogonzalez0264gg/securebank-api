# Checklist por sesión · lo que pide cada presentación vs. lo que hay en el repo

Revisión del 2026-11-25 sobre `main` + cambios locales. Cada ítem sale del checklist, la rúbrica o la sección "debe incluir" de la presentación de esa sesión (`material-curso/`, que no se versiona). La revisión se contrastó además con un segundo revisor independiente. SecureBank es un **caso hipotético**, así que solo se evalúa lo que pide cada entregable.

Leyenda: ✅ cumple · 🟡 parcial · ❌ falta · 🔒 ajuste de GitHub (no verificable desde el repo) · 👤 requiere una acción del equipo (ejecutar, capturar o exportar)

## Resumen

| Sesión | Estado | Qué falta para cerrarla (todo es 👤 o 🔒) |
|---|---|---|
| S1 · Ciclo DevSecOps | 🟡 | Exportar el diagrama a un PDF de 1 página |
| S2 · Repos seguros | 🟡 | Asignar Lead de seguridad y SRE en CODEOWNERS; capturas de la protección de `main` |
| S3 · Threat Modeling | ✅ | — |
| S4 · CI/CD | 🟡 | Captura del run en verde y del status check obligatorio |
| S5 · SAST | 🟡 | URL del run en verde |
| S6 · SCA y SBOM | 🟡 | Descomentar los pasos del CI para que `reports/` salga del pipeline |
| S7 · Secretos | 🟡 | Ejecutar la prueba de bloqueo de Gitleaks y pegar la URL o captura en `SECRETS.md` §6 |
| S8 · DAST | 🟡 | Reemplazar la tabla ilustrativa por el `report.json` real, capturas y PDF |
| S9 · Quality Gates | ✅ | — |
| S10 · Docker | 🟡 | Aplicar los 3 parches disponibles y volver a escanear |
| S11 · IaC | 🟡 | `checkov-before.json` real, capturas y PDF del informe |
| S12 · Kubernetes | 🟡 | Digest real y salida de kubesec o kube-score |
| S13 · Supply chain | 🟡 | Run nuevo con la imagen real, evidencia de Rekor y URL del run |

Lo que se podía resolver dentro del repo ya está hecho. Lo pendiente necesita ejecutar herramientas o GitHub Actions, capturar pantallas, exportar PDF o tocar la configuración de GitHub.

---

## S1 · Introducción a DevSecOps

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| Las 8 fases del ciclo con sus controles | ✅ | [ciclo-devsecops.md](sesion-01-ciclo/ciclo-devsecops.md) |
| Al menos 1 herramienta por fase | ✅ | Tabla del documento |
| Rol responsable en cada control | ✅ | Columna "Responsable" |
| PDF de 1 página (draw.io, Excalidraw o Miro) | 👤 | Exportar el Mermaid a PDF |

## S2 · Git y repositorios seguros

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| §1 Alcance · §2 Roles (los 5) · §3 Reglas · §4 Matriz (4 preguntas) · §5 Excepciones | ✅ | [POL-REPO-001.md](sesion-02-repos/POL-REPO-001.md) (R.01–R.07 cubren los 7 riesgos) |
| CODEOWNERS por carpeta | 🟡 | [CODEOWNERS](../.github/CODEOWNERS) ya separa `src/auth/`, `src/transfers/`, `.github/`, `policy/`, `config/`, `infra/`, `k8s/` y `docker/`. Falta `TODO(equipo)`: dejar solo al Lead de seguridad y al SRE en las rutas sensibles |
| `main` protegida, PR obligatorio, revisión de Code Owners, sin force push | 🔒 | Settings → Branches + captura |
| Commits firmados y MFA | 🔒 | 141 de los últimos 154 commits llevan firma (en su mayoría merges hechos desde GitHub) y 13 no; activar "Require signed commits" |

## S3 · Threat Modeling

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| ≥ 10 amenazas con STRIDE, riesgo y control | ✅ | T01–T10 en [threat-model.md](sesion-03-threat-model/threat-model.md) |
| DFD con fronteras de confianza | ✅ | §6 y §7 (TB01–TB05) |
| Caso de abuso `POST /transfer` | ✅ | §11 |
| Security Stories | ✅ | SS01–SS10 |
| Fecha de próxima revisión vigente | ✅ | Estaba vencida (2026-11-13); revisado el 2026-11-25, próxima revisión 2027-02-25 |

## S4 · CI/CD

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| `ci.yml` en `main` con las 5 etapas | ✅ | Job `build` en [ci.yml](../.github/workflows/ci.yml) |
| Artefacto `dist-<sha>` con 7 días de retención | ✅ | |
| Ningún secreto en el YAML | ✅ | |
| README con badge y resumen | ✅ | [README](../README.md), [pipeline.md](sesion-04-ci/pipeline.md), actualizado con todos los jobs |
| Última ejecución en verde | 👤 | Captura o URL del run |
| Status check obligatorio en PR a `main` | 🔒 | Protección de rama |

## S5 · SAST

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| ① SARIF antes y después | ✅ | [sesion-05-sast/](sesion-05-sast/README.md): 10 → 0 resultados |
| ② Tabla de clasificación OWASP | ✅ | [README de S5](sesion-05-sast/README.md) §② |
| ③ Diff del código corregido | ✅ | §③, con el diff tomado del historial de git |
| ④ URL del run en verde | 👤 | `TODO(equipo)` en §④ |
| Los 5 defectos corregidos y con tests | ✅ | `src/` + [test_transfers_auth_views.py](../tests/unit/test_transfers_auth_views.py) |
| `--config=p/owasp-top-ten --error` | ✅ | Diferencia justificada en el README de S5 (el gate de S9 bloquea); la variante literal quedó comentada en `ci.yml` |

## S6 · SCA y SBOM

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| SCA integrado al pipeline | ✅ | Job `sca` (Trivy) |
| `reports/securebank-sbom.cdx.json` (CycloneDX 1.5: componentes, transitivas, PURL, licencias) | ✅ | 18 componentes, generado con `cyclonedx-py` |
| `reports/securebank-vulns.html` + `.json` (CVE, CVSS, componente, versión) | ✅ | Datos reales de pip-audit + OSV: 17 avisos (16 CVE + 1 GHSA) en PyJWT 2.10.1 (1 Critical CVSS 9.1) |
| Semáforo bloqueo / approval / registro + decisión | ✅ | [reports/README.md](../reports/README.md): la decisión fue subir a PyJWT 2.15.0 (0 CVE, 30 tests pasan) |
| Los artefactos salen **del pipeline** | 🟡 | Los pasos están comentados en el job `sca`; hoy los archivos se generaron a mano con las mismas herramientas. 👤 Descomentar |
| Gate coherente con el semáforo (Critical = bloqueo) | ✅ | `security-context.json` ya no declara mitigaciones inexistentes → `max_sca_critical := 0` |

## S7 · Secret Management

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| Sin secretos hardcodeados | ✅ | [src/config.py](../src/config.py) |
| Gitleaks en `.gitleaks.toml`, pre-commit y CI, antes de SAST/SCA, con exit 1 | ✅ | |
| `docs/SECRETS.md` §1–§5 | ✅ | [SECRETS.md](SECRETS.md) |
| Rotación documentada **y ejecutable** | ✅ | §4 con un script de referencia (comentado) |
| `.env.example` | ✅ | [.env.example](../.env.example) |
| §6 Evidencia de un pipeline bloqueado por un secreto de prueba | 👤 | Procedimiento comentado en §6; falta ejecutarlo y pegar la URL o captura |

## S8 · DAST

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| ZAP baseline en el pipeline + comando exacto con versión | ✅ | Job `dast`, [reporte-dast.md](sesion-08-dast/reporte-dast.md) §1 |
| Tabla de hallazgos (severidad, CWE, URL, evidencia) | 🟡 | Tabla **ilustrativa** antes/después; 👤 reemplazar con el `report.json` real |
| Timestamp, screenshots y `report.json` adjunto | 👤 | Salen del artefacto `dast-report-<sha>` del CI |
| Plan de mitigación para **todo** High/Medium, con responsable, plazo y verificación | 🟡 | [plan-mitigacion.md](sesion-08-dast/plan-mitigacion.md) (agrega CSP `form-action`, cabecera `Server` y Spectre, derivados del resultado ilustrativo; 👤 confirmar con el `report.json` real) |
| Cada fila cerrada con un nuevo scan | 👤 | Re-scan después de aplicar el plan |
| BOLA corregido + test 403 | ✅ | [test_bola.py](../tests/security/test_bola.py) |
| PDF de 2–3 páginas | 👤 | |

## S9 · Quality Gates

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| Umbrales justificados, cobertura, no secrets, criterio de riesgo, 2 casos, pruebas | ✅ | [policy/](../policy/README.md), 20 tests OPA, fixtures green/red |
| Auditabilidad | ✅ | Evidencia del gate guardada 90 días; CODEOWNERS ya cubre `policy/` y `config/` |
| Contexto de riesgo verídico | ✅ | [security-context.json](../config/security-context.json) sin `waf` ni `rate_limiting` (no existen) |

## S10 · Docker

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| Base slim con tag fijo, `USER`, `.dockerignore`, `EXPOSE 8000`, sin caches | ✅ | [Dockerfile.v2](../docker/Dockerfile.v2) |
| REPORT: Trivy de ambas, tabla, cambios, evidencia, riesgos residuales | ✅ | [REPORT.md](../docker/REPORT.md) §1–§5 + §6 con la actualización de los riesgos |
| Demostrar la mejora en vulnerabilidades | 🟡 | v1 dio 0 (fue un `ubuntu:latest` recién parcheado) y v2 da 50 HIGH (47 sin parche). La mejora medible está en superficie (−43 % de tamaño, −35 % de paquetes, sin root, sin puerto 22). 👤 Aplicar `apt-get upgrade` (comentado en el Dockerfile) y volver a escanear |

## S11 · IaC

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| Terraform corregido + `iac.yml` scan → gate → plan → apply | ✅ | El gate es el exit code de Checkov (justificado en el informe) |
| Checkov after ≥ 85 % y 0 CRITICAL/HIGH | ✅ | 307/0/15 → 100 % |
| Checkov before (20 % de la rúbrica) | 🟡 | Estimación **ilustrativa** en el [informe](sesion-11-iac/informe-iac.md); 👤 generar `checkov-before.json` real (comando comentado) |
| Informe: top 5 hallazgos y cómo se corrigieron | ✅ | [informe-iac.md](sesion-11-iac/informe-iac.md) §2, con checks reales verificados en el `.tf` |
| Commit CRITICAL bloquea + captura en verde | 👤 | Prueba comentada en el informe §3 |
| PDF de 2–3 páginas | 👤 | Exportar el informe |

## S12 · Kubernetes

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| runAsNonRoot + uid > 1000, readOnlyRootFilesystem, drop ALL, limits, allowPrivilegeEscalation false | ✅ | [deployment.hardened.yaml](../k8s/hardened/deployment.hardened.yaml) |
| Secretos vía `secretKeyRef` | ✅ | Ahora incluye `JWT_SECRET` y `DATABASE_URL`, que exige la app |
| Corresponde a uno de los manifiestos M1–M5 | ✅ | M2 (`api-deployment.yaml`), declarado en el encabezado |
| Imagen por digest, desplegable con `kubectl apply` | 🟡 | 👤 Reemplazar el digest de ejemplo por el que publique S13 |
| Validación con kube-score / kubesec | 👤 | Comandos comentados en el encabezado del YAML |

## S13 · Supply chain

| Ítem de la presentación | Estado | Evidencia / qué falta |
|---|---|---|
| Build de `securebank:v1` + digest en los logs | ✅ | Ahora con la imagen real (`docker/Dockerfile.v2`) + tag por SHA |
| SBOM CycloneDX (Syft) + `cosign attest` | ✅ | |
| Firma Cosign keyless | ✅ | |
| Entrada visible en Rekor | 🟡 | Paso comentado que imprime el `logIndex`; 👤 ejecutar y documentar |
| Verificación que bloquea el deploy | 🟡 | El paso `cosign verify` corta con exit 1; los jobs `verify` → `deploy` separados quedan comentados |
| Captura del pipeline rojo ante una imagen no firmada | ✅ | [captura_verificar-firma.PNG](sesion-13-supply-chain/captura_verificar-firma.PNG) |
| Documento de análisis (máx. 1 página) | ✅ | [supply_chain_analisis.md](sesion-13-supply-chain/supply_chain_analisis.md) |
| SBOM y firma de la imagen de SecureBank | 👤 | El `sbom.zip` actual es del alpine de prueba; el próximo run lo genera sobre la imagen real |
