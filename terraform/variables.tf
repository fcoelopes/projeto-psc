variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo da instância EC2 (ex: t2.micro, t3.small)"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Para garantir o Free Tier, use apenas t2.micro ou t3.micro."
  }
}

variable "ssh_key_path" {
  description = "Caminho local para a chave pública SSH"
  type        = string
}

variable "key_name" {
  description = "Nome da chave na AWS"
  type        = string
}