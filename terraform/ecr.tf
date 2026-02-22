# ECR Repository and IAM Configuration
# This module sets up an AWS Elastic Container Registry (ECR) repository and configures
# IAM roles and policies to allow EC2 instances to read from the repository.
#
# Resources:
# - aws_ecr_repository.projeto_repository: Creates a private ECR repository named "meu-projeto-nginx"
#   with image tag mutability enabled and automatic image scanning on push.
#
# - aws_iam_role.ec2_ecr_role: Creates an IAM role that allows EC2 instances to assume
#   this role via the EC2 service principal.
#
# - aws_iam_role_policy_attachment.ecr_readonly: Attaches the AWS managed policy
#   "AmazonEC2ContainerRegistryReadOnly" to the EC2 role, granting read-only access to ECR.
#
# - aws_iam_instance_profile.ec2_profile: Creates an instance profile that associates
#   the IAM role with EC2 instances, enabling them to assume the role and access ECR.
#
# Usage:
# EC2 instances launched with the "ec2_ecr_profile" instance profile will be able to
# pull images from the "meu-projeto-nginx" ECR repository.
resource "aws_ecr_repository" "projeto_repository" {
  name                 = "psc-nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2_ecr_readonly_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_ecr_profile"
  role = aws_iam_role.ec2_ecr_role.name
}