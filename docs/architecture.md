# Arquitectura - SecureBank API

## 1. Descripción general

SecureBank API es una plataforma financiera simulada utilizada para practicar la aplicación de principios DevSecOps.

El sistema está compuesto por un frontend web, una API REST, un servicio de autenticación y una base de datos.

La arquitectura permite separar las responsabilidades de presentación, procesamiento de solicitudes, autenticación y almacenamiento de información.

Todos los componentes se despliegan sobre infraestructura cloud definida como código (IaC, Terraform), versionada en Git, revisada por Pull Request y escaneada antes de desplegarse (ver sección 5 y `docs/pipeline.md`).

---

## 2. Componentes principales

### Frontend Web

Es la interfaz utilizada por los usuarios para interactuar con SecureBank.

Sus principales responsabilidades son:

* Permitir el inicio de sesión.
* Permitir consultar información de cuentas.
* Permitir realizar operaciones.
* Enviar solicitudes a la API REST.

### Backend REST API

Es el componente encargado de procesar las solicitudes provenientes del frontend.

Sus principales módulos son:

* Autenticación.
* Cuentas.
* Transferencias.
* Usuarios.
* Movimientos e historial.

La API contiene los endpoints que permiten acceder a las funcionalidades de SecureBank.

### Servicio de autenticación

Es responsable de gestionar la autenticación de los usuarios.

Entre los elementos relacionados con este componente se encuentran:

* Login.
* Credenciales.
* Sesiones.
* Tokens JWT.

### Base de datos

Es el componente encargado de almacenar la información de SecureBank.

Entre los datos almacenados se consideran:

* Datos de usuarios.
* Datos de clientes.
* Información de cuentas.
* Saldos.
* Transferencias.
* Movimientos e historial.

---

## 3. Flujo principal

El flujo principal de comunicación es:

```text
Usuario
   |
   | HTTPS
   v
Frontend Web
   |
   | Solicitud HTTP/HTTPS
   v
Backend REST API
   |
   +----------------------+
   |                      |
   v                      v
Servicio de          Base de Datos
Autenticación
   |
   v
Tokens JWT
```

### Flujo de una solicitud

1. El usuario interactúa con el frontend.
2. El frontend envía una solicitud hacia la API REST.
3. La API recibe y procesa la solicitud.
4. Cuando corresponde, se valida la autenticación del usuario.
5. La API verifica los permisos necesarios para realizar la operación.
6. La API consulta o modifica información en la base de datos.
7. La respuesta es enviada nuevamente al frontend.

---

## 4. Módulos de la API

### Auth

Gestiona las funciones relacionadas con la autenticación de usuarios.

Ejemplos:

* Login.
* Validación de credenciales.
* Gestión de sesión.
* Tokens JWT.

### Accounts

Gestiona las cuentas bancarias.

Ejemplos:

* Consulta de cuentas.
* Consulta de saldos.
* Acceso a información de cuentas.

### Transfers

Gestiona las transferencias bancarias.

Endpoint crítico utilizado durante el Threat Modeling:

```text
POST /transfer
```

Este endpoint requiere controles de autenticación, autorización y validación de entradas.

### Users

Gestiona la información relacionada con los usuarios.

Ejemplos:

* Registro.
* Perfil.
* Información del usuario.

### Movements

Gestiona el historial e información relacionada con las operaciones realizadas.

---

## 5. Infraestructura cloud (IaC)

La infraestructura se declara en archivos Terraform (`infra/terraform/`, ver `infra/README.md`) y se trata igual que la aplicación: versionada, revisada por Pull Request y escaneada con Checkov antes de `terraform apply`. Así la infraestructura vulnerable nunca llega a existir (Shift-Left).

### 5.1 Segmentación de red

```text
Internet
   |
   | HTTPS 443
   v
[alb_public]            Subred pública (subnet_pub)
   |                    sg_public: solo 443 desde Internet
   v
------------------------ VPC 10.0.0.0/16 (vpc_main) ------------------------
[ec2_web / lambda_api]  Subred privada (subnet_priv)  - API REST (sg_app: solo desde el ALB)
   |
   | 5432, solo desde sg_app
   v
[rds_postgres]          sg_db, publicly_accessible = false
```

Reglas de red:

* Ningún Security Group abre `0.0.0.0/0` sobre puertos administrativos (SSH 22, RDP 3389).
* No existe SSH: el acceso administrativo es por SSM Session Manager (rol `iam_role_admin`), sin puertos abiertos.
* La base de datos no es accesible desde Internet; solo acepta tráfico de la API.

### 5.2 Recursos del stack y control exigido

