output "access_terminal_public_ip" {
  value = aws_instance.access_terminal.public_ip
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins_ec2.private_ip
}

output "nexus_private_ip" {
  value = aws_instance.nexus_ec2.private_ip
}
