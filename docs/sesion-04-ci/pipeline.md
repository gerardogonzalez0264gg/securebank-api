# Pipeline CI/CD de SecureBank

## Objetivo

Automatizar el camino del código: bajarlo, compilarlo, probarlo y guardarlo, y dejar un lugar listo para sumar controles de seguridad.

## Flujo del pipeline

1. Commit
2. Build
3. Unit Test
4. Security Test (se agrega en la clase 5)
5. Package
6. Deploy

## Pipeline actual (CI v1.0)

El archivo es `.github/workflows/ci.yml`. Se activa con cada push a `main` o `feature/**` y con cada PR hacia `main`. Hace esto:

1. Descarga el código (checkout).
2. Prepara Node 20.
3. Instala las librerías con `npm ci` (versiones exactas).
4. Compila (`npm run build`).
5. Corre las pruebas (`npm test`).
6. Guarda el resultado `dist/` como artefacto por 7 días, con el código del commit en el nombre.

Tiene permisos mínimos (`contents: read`) y no guarda secretos en el archivo.

## Pipeline IaC Security (Sesión 11)

La infraestructura también es código, así que tiene su propio pipeline con una compuerta de seguridad antes de desplegar.

```text
Commit -> IaC Scan + Validate (gate) -> Plan -> Apply
```

| Etapa | Qué hace | Herramienta / regla |
|---|---|---|
| Commit | Push a la rama de feature y Pull Request | Revisión por pares |
| IaC Scan | Analiza los `.tf` antes de desplegar | `checkov -d infra/terraform` |
| Validate | Comprueba formato y sintaxis, sin credenciales | `terraform fmt -check`, `terraform init -backend=false`, `terraform validate` |
| Gate | Detiene el pipeline si falla el scan o el validate | Cualquier hallazgo bloquea el PR; `plan` y `apply` no corren |
| Plan | Calcula los cambios | `terraform plan` |
| Apply | Despliega a la nube | `terraform apply`; en producción, con aprobación manual |

- Complemento opcional: `trivy config ./terraform`.
- Archivo: `.github/workflows/iac.yml`. Se activa al cambiar `infra/**`. `plan` y `apply` solo corren si el repositorio define `AWS_ROLE_ARN` y las demás variables descritas en `infra/README.md`.
- Checkov OSS no asigna severidad, así que el gate falla ante cualquier hallazgo. Resultados, checks omitidos y motivos: `infra/README.md` y `docs/sesion-11-iac/checkov-after.json`.
- Criterios de aceptación: un commit con violación CRITICAL bloquea el pipeline, Security Score final de 85 % o más, cero hallazgos CRITICAL o HIGH abiertos, y reportes Checkov before/after en JSON.
- Security Score = (checks aprobados / checks totales) × 100.

## Tres formas de automatizar

| Práctica | Hasta dónde llega solo | ¿Aprueba una persona? |
|---|---|---|
| Integración continua (CI) | Compila y prueba | No aplica al despliegue |
| Entrega continua | Deja todo listo en staging | Sí, una persona decide pasar a producción |
| Despliegue continuo | Llega a producción | No, todo es automático |

SecureBank es un banco, así que lo correcto sería entrega continua, con aprobación humana.

## Piezas del pipeline

| Pieza | Qué es |
|---|---|
| Runner | La máquina que ejecuta el trabajo (`ubuntu-latest`) |
| Job | Un grupo de pasos (`build-test`) |
| Step | Un paso suelto (`npm ci`) |
| Artifact | El archivo que deja el trabajo (`dist/`) |
| Environment | El lugar de destino (dev, staging, producción) |
| Trigger | Lo que lo activa (push o pull request) |
| Secret | Un dato privado guardado fuera del archivo |
| Workflow | El archivo completo (`ci.yml`) |

## Ejercicio: pipeline inseguro

| # | Línea peligrosa | Qué podría hacer un atacante | Corrección | Tipo STRIDE |
|---|---|---|---|---|
| R1 | `permissions: write-all` | Con un token robado podría cambiar el repo y publicar versiones | `permissions: contents: read` | Elevación de privilegios |
| R2 | `curl http://... \| sudo bash` | Si alguien hackea ese sitio, corre su código con permisos de administrador | Usar acciones oficiales con versión fija y no ejecutar scripts sin verificar | Manipulación |
| R3 | `npm install express body-parser jsonwebtoken` | Si una librería cambia, entra código malicioso en cada build | Usar `npm ci` con `package-lock.json` y agregar `npm audit` | Manipulación |
| R4 | `DB_PASSWORD: 'P@ssw0rd...'` | Quien vea el repo ve la clave, y queda en el historial para siempre | `DB_PASSWORD: ${{ secrets.DB_PASSWORD }}` y cambiar la clave | Divulgación de información |

## Seguridad del pipeline

- No guardar secretos en el repositorio.
- Usar permisos mínimos.
- Usar solo acciones confiables y con versión fija.
- Mantener el pipeline versionado y revisado por PR.

## Estado actual (2026-11-25)

El CI v1.0 de esta sesión fue creciendo con cada clase. Hoy hay tres workflows:

```text
ci.yml
  secret-scan (Gitleaks, S7) ─┬─> build (CI v1.0, S4) ──> dast (pytest security + ZAP, S8) ─┐
                              ├─> sast (Semgrep, S5) ───────────────────────────────────────┤
                              ├─> sca (Trivy, S6) ──────────────────────────────────────────┼─> gate (OPA, S9)
                              └─> coverage (pytest-cov) ────────────────────────────────────┘
iac.yml           iac-scan (Checkov) + terraform-validate ─> plan ─> apply con aprobación (S11)
supply-chain.yml  build y push por digest ─> SBOM (Syft) ─> cosign sign/attest ─> cosign verify (S13)
```

| Job | Sesión | Qué hace | ¿Bloquea? |
|---|---|---|---|
| `secret-scan` | S7 | Gitleaks sobre todo el historial | Sí, con exit 1 si hay un secreto |
| `build` | S4 | checkout → `npm ci` → build → test → artefacto `dist-<sha>` (7 días) | Si falla el build |
| `sast` | S5 | Semgrep `p/default` → `sast.sarif` | No; decide el gate |
| `sca` | S6 | Trivy fs → `sca.json` (pasos de SBOM y reporte comentados, ver `reports/README.md`) | No; decide el gate |
| `coverage` | S9 | `pytest --cov=src` → `coverage.json` | Si falla un test |
| `dast` | S8 | Tests de seguridad + ZAP baseline sobre un contenedor efímero | No (`-I`); decide el gate |
| `gate` | S9 | Consolida todo en `findings.json` y evalúa `policy/security-policy-v1.rego` | **Sí**: `BLOCK` → exit 1 (falla cerrada con `if: always()`) |

Pendiente: los `plan`/`apply` de `iac.yml` solo corren cuando se configuran las variables de AWS, y el job `build` sigue siendo el de Node de esta sesión (de relleno).

## Etapa DAST (Sesión 8)

El job `dast` de `ci.yml` corre después de `build`: ejecuta los tests de seguridad (`tests/security`), levanta SecureBank en un contenedor efímero (`docker-compose.dast.yml`), lanza **OWASP ZAP Baseline** contra `http://localhost:8080` y sube `report.html`, `report.json` y `report.md` como artefacto por 14 días. Usa `-I`, así que no rompe el build por advertencias: los umbrales de pass/fail llegan con los Quality Gates (Sesión 9). Detalle y entregable en `docs/sesion-08-dast/`.
