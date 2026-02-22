output "elastic_ip" {
  value       = aws_eip.nginx_eip.public_ip
  description = "IP fixo público para acesso via internet"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.projeto_repository.repository_url
  description = "A URL do repositório ECR para fazer o push da imagem"
}

resource "local_file" "ansible_inventory" {
  content  = <<-EOT
    [webservers]
    nginx_server ansible_host=${aws_eip.nginx_eip.public_ip}

    [webservers:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=${replace(var.ssh_key_path, ".pub", "")}
    ecr_url=${aws_ecr_repository.projeto_repository.repository_url}
  EOT
  filename = "${path.module}/../ansible/inventory.ini"
}

output "backup_ami_id" {
  value = aws_ami_from_instance.nginx_backup.id
}