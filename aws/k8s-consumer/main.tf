# Vault Kubernetes Consumer
# This workspace provisions resources that consume secrets from Vault
# using the Kubernetes authentication method.

# Consume network outputs from vault-network-aws-sandbox workspace
data "tfe_outputs" "network" {
  organization = "zander-nelson-demo"
  workspace    = "vault-network-aws-sandbox"
}

locals {
  vpc_id             = data.tfe_outputs.network.nonsensitive_values.vpc_id
  public_subnet_ids  = data.tfe_outputs.network.nonsensitive_values.public_subnet_ids
  private_subnet_ids = data.tfe_outputs.network.nonsensitive_values.private_subnet_ids
  name_prefix        = data.tfe_outputs.network.nonsensitive_values.name_prefix
}
