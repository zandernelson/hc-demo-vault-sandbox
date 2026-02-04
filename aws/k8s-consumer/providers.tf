terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "zander-nelson-demo"
    workspaces {
      name = "vault-k8s-aws-consumer"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.51.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

