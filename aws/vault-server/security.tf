# Security Group for Vault Server
resource "aws_security_group" "vault" {
  name        = "${local.name_prefix}-vault-sg"
  description = "Security group for Vault server"
  vpc_id      = local.vpc_id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Vault API/UI
  ingress {
    description = "Vault API and UI"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = var.allowed_vault_cidrs
  }

  # Vault cluster communication (for future multi-node setup)
  ingress {
    description = "Vault cluster"
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    self        = true
  }

  # Egress - allow all outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-vault-sg"
  }
}
