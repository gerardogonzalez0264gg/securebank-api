terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # Estado remoto: el bucket se crea aparte (bootstrap) y se pasa con
  # -backend-config en el pipeline. Nunca se versiona el .tfstate.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "SecureBank"
      ManagedBy = "Terraform"
    }
  }
}
