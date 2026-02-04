# Vault Kubernetes Consumer
# This workspace provisions resources that consume secrets from Vault
# using the Kubernetes authentication method.

# Consume networking outputs from vault-network-aws-shared workspace
data "tfe_outputs" "networking" {
  organization = var.tfe_organization
  workspace    = "vault-network-aws-shared"
}

locals {
  vpc_id             = data.tfe_outputs.networking.values.vpc_id
  public_subnet_ids  = data.tfe_outputs.networking.values.public_subnet_ids
  private_subnet_ids = data.tfe_outputs.networking.values.private_subnet_ids
  name_prefix        = data.tfe_outputs.networking.values.name_prefix
}
