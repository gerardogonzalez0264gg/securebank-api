variable "aws_region" {
  description = "Región de despliegue"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad fijas (deben pertenecer a aws_region)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR de la VPC (red interna de SecureBank)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "certificate_arn" {
  description = "ARN del certificado ACM para el listener HTTPS del ALB"
  type        = string
}

variable "github_repository" {
  description = "Repositorio de GitHub autorizado a asumir el rol de CI por OIDC (owner/repo)"
  type        = string
  default     = "gerardogonzalez0264gg/securebank-api"
}

variable "github_oidc_provider_arn" {
  description = "ARN del proveedor OIDC de GitHub si ya existe en la cuenta (null = crearlo)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Tipo de instancia para ec2_web y ec2_worker"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "Clase de instancia de rds_postgres (Performance Insights requiere db.t3.medium o superior)"
  type        = string
  default     = "db.t3.medium"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos (la clave la gestiona AWS Secrets Manager)"
  type        = string
  default     = "securebank_admin"
}
