# Procedimiento de gestión y rotación de secretos · SecureBank API

Documento de la Sesión 7. Versión 1.0 · 2026-11-25 · Próxima revisión: 2027-02-25 (cada 3 meses, igual que [POL-REPO-001](sesion-02-repos/POL-REPO-001.md)).
SecureBank es un caso hipotético. Los secretos "de producción" de este documento son los que tendría la API si existiera. Los que se usan hoy en el CI son efímeros.

## §1 · Inventario de secretos

| Secreto | Tipo | Quién lo usa | Dónde vive hoy | Dónde viviría en producción |
|---|---|---|---|---|
| `JWT_SECRET` | Clave de firma HS256 (≥ 32 caracteres) | `src/auth/tokens.py` | Variable de entorno. En el CI se genera en cada run (`openssl rand`) y se enmascara | GitHub Secrets (staging) / Vault (producción) |
| `DATABASE_URL` | Connection string (puede llevar usuario y clave) | `src/config.py` | Variable de entorno | Vault, con credenciales dinámicas de BD |
| `SEED_ALICE_PW`, `SEED_BOB_PW` | Contraseñas de usuarios de prueba | `lab/dast/seed.py` | Efímeras en el job `dast` | No existen en producción |
| `GITHUB_TOKEN` | Token del pipeline | `supply-chain.yml` (push a GHCR) | Lo emite GitHub por ejecución | Igual (efímero, permisos mínimos) |
| Identidad OIDC de AWS | Credencial temporal | `iac.yml` (`plan` / `apply`) | Rol `vars.AWS_ROLE_ARN`, sin claves estáticas | Igual |
| Firma Cosign | Certificado keyless (Fulcio) | `supply-chain.yml` | Efímero, ligado a la identidad del workflow | Igual |
| `DB_PASSWORD` (K8s) | Contraseña de BD | `k8s/hardened/deployment.hardened.yaml` | `Secret` de Kubernetes (`secretKeyRef`) | Secret cifrado con KMS o sincronizado desde Vault |

Las contraseñas de usuarios no son secretos de la aplicación: se guardan como hash bcrypt (`src/auth/auth.py`).

## §2 · Alternativas elegidas y justificación

| Caso | Alternativa | Por qué |
|---|---|---|
| Desarrollo local | Variables de entorno desde `.env`, copiado de [.env.example](../.env.example) | Simple. `.env` está en `.gitignore` y `.dockerignore` |
| CI (tests y DAST) | Secretos efímeros generados en el job y enmascarados con `::add-mask::` | No hay nada que robar: el secreto muere con el runner |
| CI → nube | OIDC (`aws-actions/configure-aws-credentials`) | Credenciales temporales, sin claves de larga duración en GitHub |
| Staging | GitHub Secrets por environment | Cifrado, auditado y con acceso limitado por environment |
| Producción | HashiCorp Vault (KV + credenciales dinámicas de BD) | Rotación automática, leases cortos y registro de cada acceso |
| Kubernetes | `secretKeyRef` + cifrado en reposo con KMS | El valor nunca aparece en el manifiesto (`env.value`) |

`src/config.py` es la defensa en el código: la app **no arranca** si falta un secreto, si es un valor de ejemplo (`changeme`, `password`…) o si `JWT_SECRET` tiene menos de 32 caracteres.

## §3 · Configuración de Gitleaks

| Capa | Archivo | Qué hace |
|---|---|---|
| Reglas | [.gitleaks.toml](../.gitleaks.toml) | Reglas oficiales (`useDefault`) + regla propia `securebank-hardcoded-password`. Excepciones: `${VAR}` y ejemplos en `docs/*.md` |
| Pre-commit | [.pre-commit-config.yaml](../.pre-commit-config.yaml) | Gitleaks v8.18.4 antes de cada commit (`pre-commit install`) |
| CI | Job `secret-scan` en [ci.yml](../.github/workflows/ci.yml) | Revisa **todo el historial** (`fetch-depth: 0`), `--exit-code 1` y reporte SARIF. Es la primera etapa: SAST y SCA dependen de ella |

