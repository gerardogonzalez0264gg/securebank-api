data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ec2_web: servidor de la API REST, en subred privada, sin IP pública ni SSH.
resource "aws_instance" "ec2_web" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_priv[0].id
  vpc_security_group_ids      = [aws_security_group.sg_app.id]
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  associate_public_ip_address = false
  monitoring                  = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2
  }

  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.kms_key.arn
  }

  tags = {
    Name = "securebank-ec2-web"
  }
}

# ec2_worker: procesos en segundo plano.
resource "aws_instance" "ec2_worker" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_priv[1].id
  vpc_security_group_ids      = [aws_security_group.sg_app.id]
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  associate_public_ip_address = false
  monitoring                  = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2
  }

  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.kms_key.arn
  }

  tags = {
    Name = "securebank-ec2-worker"
  }
}

# ebs_volume: volumen de datos del worker, cifrado con KMS.
resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = aws_instance.ec2_worker.availability_zone
  size              = 20
  type              = "gp3"
  encrypted         = true
  kms_key_id        = aws_kms_key.kms_key.arn
}

resource "aws_volume_attachment" "ebs_volume" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.ec2_worker.id
}

# lambda_api: función de apoyo de la API (código de ejemplo; se reemplaza en el despliegue).
data "archive_file" "lambda_api" {
  type        = "zip"
  output_path = "${path.module}/lambda_api.zip"

  source {
    filename = "handler.py"
    content  = "def handler(event, context):\n    return {\"statusCode\": 200}\n"
  }
}

resource "aws_lambda_function" "lambda_api" {
  #checkov:skip=CKV_AWS_116:Funcion de apoyo (esqueleto); la DLQ es una mejora MEDIUM pendiente
  #checkov:skip=CKV_AWS_272:Firma de codigo corresponde a la etapa Release, fuera de la Sesion 11
  function_name                  = "securebank-lambda-api"
  role                           = aws_iam_role.lambda_api.arn
  runtime                        = "python3.12"
  handler                        = "handler.handler"
  filename                       = data.archive_file.lambda_api.output_path
  source_code_hash               = data.archive_file.lambda_api.output_base64sha256
  reserved_concurrent_executions = 10
  kms_key_arn                    = aws_kms_key.kms_key.arn

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = aws_subnet.subnet_priv[*].id
    security_group_ids = [aws_security_group.sg_app.id]
  }
}
