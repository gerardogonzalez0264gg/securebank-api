data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Política de la clave: administración solo por la cuenta; CloudTrail y los
# flow logs solo pueden generar claves de datos para escribir en s3_logs.
data "aws_iam_policy_document" "kms_key" {
  #checkov:skip=CKV_AWS_109:Patron estandar de key policy: el root de la cuenta administra la clave
  #checkov:skip=CKV_AWS_111:Patron estandar de key policy: el root de la cuenta administra la clave
  #checkov:skip=CKV_AWS_356:En una key policy Resource "*" significa "esta clave"
  statement {
    sid       = "AdministracionCuenta"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "CloudTrailYFlowLogs"
    actions   = ["kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid = "CloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "kms_key" {
  description             = "SecureBank: cifrado en reposo (S3, RDS, EBS, DynamoDB, ECR)"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_key.json
}

resource "aws_kms_alias" "kms_key" {
  name          = "alias/securebank"
  target_key_id = aws_kms_key.kms_key.key_id
}
