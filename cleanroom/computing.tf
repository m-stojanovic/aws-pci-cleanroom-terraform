resource "aws_instance" "access_terminal" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  security_groups             = [aws_security_group.access_terminal_sg.id, aws_security_group.allow_updates.id]
  subnet_id                   = aws_subnet.clean_room_subnet.id
  depends_on                  = [aws_networkfirewall_firewall.aws_firewall]
  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = "false"
    encrypted             = "true"
    kms_key_id            = aws_kms_key.ec2_volume_encryption_key.arn
  }
  user_data = data.template_file.kickstart_access_terminal.rendered

  tags = {
    Name = "${var.environment}-access-terminal"
    "user:Client"      = var.client_name
    "user:Environment" = var.environment
  }
}

resource "aws_instance" "jenkins_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.large"
  security_groups             = [aws_security_group.jenkins_sg.id, aws_security_group.allow_updates.id]
  subnet_id                   = aws_subnet.clean_room_subnet.id
  depends_on                  = [aws_networkfirewall_firewall.aws_firewall]
  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = "false"
    encrypted             = "true"
    kms_key_id            = aws_kms_key.ec2_volume_encryption_key.arn
  }
  user_data = data.template_file.kickstart_private_instances.rendered

  tags = {
    Name               = "${var.environment}-jenkins"
    "user:Client"      = var.client_name
    "user:Environment" = var.environment
  }
}

resource "aws_instance" "nexus_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.small"
  associate_public_ip_address = "true"
  security_groups             = [aws_security_group.nexus_sg.id, aws_security_group.allow_updates.id]
  subnet_id                   = aws_subnet.clean_room_subnet.id
  depends_on                  = [aws_networkfirewall_firewall.aws_firewall]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 100
    delete_on_termination = "false"
    encrypted             = "true"
    kms_key_id            = aws_kms_key.ec2_volume_encryption_key.arn
  }
  user_data = data.template_file.kickstart_private_instances.rendered

  tags = {
    Name               = "${var.environment}-nexus"
    "user:Client"      = var.client_name
    "user:Environment" = var.environment
  }
}

#################################
#         Create AT EIP         #
#################################
resource "aws_eip" "eip_at" {
  instance   = aws_instance.access_terminal.id
  vpc        = true
  tags = {
    Name               = "${var.environment}-at-eip"
    "user:Environment" = var.environment
  }
}

######################################
#         Create Jenkins EIP         #
######################################
resource "aws_eip" "eip_jenkins" {
  instance   = aws_instance.jenkins_ec2.id
  vpc        = true
  tags = {
    Name               = "${var.environment}-jenkins-eip"
    "user:Environment" = var.environment
  }
}