# ---------------------------------------------------------------------------
# iam_role_admin: rol de las instancias. Administración por SSM (sin SSH) y
# permisos mínimos: solo leer objetos del bucket de respaldos. Sin "*".
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role_admin" {
  name               = "securebank-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.iam_role_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "instance_least_privilege" {
  statement {
    sid       = "LeerBackups"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_backups.arn}/*"]
  }

  statement {
    sid       = "DescifrarBackups"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.kms_key.arn]
  }
}

resource "aws_iam_role_policy" "instance_least_privilege" {
  name   = "securebank-instance-least-privilege"
  role   = aws_iam_role.iam_role_admin.id
  policy = data.aws_iam_policy_document.instance_least_privilege.json
}

resource "aws_iam_instance_profile" "instance" {
  name = "securebank-instance-profile"
  role = aws_iam_role.iam_role_admin.name
}

# ---------------------------------------------------------------------------
# iam_user_ci: usuario de CI, vía grupo (no policies directas al usuario).
# Solo puede subir imágenes al repositorio ECR. No se crean access keys aquí.
# ---------------------------------------------------------------------------
resource "aws_iam_user" "iam_user_ci" {
  #checkov:skip=CKV_AWS_273:Usuario de CI exigido por el stack de la Sesion 11; sin access keys y con menor privilegio. Reemplazar por OIDC
  name = "securebank-ci"
}

resource "aws_iam_group" "ci" {
  name = "securebank-ci"
}

resource "aws_iam_user_group_membership" "ci" {
  user   = aws_iam_user.iam_user_ci.name
  groups = [aws_iam_group.ci.name]
}

data "aws_iam_policy_document" "ci_ecr_push" {
  statement {
    sid = "PushImagenes"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [aws_ecr_repository.ecr_repo.arn]
  }
}

resource "aws_iam_group_policy" "ci_ecr_push" {
  name   = "securebank-ci-ecr-push"
  group  = aws_iam_group.ci.name
  policy = data.aws_iam_policy_document.ci_ecr_push.json
}

# ---------------------------------------------------------------------------
# Rol de monitoreo mejorado de RDS
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "rds_monitoring_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name               = "securebank-rds-monitoring"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume.json
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ---------------------------------------------------------------------------
# Rol de lambda_api
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_api" {
  name               = "securebank-lambda-api"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}
