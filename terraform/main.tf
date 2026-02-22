# AWS Security Group and EC2 Instance Configuration
#
# This module creates a security group that allows inbound SSH (port 22) and HTTP (port 80) traffic
# from any source (0.0.0.0/0), with unrestricted egress traffic. It also sets up an EC2 instance
# running Ubuntu with Nginx, using SSH key-pair authentication for secure access.
#
# Security Considerations:
# - SSH access is open to 0.0.0.0/0. Consider restricting this to specific IP ranges in production.
# - HTTP traffic is open to the internet. Add HTTPS (port 443) and restrict HTTP access if needed.
# - The AMI ID is region-specific and should be verified for your target AWS region.
#
# Resources:
# - aws_security_group.nginx_sg: Manages inbound and outbound traffic rules
# - aws_key_pair.projeto_key: Manages SSH public key for EC2 authentication
# - aws_instance.nginx_server: Ubuntu EC2 instance with t2.micro instance type (Free Tier eligible)
#
# Variables Required:
# - var.key_name: Name identifier for the SSH key pair
# - var.ssh_key_path: File path to the SSH public key
#
# Dependencies:
# - aws_vpc.main_vpc: VPC resource referenced by the security group
# - aws_subnet.main_subnet: Subnet resource referenced by the EC2 instance

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

resource "aws_key_pair" "projeto_key" {
  key_name   = var.key_name
  public_key = file(var.ssh_key_path)
}

# Firewall (Security Group)
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Permitir HTTP e SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nginx-sg" }
}

resource "aws_instance" "nginx_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = var.instance_type

  private_ip = "10.0.1.10"

  key_name               = aws_key_pair.projeto_key.key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id              = aws_subnet.main_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # 1. Atualiza a lista de pacotes
              apt-get update -y
              
              # 2. Instala bibliotecas básicas e o Python 3 (motor do Ansible)
              apt-get install -y python3-pip software-properties-common curl unzip awscli

              # 3. Garante que o usuário ubuntu tenha as permissões corretas
              chown -R ubuntu:ubuntu /home/ubuntu
              EOF

  user_data_replace_on_change = true

  tags = { Name = "NginxServer" }
}

resource "aws_eip" "nginx_eip" {
  instance = aws_instance.nginx_server.id
  domain   = "vpc"

  tags = { Name = "nginx-elastic-ip" }
}

resource "aws_ami_from_instance" "nginx_backup" {
  name               = "ami-nginx-server-psc-final"
  source_instance_id = aws_instance.nginx_server.id
  
  # Importante: garante que a AMI só seja criada após o Ansible terminar
  # (Você pode comentar isso após a primeira execução)
  depends_on = [aws_instance.nginx_server]

  lifecycle {
    prevent_destroy = true
  }
}