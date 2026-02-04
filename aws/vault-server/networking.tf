# Consume network outputs from vault-network-aws-sandbox workspace
data "tfe_outputs" "network" {
  organization = "zander-nelson-demo"
  workspace    = "vault-network-aws-sandbox"
}

locals {
  vpc_id            = data.tfe_outputs.network.values.vpc_id
  public_subnet_ids = data.tfe_outputs.network.values.public_subnet_ids
  name_prefix       = data.tfe_outputs.network.values.name_prefix
}
