# Choose your aws profile
variable "profile" {
  type    = string
  default = "awsprofile"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "environment" {
  type    = string
  default = "cleanroom"
}

# Add the client name
variable "client_name" {
  type    = string
  default = ""
}

variable "ssh_port" {
  description = "Non standard ssh port for instances"
  type        = number
  default     = 2177
}

variable "vnc_port" {
  description = "Port to be used for VNC connection on access terminal"
  type        = number
  default     = 5950
}

variable "jenkins_http_port" {
  description = "Jenkins UI http access port"
  type        = number
  default     = 8081
}

variable "nexus_http_port" {
  description = "Nexus UI http access port"
  type        = number
  default     = 8085
}
variable "nexus_https_port" {
  description = "Nexus https access port"
  type        = number
  default     = 8087
}

# Insert your user accounts public keys
variable "username_1_pub_ssh" {
  type    = string
  default = ""
}
variable "username_2_pub_ssh" {
  type    = string
  default = ""
}
variable "username_3_pub_ssh" {
  type    = string
  default = ""
}
