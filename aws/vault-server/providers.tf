terraform {
  required_version = ">= 1.14.0"

  cloud {
    organization = "zander-nelson-demo"
    workspaces {
      name = "vault-server-aws-sandbox"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.51.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "vault-sandbox"
      Environment = "demo"
      ManagedBy   = "terraform"
    }
  }
}