```bash
pip install pre-commit && pre-commit install
gitleaks detect --source . --config .gitleaks.toml --redact --verbose
```

## §4 · Política de rotación

| Secreto | Frecuencia | Responsable | Disparadores extra |
|---|---|---|---|
| `JWT_SECRET` | Cada 90 días | Secret Custodian | Fuga, salida de un integrante, sospecha de tokens forjados |
| Credenciales de BD | Cada 90 días (en Vault: leases de 24 h) | Secret Custodian + SRE | Fuga o cambio de proveedor |
| GitHub Secrets | Cada 90 días | Secret Custodian | Cambio en el equipo |
| `GITHUB_TOKEN`, OIDC, Cosign | En cada ejecución | Automático | — |
| Contraseñas de seed | En cada ejecución | Automático | — |

Al rotar `JWT_SECRET` se invalidan todos los tokens. Como duran como máximo 60 minutos (`JWT_TTL_MINUTES`), el efecto es que los usuarios vuelven a iniciar sesión.

**Rotación ejecutable.** Script de referencia, comentado para que no se ejecute sin un entorno real:

```bash
# scripts/rotate_jwt_secret.sh (referencia, NO ejecutar sin Vault/GitHub configurados)
# set -euo pipefail
# NEW="$(openssl rand -base64 48)"
# # 1. Guardar el nuevo valor (producción en Vault, staging en GitHub Secrets)
# vault kv put secret/securebank/jwt JWT_SECRET="$NEW"
# gh secret set JWT_SECRET --env staging --body "$NEW"
# # 2. Redesplegar para que los pods lean el valor nuevo
# kubectl -n securebank rollout restart deployment/securebank-api
# # 3. Dejar registro (sin el valor)
# echo "$(date -u +%FT%TZ) JWT_SECRET rotado por $USER" >> rotaciones.log
```

## §5 · Procedimiento de respuesta ante una fuga

| Paso | Plazo | Responsable | Acción | Evidencia |
|---|---|---|---|---|
| 1. Detectar | Minuto 0 | SecOps | Alerta de Gitleaks (pre-commit o CI). Confirmar el tipo de secreto y su alcance | Run del CI o reporte SARIF |
| 2. Revocar | ≤ 15 min | Dueño del servicio | Invalidar la credencial en el proveedor (AWS, GitHub, BD) | Registro del proveedor |
| 3. Rotar | Sin downtime | DevOps | Generar una credencial nueva, publicarla en Vault/Secrets y redesplegar (§4) | Registro de rotación |
| 4. Limpiar | Coordinado | Maintainer del repo | `git filter-repo --replace-text` o BFG, force push coordinado, avisar a los forks e invalidar caches | PR o issue de limpieza |
| 5. Notificar | ≤ 24 h | Lead de seguridad | Avisar a los stakeholders y hacer un post-mortem sin culpables | Documento post-mortem |

Borrar el archivo **no** borra el secreto: sigue en el historial, en los forks y en los logs. Por eso **revocar va antes que limpiar**.

## §6 · Evidencia de un ciclo real

Prueba que demuestra que el pipeline bloquea un secreto. Queda comentada para no meter un secreto falso en el historial de `main`:

```bash
# git switch -c test/gitleaks-bloqueo
# echo 'db_pass = "S3cr3tDePrueba!"' > src/leak_test.py    # activa la regla securebank-hardcoded-password
# git add src/leak_test.py && git commit -m "test: secreto de prueba" --no-verify
# git push -u origin test/gitleaks-bloqueo
# # Resultado esperado: job "Secret Scan (Gitleaks)" en rojo, exit code 1, y sast/sca/build no se ejecutan.
# # Luego: borrar la rama remota y local (el secreto es falso, no hace falta rotar).
```

| Campo | Valor |
|---|---|
| Rama de prueba | `TODO(equipo)`: `test/gitleaks-bloqueo` |
| URL del run en rojo | `TODO(equipo)`: pegar el enlace de GitHub Actions |
| Captura | `TODO(equipo)`: `docs/img/gitleaks-bloqueo.png` |
| Regla que disparó | `securebank-hardcoded-password` |
| Resultado | El job falla con exit code 1 y las etapas siguientes no corren |
