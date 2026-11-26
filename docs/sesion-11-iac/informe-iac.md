# Informe técnico · Pipeline IaC Security · SecureBank-Infra (Sesión 11)

Proyecto hipotético SecureBank. Herramienta: Checkov 3.4.6 sobre [infra/terraform/](../../infra/terraform/). Pipeline: [iac.yml](../../.github/workflows/iac.yml). Exportar a PDF de 2–3 páginas para la entrega.

## 1. Resultado before / after

| Ejecución | Aprobados | Fallidos | Omitidos | Security Score | Evidencia |
|---|---|---|---|---|---|
| Before (módulo vulnerable del ejercicio) | ~214 | ~93 | 0 | **~70 %** ⚠️ ilustrativo | `TODO(equipo)`: `checkov-before.json` real (comando abajo) |
| After (estado actual de `main`) | 307 | 0 | 15 | **100 %** (≥ 85 % ✓) | [checkov-after.json](checkov-after.json) |

Security Score = aprobados / (aprobados + fallidos) × 100. Los 15 omitidos tienen su motivo en el propio `.tf` (`#checkov:skip`) y en [infra/README.md](../../infra/README.md).

> ⚠️ Los números del "before" son una **estimación ilustrativa**: no hay un JSON del módulo vulnerable original en el repo. Para generarlo, se corre Checkov sobre el commit anterior a las correcciones (comandos comentados, no se ejecutan solos):
>
> ```bash
> # git worktree add /tmp/infra-before <commit-anterior-a-las-correcciones>
> # checkov -d /tmp/infra-before/infra/terraform --framework terraform \
> #   --output json > docs/sesion-11-iac/checkov-before.json
> # git worktree remove /tmp/infra-before
> ```

## 2. Los 5 hallazgos más críticos y cómo se corrigieron

Son checks que fallarían en un stack bancario sin endurecer y que hoy aparecen como **aprobados** en `checkov-after.json`.

| # | Check | Recurso | Riesgo | Corrección aplicada |
|---|---|---|---|---|
| 1 | CKV_AWS_17 · RDS públicamente accesible | `aws_db_instance.rds_postgres` | La BD de cuentas y saldos expuesta a Internet | `publicly_accessible = false`, subred privada, `sg_db` solo acepta tráfico de `sg_api` ([database.tf](../../infra/terraform/database.tf)) |
| 2 | CKV_AWS_24 / CKV_AWS_25 · SG con 0.0.0.0/0 a 22/3389 | `aws_security_group.sg_public` | Fuerza bruta de SSH/RDP sobre las instancias | Solo 443 público en el ALB, sin SSH; la administración se hace por SSM ([network.tf](../../infra/terraform/network.tf)) |
| 3 | CKV_AWS_63 · IAM con `"*"` en acciones | `aws_iam_role_policy.*` | Una credencial robada daría control total de la cuenta | Roles de mínimo privilegio; el CI usa OIDC y solo puede hacer push a ECR ([iam.tf](../../infra/terraform/iam.tf)) |
| 4 | CKV_AWS_16 / CKV_AWS_19 / CKV_AWS_145 · datos sin cifrar | RDS, S3 `s3_backups` y `s3_logs` | Lectura de respaldos o de la BD en reposo | Cifrado con KMS propio y rotación activada (CKV_AWS_7) ([kms.tf](../../infra/terraform/kms.tf), [storage.tf](../../infra/terraform/storage.tf)) |
| 5 | CKV_AWS_20 / CKV_AWS_53 / CKV2_AWS_6 · S3 público | `aws_s3_bucket.s3_logs`, `s3_backups` | Fuga de respaldos y de logs con datos de clientes | `aws_s3_bucket_public_access_block` con los 4 bloqueos y sin ACL pública |

Otros controles relevantes que pasan: CloudTrail en todas las regiones (CKV_AWS_67), VPC flow logs (CKV2_AWS_11), IMDSv2 obligatorio (CKV_AWS_79), EBS cifrado (CKV_AWS_8) y RDS Multi-AZ (CKV_AWS_157).

## 3. El gate bloquea despliegues inseguros

- El job `iac-scan` corre Checkov **sin** `--soft-fail`: cualquier hallazgo fallido termina con exit ≠ 0. Como `plan` depende de `iac-scan` y `terraform-validate`, `plan` y `apply` no se ejecutan.
- `apply` solo corre en `main` y con el environment `production`, que exige aprobación humana.
- Scan y gate van en un mismo job: el exit code de Checkov **es** la compuerta. La diapositiva muestra 4 etapas (scan → gate → plan → apply) y aquí se cumplen igual, con el gate implícito en el resultado del scan.

Prueba de bloqueo (comentada; hacerla en una rama de prueba y guardar la captura):

```bash
# git switch -c test/iac-critical
# # en infra/terraform/database.tf:  publicly_accessible = true
# git commit -am "test: RDS publica (debe bloquear)" && git push -u origin test/iac-critical
# # Esperado: job "IaC Scan + Gate (Checkov)" en rojo por CKV_AWS_17; plan/apply no corren.
```

| Evidencia | Estado |
|---|---|
| Captura del pipeline en verde con el gate aplicado | `TODO(equipo)` |
| Captura del commit con violación CRITICAL bloqueado | `TODO(equipo)` |