| Capa | Recursos | Control exigido |
| --- | --- | --- |
| Red | `vpc_main`, `subnet_pub`, `subnet_priv`, `sg_public`, `sg_app`, `sg_db` | Sin `0.0.0.0/0` en puertos administrativos; solo 443 público vía ALB; API solo desde el ALB; BD solo desde la API |
| Cómputo | `ec2_web`, `ec2_worker`, `lambda_api`, `ebs_volume` | Sin IP pública ni SSH; IMDSv2 obligatorio; volúmenes cifrados |
| Datos | `rds_postgres`, `dynamodb_txn` | `storage_encrypted = true`, `publicly_accessible = false`, TLS obligatorio, clave gestionada por Secrets Manager |
| Almacenamiento | `s3_backups`, `s3_logs` | Privados (`block_public_acls = true`) y cifrados con KMS (`sse_algorithm = "aws:kms"`) |
| Identidad | `iam_role_admin`, `iam_user_ci` | Sin `Action: "*"` ni `Resource: "*"`; menor privilegio; CI solo puede subir imágenes a `ecr_repo` |
| Cifrado | `kms_key` | Clave usada para cifrar datos en reposo |
| Trazabilidad | `cloudtrail`, `flow_logs` | Habilitados; CloudTrail multi-región con validación de integridad y envío a CloudWatch Logs; logs y query logging de RDS |
| Otros | `alb_public`, `ecr_repo` | Pasan por el mismo escaneo Checkov |

### 5.3 Riesgos OWASP abordados con IaC (Sesión 11)

| OWASP | Problema detectado | Mejora en la arquitectura |
| --- | --- | --- |
| A01 Broken Access Control | Transferencias sin verificar rol | Roles IAM con menor privilegio (sin `Action: "*"` / `Resource: "*"`), por ejemplo solo `s3:GetObject` sobre el ARN del bucket. La verificación de rol dentro de la API sigue siendo responsabilidad del backend |
| A02 Cryptographic Failures | Secretos en texto plano | Datos en reposo cifrados con `kms_key` (S3, RDS, EBS, DynamoDB, ECR), TLS obligatorio en RDS y contraseña de RDS en Secrets Manager (no está en el código). Los secretos de la aplicación quedan fuera de esta sesión |
| A05 Security Misconfiguration | Contenedor como root · cloud abierto | Parte cloud: sin SSH, BD privada, buckets con acceso público bloqueado, segmentación pública/privada e IMDSv2 |
| A08 Integrity Failures | Pipeline sin firma ni verificación | `iac.yml` con escaneo Checkov obligatorio como gate antes de `plan` y `apply`, cambios solo por PR, versiones fijas y aprobación manual en producción. La firma de artefactos queda pendiente |
| A09 Logging & Monitoring | Ausencia total de trazabilidad | `cloudtrail` (multi-región, a CloudWatch), `flow_logs`, logs y query logging de RDS, `s3_logs` y access logs de `s3_backups` |

---

## 6. Límites de confianza

La arquitectura contiene diferentes fronteras de confianza.

### Internet ↔ Frontend

El usuario se encuentra fuera de la infraestructura de SecureBank y accede al frontend.

### Frontend ↔ API

Las solicitudes provenientes del frontend ingresan a la API y deben ser validadas.

### API ↔ Servicio de autenticación

La API debe comprobar la identidad del usuario y la validez de la autenticación.

### API ↔ Base de datos

La API accede a información privada almacenada en la base de datos.

### Zona pública ↔ Infraestructura interna

Los recursos internos deben estar protegidos frente a accesos externos no autorizados.

Esta frontera se materializa con la VPC, la separación `subnet_pub` / `subnet_priv` y los Security Groups: solo el ALB es público (443) y ninguna regla abre puertos administrativos a `0.0.0.0/0`.

En cada frontera de confianza se deben aplicar controles de validación, autenticación y autorización.

---

## 7. Superficie de ataque

Los principales puntos de exposición de la arquitectura son:

* Endpoints REST.
* Formularios del frontend.
* Servicio de autenticación.
* Tokens JWT.
* Base de datos.
* Contenedores e imágenes Docker.
* Dependencias de terceros.
* Variables de entorno.
* Secretos.
* Solicitudes HTTP/HTTPS.
* Security Groups y reglas de red.
* Buckets S3 (backups y logs).
* Roles y usuarios IAM.

---

## 8. Consideraciones de seguridad

La arquitectura debe considerar los siguientes controles:

* Autenticación de usuarios.
* Autorización basada en recursos.
* Validación de entradas.
* Protección de credenciales.
* Gestión segura de secretos.
* Cifrado de comunicaciones mediante HTTPS.
* Protección de la base de datos.
* Registro y auditoría de operaciones.
* Configuración segura de contenedores.
* Análisis de dependencias.
* Controles de seguridad integrados al pipeline DevSecOps.
* Infraestructura como código revisada por PR y escaneada (Checkov) antes de desplegar.
* Cifrado en reposo de volúmenes, buckets y base de datos.
* Menor privilegio en IAM.
* Logs de infraestructura habilitados (CloudTrail, VPC flow logs).
* Security Score de IaC igual o superior a 85 %.

---

## 9. Relación con el Threat Model

La arquitectura sirve como base para el Threat Model de SecureBank.

Los puntos donde los datos atraviesan fronteras de confianza representan lugares donde deben aplicarse controles de seguridad.

El endpoint `POST /transfer` es especialmente relevante debido a que una falla de autorización podría permitir que un usuario acceda o realice operaciones sobre recursos que no le pertenecen.

El Threat Model asociado se encuentra en:

```text
docs/threat-model.md
```

---

## 10. Resumen

La arquitectura de SecureBank separa el frontend, la API REST, el servicio de autenticación y la base de datos, desplegados sobre una VPC con subred pública y privada definida como código.

Esta separación permite identificar los flujos de información, las fronteras de confianza y los principales puntos de ataque que deben ser considerados durante el ciclo DevSecOps.
