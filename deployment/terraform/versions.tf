terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}
