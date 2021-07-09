### NOTE ABOUT IMAGES ###
# Current method of setting non standard SSH port is using AWS user_data option, that is happening on launch,
# it executes shell script that changes the port in sshd_config file and restarts sshd service.
# Other method is building custom AMIs with Packer or similar tool, and tailoring images to our needs, we can also use this method to
# launch instance with necessary software already installed (e.g. nexus,jenkins...)
data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "template_file" "kickstart_access_terminal" {
  template = file("./scripts/access_terminal_startup.yaml")
  vars = {
    ssh_port                = var.ssh_port
    username_1_pub_ssh      = var.username_1_pub_ssh
    username_2_pub_ssh      = var.username_2_pub_ssh
    username_3_pub_ssh      = var.username_3_pub_ssh
  }
}
data "template_file" "kickstart_private_instances" {
  template = file("./scripts/private_instances_startup.yaml")
  vars = {
    ssh_port                = var.ssh_port
    username_1_pub_ssh      = var.username_1_pub_ssh
    username_2_pub_ssh      = var.username_2_pub_ssh
    username_3_pub_ssh      = var.username_3_pub_ssh
  }
}
