# Network Infrastructure Configuration
# This module sets up a basic AWS VPC network with internet connectivity.
# Components:
# - VPC: Main virtual private cloud with CIDR block 10.0.0.0/16
# - Internet Gateway: Enables internet access for the VPC
# - Public Subnet: 10.0.1.0/24 subnet where EC2 instances (e.g., Nginx) are deployed
# - Route Table: Directs all outbound traffic (0.0.0.0/0) to the Internet Gateway
# - Route Table Association: Links the public subnet to the route table for internet routing
# VPC
# VPC isolada para o projeto
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "main-vpc" }
}

# Gateway para saída/entrada de internet
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = { Name = "main-igw" }
}

# Subnet onde a EC2 residirá
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Essencial para acesso externo
  availability_zone       = "${var.aws_region}a"

  tags = { Name = "main-subnet" }
}

# Tabela de rotas para direcionar tráfego para o IGW
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = { Name = "main-route-table" }
}

# Associação da rota com a nossa subnet pública
resource "aws_route_table_association" "main_rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}