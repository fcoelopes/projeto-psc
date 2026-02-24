# Variáveis para facilitar a manutenção
ECR_URL = $(shell cd terraform && terraform output -raw ecr_repository_url)
REGION = us-east-1
IMAGE_NAME = psc-nginx
TF_DIR = terraform

.PHONY: help terraform-init terraform-apply docker-push ansible-deploy all destroy

help: ## Mostra os comandos disponíveis
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Camada Terraform ---
tf-init: ## Inicializa o Terraform
	terraform -chdir=$(TF_DIR) init

tf-apply: ## Provisiona a infraestrutura na AWS
	terraform -chdir=$(TF_DIR) apply -auto-approve

tf-validate: ## Valida os arquivos de configuração do Terraform
	terraform -chdir=$(TF_DIR) validate

tf-fmt: ## Formata os arquivos de configuração do Terraform
	terraform -chdir=$(TF_DIR) fmt

tf-show: ## Mostra o conteúdo formatado do Terraform
	terraform -chdir=$(TF_DIR) show

tf-plan: ## Mostra o plano de execução do Terraform
	terraform -chdir=$(TF_DIR) plan

# --- Camada Docker ---
docker-login: ## Autentica no ECR
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_URL)

docker-build: ## Builda e etiqueta a imagem local
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME):latest $(ECR_URL):latest

docker-push: docker-login
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME):latest $(ECR_URL):latest
	docker push $(ECR_URL):latest

# --- Camada Ansible ---
ansible-ping: ## Testa a conexão com a EC2
	cd ansible && ansible webservers -i inventory.ini -m ping

deploy: ## Executa o deploy final via Ansible
	cd ansible && ansible-playbook -i inventory.ini playbook.yml

# --- Atalhos Mestres ---
all: tf-apply docker-push deploy ## Executa o pipeline completo do zero

destroy: ## Destrói toda a infraestrutura na AWS
	cd terraform && terraform destroy -auto-approve