# KMS key for Vault auto-unseal
resource "aws_kms_key" "vault" {
  description             = "KMS key for Vault auto-unseal"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-vault-unseal-key"
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${local.name_prefix}-vault-unseal"
  target_key_id = aws_kms_key.vault.key_id
}
