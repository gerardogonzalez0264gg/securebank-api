# ---------------------------------------------------------------------------
# s3_logs: destino de CloudTrail y VPC Flow Logs (privado, cifrado, versionado)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "s3_logs" {
  #checkov:skip=CKV_AWS_18:Los access logs de S3 requieren un bucket destino con SSE-S3, no con SSE-KMS; pendiente bucket dedicado
  #checkov:skip=CKV_AWS_144:Replicacion cross-region (MEDIUM) pendiente: requiere segundo provider y costo adicional
  #checkov:skip=CKV2_AWS_62:Sin consumidor de eventos definido en el esqueleto (MEDIUM)
  bucket_prefix = "securebank-logs-"
}

resource "aws_s3_bucket_public_access_block" "s3_logs" {
  bucket                  = aws_s3_bucket.s3_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.kms_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id
  rule {
    id     = "retencion-logs"
    status = "Enabled"
    filter {}
    expiration {
      days = 365
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

data "aws_iam_policy_document" "s3_logs" {
  statement {
    sid       = "CloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.s3_logs.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "CloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.s3_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid       = "FlowLogsAclCheck"
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]
    resources = [aws_s3_bucket.s3_logs.arn]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid       = "FlowLogsWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.s3_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid       = "SoloTLS"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.s3_logs.arn, "${aws_s3_bucket.s3_logs.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_logs" {
  bucket     = aws_s3_bucket.s3_logs.id
  policy     = data.aws_iam_policy_document.s3_logs.json
  depends_on = [aws_s3_bucket_public_access_block.s3_logs]
}

# ---------------------------------------------------------------------------
# s3_backups: respaldos (privado, cifrado con KMS, versionado)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "s3_backups" {
  #checkov:skip=CKV_AWS_18:Los access logs de S3 requieren un bucket destino con SSE-S3, no con SSE-KMS; pendiente bucket dedicado
  #checkov:skip=CKV_AWS_144:Replicacion cross-region (MEDIUM) pendiente: requiere segundo provider y costo adicional
  #checkov:skip=CKV2_AWS_62:Sin consumidor de eventos definido en el esqueleto (MEDIUM)
  bucket_prefix = "securebank-backups-"
}

resource "aws_s3_bucket_public_access_block" "s3_backups" {
  bucket                  = aws_s3_bucket.s3_backups.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_backups" {
  bucket = aws_s3_bucket.s3_backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_backups" {
  bucket = aws_s3_bucket.s3_backups.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.kms_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_backups" {
  bucket = aws_s3_bucket.s3_backups.id
  rule {
    id     = "retencion-backups"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
