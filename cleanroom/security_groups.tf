resource "aws_security_group" "access_terminal_sg" {
  name        = "allow_traffic"
  description = "Allow traffic from vpn and outgoing connections to other hosts"
  vpc_id      = aws_vpc.aws_clean_room_vpc.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "TCP"
    cidr_blocks = ["217.24.18.64/29"]
    description = "SSH PORT CLEANROOM VPC"
  }
  ingress {
    from_port   = var.vnc_port
    to_port     = var.vnc_port
    protocol    = "TCP"
    cidr_blocks = ["217.24.18.64/29"]
    description = "VNC PORT"
  }
  egress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
    description = "SSH PORT CLEANROOM VPC"
  }
  egress {
    from_port   = var.jenkins_http_port
    to_port     = var.nexus_https_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
    description = "Jenkins to Nexus HTTP and HTTPS ports"
  }

  tags = {
    Name               = "${var.environment}-main-sg"
    "user:Environment" = var.environment
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg_traffic"
  description = "Allow traffic from access terminal to jenkins host"
  vpc_id      = aws_vpc.aws_clean_room_vpc.id
  ingress {
    from_port   = var.jenkins_http_port
    to_port     = var.jenkins_http_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
    description = "JENKINS PORT"
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
    description = "SSH PORT"
  }
  egress {
    from_port   = var.nexus_http_port
    to_port     = var.nexus_http_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
    description = "NEXUS HTTP PORT"
  }
  egress {
    from_port   = var.nexus_https_port
    to_port     = var.nexus_https_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
    description = "NEXUS HTTPS PORT"
  }

  tags = {
    Name               = "${var.environment}-jenkins-sg"
    "user:Environment" = var.environment
  }
}

resource "aws_security_group" "nexus_sg" {
  name        = "nexus_sg_traffic"
  description = "Allow traffic from access terminal to nexus host"
  vpc_id      = aws_vpc.aws_clean_room_vpc.id

  ingress {
    from_port   = var.nexus_http_port
    to_port     = var.nexus_https_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "TCP"
    cidr_blocks = [aws_subnet.clean_room_subnet.cidr_block]
  }

  tags = {
    Name               = "${var.environment}-nexus-sg"
    "user:Environment" = var.environment
  }
  # Egress NAT GW 1
  # Egress NAT GW 2
}

resource "aws_security_group" "allow_updates" {
  name   = "allow-system-updates"
  vpc_id = aws_vpc.aws_clean_room_vpc.id
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  tags = {
    Name               = "${var.environment}-allow-updates-sg"
    "user:Environment" = var.environment
  }
}