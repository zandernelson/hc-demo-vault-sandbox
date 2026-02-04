# Consume networking outputs from vault-network-aws-shared workspace
data "tfe_outputs" "networking" {
  organization = var.tfe_organization
  workspace    = "vault-network-aws-shared"
}

locals {
  vpc_id            = data.tfe_outputs.networking.values.vpc_id
  public_subnet_ids = data.tfe_outputs.networking.values.public_subnet_ids
  name_prefix       = data.tfe_outputs.networking.values.name_prefix
}
