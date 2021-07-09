#######
# VPC #
#######
resource "aws_vpc" "aws_clean_room_vpc" {
  cidr_block = "172.20.0.0/24"
  tags = {
    Name = "${var.environment}-vpc"
  }
}

#######
# IGW #
#######
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.aws_clean_room_vpc.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

#################
# Public subnet #
#################
resource "aws_subnet" "clean_room_subnet" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "172.20.0.0/28"
  vpc_id                  = aws_vpc.aws_clean_room_vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

###################
# Firewall subnet #
###################
resource "aws_subnet" "firewall_subnet" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "172.20.0.16/28"
  vpc_id                  = aws_vpc.aws_clean_room_vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name = "firewall-public-subnet"
  }
}

################################
# Route table Cleanroom subnet #
################################
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.aws_clean_room_vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = (aws_networkfirewall_firewall.aws_firewall.firewall_status[0].sync_states[*].attachment[0].endpoint_id)[0]
  }

  tags = {
    Name = "${var.environment}-rt"
  }
}

###############################
# Route table Firewall subnet #
###############################
resource "aws_route_table" "firewall_subnet" {
  vpc_id = aws_vpc.aws_clean_room_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "firewall-rt"
  }
}

##############################
# Route table Gateway subnet #
##############################
resource "aws_route_table" "gateway" {
  vpc_id = aws_vpc.aws_clean_room_vpc.id
  route {
    cidr_block      = aws_subnet.clean_room_subnet.cidr_block
    vpc_endpoint_id = (aws_networkfirewall_firewall.aws_firewall.firewall_status[0].sync_states[*].attachment[0].endpoint_id)[0]
  }
  tags   = {
    Name = "gateway-rt"
  }
}

####################################
# Route table Firewall association #
####################################
resource "aws_route_table_association" "fw_assoc" {
  route_table_id = aws_route_table.firewall_subnet.id
  subnet_id      = aws_subnet.firewall_subnet.id
}

#####################################
# Route table Cleanroom association #
#####################################
resource "aws_route_table_association" "main_rt_assoc" {
  route_table_id = aws_route_table.main_rt.id
  subnet_id      = aws_subnet.clean_room_subnet.id
}

###################################
# Route table Gateway association #
###################################
resource "aws_route_table_association" "gateway_assoc" {
  route_table_id = aws_route_table.gateway.id
  gateway_id     = aws_internet_gateway.internet_gateway.id
}

################################
# Main route table association #
################################
resource "aws_main_route_table_association" "main_rt_assoc" {
  vpc_id         = aws_vpc.aws_clean_room_vpc.id
  route_table_id = aws_route_table.main_rt.id
}