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
  vpc_id            = data.terraform_remote_state.network.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids
  name_prefix       = data.terraform_remote_state.network.outputs.name_prefix
}

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

# Lookup latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Elastic IP for stable address
resource "aws_eip" "vault" {
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-vault-eip"
  }
}

# Associate EIP with instance
resource "aws_eip_association" "vault" {
  instance_id   = aws_instance.vault.id
  allocation_id = aws_eip.vault.id
}

# Vault EC2 Instance
resource "aws_instance" "vault" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = local.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.vault.id]
  iam_instance_profile   = aws_iam_instance_profile.vault.name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${local.name_prefix}-vault-server"
  }
}
