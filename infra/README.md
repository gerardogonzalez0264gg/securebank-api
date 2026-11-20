# Infraestructura (Terraform) · SecureBank API

Esqueleto de infraestructura como código de la Sesión 11 (IaC y Cloud Security). Define los 20 recursos del stack, más los recursos de apoyo que necesitan (`sg_app`, roles IAM, parameter group de RDS, log group de CloudTrail).

```text
infra/terraform/
  versions.tf    providers y backend S3 (estado remoto, se configura en el pipeline)
  variables.tf   región, CIDR, zonas, certificado ACM, tamaños
  network.tf     vpc_main, subnet_pub, subnet_priv, sg_public, sg_app, sg_db, flow_logs
  compute.tf     ec2_web, ec2_worker, ebs_volume, lambda_api
  database.tf    rds_postgres, dynamodb_txn
  storage.tf     s3_backups, s3_logs
  iam.tf         iam_role_admin, iam_user_ci y roles de servicio
  kms.tf         kms_key
  alb.tf         alb_public
  logging.tf     cloudtrail
  ecr.tf         ecr_repo
```

## Escaneo local

```bash
pip install checkov==3.4.6
checkov -d infra/terraform --framework terraform --compact
```

Resultado actual: 279 aprobados, 0 fallidos, 13 omitidos (`docs/iac-report/checkov-after.json`).

## Checks omitidos (con motivo)

Checkov OSS no asigna severidad, así que el gate falla ante cualquier hallazgo. Lo que no se corrige queda omitido en el propio `.tf` con `#checkov:skip` y su motivo:

| Check | Dónde | Motivo |
|---|---|---|
| CKV_AWS_109 / 111 / 356 | `kms.tf` | Key policy estándar: el root de la cuenta administra la clave y `Resource "*"` significa "esta clave" |
| CKV_AWS_252 | `logging.tf` | Notificaciones SNS pertenecen a Monitor, fuera de la Sesión 11 |
| CKV_AWS_116 | `compute.tf` | DLQ de `lambda_api` pendiente (esqueleto) |
| CKV_AWS_272 | `compute.tf` | Firma de código pertenece a Release, fuera de la Sesión 11 |
| CKV_AWS_273 | `iam.tf` | `iam_user_ci` lo exige el stack de la sesión; sin access keys; reemplazar por OIDC |
| CKV_AWS_144 (x2) | `storage.tf` | Replicación cross-region pendiente (segundo provider y costo) |
| CKV2_AWS_62 (x2) | `storage.tf` | Sin consumidor de eventos definido en el esqueleto |
| CKV_AWS_91 | `alb.tf` | Los access logs del ALB no admiten buckets con SSE-KMS; falta un bucket dedicado |
| CKV2_AWS_28 | `alb.tf` | WAF pertenece a Operate, fuera de la Sesión 11 |

## Pipeline

`.github/workflows/iac.yml` ejecuta scan → gate → plan → apply. El scan y el gate corren siempre que cambie `infra/`. `plan` y `apply` se activan cuando el repositorio define estas variables (Settings → Variables):

| Variable | Uso |
|---|---|
| `AWS_ROLE_ARN` | Rol que asume el pipeline por OIDC (sin claves estáticas) |
| `AWS_REGION` | Región (debe coincidir con `availability_zones`) |
| `TF_STATE_BUCKET` | Bucket S3 del estado remoto, creado aparte |
| `CERTIFICATE_ARN` | Certificado ACM del listener HTTPS |

`apply` solo corre en `main` y usa el environment `production`, que debe tener revisores requeridos (aprobación manual).

> Limitación: este módulo se validó con Checkov y análisis sintáctico HCL, pero no se ejecutó `terraform validate` ni `plan` contra AWS.
