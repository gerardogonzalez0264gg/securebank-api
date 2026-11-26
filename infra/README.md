# Infraestructura (Terraform) · SecureBank API

Esqueleto de infraestructura como código de la Sesión 11 (IaC y Cloud Security). Define los 20 recursos del stack y los recursos de apoyo que necesitan. El diseño y los controles están en `docs/architecture.md` (sección 5) y el pipeline en `docs/sesion-04-ci/pipeline.md`.

```text
infra/terraform/
  versions.tf    providers y backend S3 (estado remoto, se configura en el pipeline)
  variables.tf   región, CIDR, zonas, certificado ACM, repositorio de GitHub, tamaños
  network.tf     vpc_main, subnet_pub, subnet_priv, sg_public, sg_api, sg_worker, sg_db, flow_logs
  compute.tf     ec2_web, ec2_worker, ebs_volume, lambda_api
  database.tf    rds_postgres, dynamodb_txn
  storage.tf     s3_backups, s3_logs
  iam.tf         iam_role_admin, iam_role_ci (OIDC) y roles de servicio
  kms.tf         kms_key
  alb.tf         alb_public
  logging.tf     cloudtrail
  ecr.tf         ecr_repo
```

## Probar en tu equipo

```bash
cd infra/terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate

pip install checkov==3.4.6
checkov -d . --framework terraform --compact
```

Estado actual: Checkov con 307 aprobados, 0 fallidos y 15 omitidos (`docs/sesion-11-iac/checkov-after.json`). `terraform validate` lo ejecuta el CI. `terraform plan` necesita credenciales de AWS y estado remoto, así que corre en el job `plan` cuando se configuran las variables de abajo.

## Variables del repositorio (Settings → Variables)

`plan` y `apply` solo corren si existe `AWS_ROLE_ARN`.

| Variable | Uso |
|---|---|
| `AWS_ROLE_ARN` | Rol que asume el pipeline por OIDC, creado aparte (bootstrap) |
| `AWS_REGION` | Región (debe coincidir con `availability_zones`) |
| `TF_STATE_BUCKET` | Bucket S3 del estado remoto, creado aparte |
| `CERTIFICATE_ARN` | Certificado ACM del listener HTTPS |

`apply` solo corre en `main` y usa el environment `production`, que debe tener revisores requeridos.

## OIDC del CI

El rol `iam_role_ci` (salida `ci_role_arn`) lo asume GitHub Actions por OIDC, solo desde `main` del repositorio indicado en `github_repository`, y solo puede subir imágenes a ECR. Si la cuenta ya tiene el proveedor OIDC de GitHub, pasar su ARN en `github_oidc_provider_arn` para no crear otro.

## Checks omitidos (con motivo)

Checkov OSS no asigna severidad, así que el gate falla ante cualquier hallazgo. Lo que no se corrige queda omitido en el propio `.tf` con `#checkov:skip` y su motivo:

| Check | Dónde | Motivo |
|---|---|---|
| CKV_AWS_109 / 111 / 356 | `kms.tf` | Key policy estándar: el root de la cuenta administra la clave y `Resource "*"` significa "esta clave" |
| CKV_AWS_356 | `iam.tf` | `ecr:GetAuthorizationToken` no admite restricción por recurso |
| CKV_AWS_252 | `logging.tf` | Notificaciones SNS pertenecen a Monitor, fuera de la Sesión 11 |
| CKV_AWS_116 | `compute.tf` | DLQ de `lambda_api` pendiente (esqueleto) |
| CKV_AWS_272 | `compute.tf` | Firma de código pertenece a Release, fuera de la Sesión 11 |
| CKV_AWS_144 (x2) | `storage.tf` | Replicación cross-region pendiente (segundo provider y costo) |
| CKV2_AWS_62 (x2) | `storage.tf` | Sin consumidor de eventos definido en el esqueleto |
| CKV_AWS_18 (x2) | `storage.tf` | Los access logs de S3 requieren un bucket destino con SSE-S3, no con SSE-KMS |
| CKV_AWS_91 | `alb.tf` | Los access logs del ALB tampoco admiten SSE-KMS; falta un bucket dedicado |
| CKV2_AWS_28 | `alb.tf` | WAF pertenece a Operate, fuera de la Sesión 11 |

## Notas

* `rds_postgres` usa `db.t3.medium` por defecto porque Performance Insights no está disponible en `db.t3.micro`.
* `lambda_api` reserva 10 ejecuciones concurrentes; en cuentas nuevas con límite de 10 en total, bajar o quitar `reserved_concurrent_executions`.
