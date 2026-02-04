terraform {
  required_version = ">= 1.14.0"

  cloud {
    organization = "zander-nelson-demo"
    workspaces {
      name = "vault-k8s-consumer-aws-sandbox"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
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

