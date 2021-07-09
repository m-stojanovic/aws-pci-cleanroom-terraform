#######
# KMS #
#######
resource "aws_kms_key" "ec2_volume_encryption_key" {
  description             = "Encryption key for EBS storage"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    Name               = "EBS encrpyion key"
    "user:Client"      = var.client_name
    "user:Environment" = "CleanRoom"
  }
}

############################
# KMS Encryption Key Alias #
############################
resource "aws_kms_alias" "stage_ec2_encryption_key_alias" {
  name          = "alias/${var.environment}-ec2-volume-key"
  target_key_id = aws_kms_key.ec2_volume_encryption_key.key_id
}