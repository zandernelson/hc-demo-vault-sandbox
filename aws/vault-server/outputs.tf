output "vault_public_ip" {
  description = "Public IP address of the Vault server"
  value       = aws_eip.vault.public_ip
}

output "vault_ui_url" {
  description = "URL for the Vault UI"
  value       = "http://${aws_eip.vault.public_ip}:8200/ui"
}

output "vault_api_addr" {
  description = "Vault API address"
  value       = "http://${aws_eip.vault.public_ip}:8200"
}

output "ssh_command" {
  description = "SSH command to connect to the Vault server"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_eip.vault.public_ip}"
}

output "ssm_command" {
  description = "AWS CLI command to connect via SSM"
  value       = "aws ssm start-session --target ${aws_instance.vault.id} --region ${var.aws_region}"
}

output "instance_id" {
  description = "EC2 instance ID for SSM"
  value       = aws_instance.vault.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "ami_id" {
  description = "Amazon Linux AMI ID used"
  value       = data.aws_ami.amazon_linux.id
}

output "kms_key_id" {
  description = "KMS key ID for Vault auto-unseal"
  value       = aws_kms_key.vault.key_id
}

output "kms_key_alias" {
  description = "KMS key alias for Vault auto-unseal"
  value       = aws_kms_alias.vault.name
}
