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
# iam_role_ci: el CI de GitHub asume este rol por OIDC (sin usuario IAM ni
# access keys). Solo puede subir imágenes al repositorio ECR y solo desde la
# rama main del repositorio indicado.
# ---------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  # Una cuenta solo admite un proveedor por URL: si ya existe, pasar su ARN en
  # var.github_oidc_provider_arn y no se crea otro.
  count           = var.github_oidc_provider_arn == null ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_oidc_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [coalesce(var.github_oidc_provider_arn, one(aws_iam_openid_connect_provider.github[*].arn))]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "iam_role_ci" {
  name               = "securebank-ci-ecr"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume.json
}

data "aws_iam_policy_document" "ci_ecr_push" {
  #checkov:skip=CKV_AWS_356:ecr:GetAuthorizationToken no admite restriccion por recurso; AWS exige Resource "*"
  statement {
    sid       = "LoginECR"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

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

resource "aws_iam_role_policy" "ci_ecr_push" {
  name   = "securebank-ci-ecr-push"
  role   = aws_iam_role.iam_role_ci.id
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
