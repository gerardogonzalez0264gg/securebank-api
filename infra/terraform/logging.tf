# cloudtrail: auditoría de todas las llamadas a la API de AWS (todas las
# regiones, con validación de integridad, cifrado KMS y envío a CloudWatch Logs).
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/securebank/cloudtrail"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.kms_key.arn
}

data "aws_iam_policy_document" "cloudtrail_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.cloudtrail.arn}:*"]
  }
}

resource "aws_iam_role" "cloudtrail" {
  name               = "securebank-cloudtrail"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume.json
}

resource "aws_iam_role_policy" "cloudtrail" {
  name   = "securebank-cloudtrail-logs"
  role   = aws_iam_role.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_logs.json
}

resource "aws_cloudtrail" "cloudtrail" {
  #checkov:skip=CKV_AWS_252:Notificaciones SNS pertenecen a la etapa Monitor, fuera de la Sesion 11
  name                          = "securebank-trail"
  s3_bucket_name                = aws_s3_bucket.s3_logs.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.kms_key.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn

  depends_on = [aws_s3_bucket_policy.s3_logs]
}
