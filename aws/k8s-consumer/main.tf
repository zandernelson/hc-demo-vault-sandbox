# Vault Kubernetes Consumer
# This workspace provisions resources that consume secrets from Vault
# using the Kubernetes authentication method.

# Consume network outputs from vault-network-aws-sandbox workspace
data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "zander-nelson-demo"
    workspaces = {
      name = "vault-network-aws-sandbox"
    }
  }
}

locals {
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.network.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  name_prefix        = data.terraform_remote_state.network.outputs.name_prefix
}
