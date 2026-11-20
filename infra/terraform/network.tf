resource "aws_vpc" "vpc_main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# El Security Group por defecto de la VPC no permite nada (CKV2_AWS_12).
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc_main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id
}

# Subredes públicas: solo para el ALB.
resource "aws_subnet" "subnet_pub" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
}

# Subredes privadas: API, worker y base de datos.
resource "aws_subnet" "subnet_priv" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.subnet_pub[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Security Groups. Regla de oro: nunca 0.0.0.0/0 sobre puertos administrativos.
# No hay SSH: el acceso administrativo es por SSM Session Manager.
# ---------------------------------------------------------------------------

# ALB: único punto público, solo HTTPS.
resource "aws_security_group" "sg_public" {
  name        = "securebank-sg-public"
  description = "ALB publico: solo HTTPS"
  vpc_id      = aws_vpc.vpc_main.id
}

resource "aws_vpc_security_group_ingress_rule" "public_https" {
  security_group_id = aws_security_group.sg_public.id
  description       = "HTTPS desde Internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "public_to_app" {
  security_group_id            = aws_security_group.sg_public.id
  description                  = "Hacia la API en el puerto 8000"
  referenced_security_group_id = aws_security_group.sg_app.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

# API / worker: solo acepta tráfico del ALB.
resource "aws_security_group" "sg_app" {
  name        = "securebank-sg-app"
  description = "API y worker: solo trafico del ALB"
  vpc_id      = aws_vpc.vpc_main.id
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.sg_app.id
  description                  = "API desde el ALB"
  referenced_security_group_id = aws_security_group.sg_public.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.sg_app.id
  description                  = "PostgreSQL hacia la base de datos"
  referenced_security_group_id = aws_security_group.sg_db.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_https_vpc" {
  security_group_id = aws_security_group.sg_app.id
  description       = "HTTPS hacia endpoints dentro de la VPC"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Base de datos: solo acepta PostgreSQL desde la API.
resource "aws_security_group" "sg_db" {
  name        = "securebank-sg-db"
  description = "Base de datos: solo PostgreSQL desde la API"
  vpc_id      = aws_vpc.vpc_main.id
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.sg_db.id
  description                  = "PostgreSQL desde la API"
  referenced_security_group_id = aws_security_group.sg_app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# ---------------------------------------------------------------------------
# VPC Flow Logs -> s3_logs (trazabilidad de red)
# ---------------------------------------------------------------------------
resource "aws_flow_log" "flow_logs" {
  vpc_id               = aws_vpc.vpc_main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.s3_logs.arn
}
