# PSC - Cloud Project

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20ECR%20%7C%20VPC-orange)](https://aws.amazon.com)
[![Docker](https://img.shields.io/badge/Docker-Alpine-blue)](https://www.docker.com)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)](https://www.terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-red)](https://www.ansible.com)

> Projeto completo de infraestrutura em nuvem com pipeline automatizado. Provisiona servidores web escaláveis na AWS com containerização Docker, orquestração com Terraform e deploy automático com Ansible.

## 📑 Sumário

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Configuração](#configuração)
- [Troubleshooting](#troubleshooting)
- [Contribuindo](#contribuindo)
- [Desenvolvedor](#-desenvolvedor)
- [Licença](#licença)

## 🎯 Visão Geral

Este projeto implementa uma solução completa de infraestrutura em nuvem com:

- **Infraestrutura como Código (IaC)**: Terraform para provisionamento em AWS
- **Containerização**: Docker com Nginx para servir aplicações web
- **Automação de Deploy**: Ansible para configuração e orquestração
- **Pipeline CI/CD**: Makefile com comandos automatizados
- **Escalabilidade**: Pronto para ECR (Elastic Container Registry)

## 🏗️ Arquitetura

```
┌──────────────────────────────────────────────────────────┐
│                       AWS Cloud                          │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │                      VPC                           │  │
│  │                                                    │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │            EC2 Instance (Ubuntu)             │  │  │
│  │  │                                              │  │  │
│  │  │  ┌─────────────────────────────────────────┐ │  │  │
│  │  │  │   Docker Container                      │ │  │  │
│  │  │  │   ├─ Nginx:Alpine                       │ │  │  │
│  │  │  │   └─ HTML App                           │ │  │  │
│  │  │  └─────────────────────────────────────────┘ │  │  │
│  │  │                                              │  │  │
│  │  │  Ports: 22 (SSH), 80 (HTTP)                  │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  │                                                    │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │      ECR Repository                          │  │  │
│  │  │      (Imagem Docker armazenada)              │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  │                                                    │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │      Security Group (Firewall)                     │  │
│  │      ├─ SSH (22): Seu IP                           │  │
│  │      └─ HTTP (80): 0.0.0.0/0                       │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘

                    Controle Local
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       Terraform      Ansible        Docker
       (IaC)        (Deploy)        (Build)
```

## 📋 Pré-requisitos

### Software Necessário

| Software | Versão | Finalidade |
|----------|--------|-----------|
| `terraform` | >= 1.0 | Provisionar infraestrutura AWS |
| `ansible` | >= 2.9 | Orquestração e deploy |
| `docker` | >= 20.0 | Build e teste de imagens |
| `aws-cli` | >= 2.0 | Autenticação ECR |
| `git` | >= 2.0 | Controle de versão |
| `make` | >= 3.8 | Automação de comandos |

### Instalação de Pré-requisitos

**Ubuntu/Debian:**
```bash
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Ansible
sudo apt-get install ansible

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# AWS CLI
sudo apt-get install awscli

# Make
sudo apt-get install build-essential
```

**macOS (com Homebrew):**
```bash
brew install terraform ansible docker aws-cli gnu-make
```

### Credenciais AWS

Configure suas credenciais AWS:

```bash
aws configure
```

Você será solicitado por:
- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region**: `us-east-1`
- **Default output format**: `json`

### Chave SSH

Gere uma chave SSH se não possuir:

```bash
ssh-keygen -t ed25519 -C "seu-email@example.com" -f ~/.ssh/id_ed25519
```

## 🚀 Instalação

### 1. Clonar o Repositório

Abra seu terminal e execute:

```bash
# Substitua "seu-usuario" e "seu-repo" pela URL real do repositório
git clone https://github.com/seu-usuario/psc.git
cd psc
```

**O que está acontecendo:**
- `git clone`: Baixa o projeto do GitHub para sua máquina
- `cd psc`: Entra no diretório do projeto

**Exemplo real:**
```bash
git clone https://github.com/fcoedls/psc.git
cd psc
```

**Verificar se funcionou:**
```bash
# Você deve ver a estrutura do projeto
ls -la
```

### 2. Configurar Variáveis Terraform

Crie o arquivo `terraform/terraform.tfvars`:

```hcl
aws_region    = "us-east-1"
instance_type = "t3.micro"
ssh_key_path  = "~/.ssh/id_ed25519.pub"
key_name      = "psc-key"
```

### 3. Verificar Arquivos

```bash
# Validar sintaxe Terraform
make tf-validate

# Verificar formato
make tf-fmt

# Executar pre-flight check
make help
```

## 📖 Uso

### Comandos Disponíveis

Visualize todos os comandos:

```bash
make help
```

### Fluxo Básico

#### Opção 1: Pipeline Completo (Recomendado)

Executa todo o pipeline do zero à produção:

```bash
make all
```

Isso executa sequencialmente:
1. `tf-apply` - Provisiona infraestrutura AWS
2. `docker-push` - Build e push da imagem para ECR
3. `deploy` - Deploy na EC2 via Ansible

#### Opção 2: Passo a Passo

**Inicializar Terraform:**
```bash
make tf-init
```

**Provisionar Infraestrutura:**
```bash
make tf-apply
```

**Build e Push da Imagem Docker:**
```bash
# Fazer login no ECR
make docker-login

# Build e push
make docker-push
```

**Testar Conectividade:**
```bash
make ansible-ping
```

**Deploy na EC2:**
```bash
make deploy
```

### Destruir Infraestrutura

```bash
make destroy
```

⚠️ **Aviso**: Isso **deletará toda a infraestrutura AWS** e incorrirá em custos zero.

## 📁 Estrutura do Projeto

```
psc/
├── README.md                    # Este arquivo
├── Dockerfile                   # Imagem Docker com Nginx
├── Makefile                     # Automação de pipeline
│
├── html/                        # Frontend estático
│   ├── index.html              # Página principal (Tailwind CSS)
│   └── img/                    # Assets (ícones, favicons)
│
├── terraform/                   # Infraestrutura como Código
│   ├── main.tf                 # Configuração EC2, Security Group, VPC
│   ├── network.tf              # VPC e Subnets
│   ├── ecr.tf                  # ECR Repository
│   ├── providers.tf            # AWS Provider
│   ├── variables.tf            # Variáveis de entrada
│   ├── outputs.tf              # Outputs (URLs, IPs)
│   ├── terraform.tfvars        # Valores das variáveis (não commitar!)
│   ├── terraform.tfstate*      # Estado (não commitar!)
│   └── .gitignore              # Ignorar arquivo de estado
│
├── ansible/                     # Automação e Deploy
│   ├── ansible.cfg             # Configuração Ansible
│   ├── inventory.ini           # Hosts (IPs EC2)
│   ├── playbook.yml            # Tarefas de deploy
│
├── nginx/                       # Configuração Nginx
│   └── defaul.conf             # Config do Nginx
│
├── .gitignore                  # Git ignore patterns
└── .git/                       # Repositório Git
```

## ⚙️ Configuração

### Variáveis Terraform

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `aws_region` | string | `us-east-1` | Região da AWS |
| `instance_type` | string | `t3.micro` | Tipo de instância EC2 (Free Tier) |
| `ssh_key_path` | string | - | Caminho para chave pública SSH |
| `key_name` | string | - | Nome da chave na AWS |

### Arquivo de Configuração Ansible

`ansible.cfg` contém:
- Host key checking
- Interpretador Python
- Configurações de conexão SSH

### Inventory Ansible

`ansible/inventory.ini` define grupos de hosts:

```ini
[webservers]
# Será preenchido pelo Terraform output
<EC2_PUBLIC_IP>

[webservers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

### Dockerfile

Usa Nginx baseado em Alpine para imagem mínima:

```dockerfile
FROM nginx:alpine
RUN rm /usr/share/nginx/html/index.html
COPY html/index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

## 🐛 Troubleshooting

### Erro: "aws-cli: command not found"

Instale AWS CLI:
```bash
pip install awscli
# ou
brew install awscli
```

### Erro: "Permission denied (publickey)"

Verifique permissões SSH:
```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

Verifique se a chave está registrada na AWS:
```bash
aws ec2 describe-key-pairs --region us-east-1
```

### Erro: "Terraform state is locked"

Desbloqueie o estado:
```bash
cd terraform
terraform force-unlock <LOCK_ID>
```

### Erro: "Docker push failed: unauthorized"

Faça login novamente no ECR:
```bash
make docker-login
make docker-push
```

### Erro: "Ansible host unreachable"

Verifique:
1. Security Group permite SSH (porta 22) do seu IP
2. EC2 está em estado "running"
3. Verifique conectividade:
   ```bash
   ssh -i ~/.ssh/id_ed25519 ubuntu@<EC2_PUBLIC_IP>
   ```

### Erro: "Terraform apply failed: AccessDenied"

Verifique credenciais AWS:
```bash
aws sts get-caller-identity
```

Garanta que têm permissões para:
- EC2, ECR, VPC, Security Groups
- IAM (key pairs)

## 🔒 Considerações de Segurança

⚠️ **Importante**: Esta configuração é para desenvolvimento. Para produção:

1. **Acesso SSH**: Restrinja para IPs específicos em vez de `0.0.0.0/0`
   ```hcl
   cidr_blocks = ["SEU_IP/32"]
   ```

2. **HTTPS**: Adicione certificado SSL/TLS
   ```bash
   # Use Let's Encrypt com Certbot
   # Configure em nginx via Ansible
   ```

3. **Secrets**: Mantenha em AWS Secrets Manager
   ```hcl
   resource "aws_secretsmanager_secret" "app_secret" {
     name = "psc/app-secret"
   }
   ```

4. **Logs**: Configure CloudWatch
   ```bash
   # Adicione em main.tf
   resource "aws_cloudwatch_log_group" "nginx_logs" {
     name              = "/aws/ec2/nginx"
     retention_in_days = 7
   }
   ```

5. **.tfstate**: Nunca commite arquivo de estado
   ```bash
   # Adicionado ao .gitignore
   terraform.tfstate*
   ```

## 📊 Custos e Free Tier

Esse projeto usa recursos elegíveis para AWS Free Tier:

- **EC2**: t2.micro ou t3.micro (750h/mês)
- **ECR**: 0.50 USD por GB armazenado
- **Data Transfer**: Primeiros 15GB/mês gratuitos

Monitore custos:
```bash
# Visualizar recursos provisionados
make tf-show
make tf-plan
```

## 🤝 Contribuindo

1. Crie uma branch para sua feature:
   ```bash
   git checkout -b feature/minha-feature
   ```

2. Commit suas mudanças:
   ```bash
   git commit -am 'Add: descrição da feature'
   ```

3. Push para a branch:
   ```bash
   git push origin feature/minha-feature
   ```

4. Abra um Pull Request

### Padrões de Commit

Use prefixos convencionais:
- `add:` - Nova feature
- `fix:` - Bug fix
- `docs:` - Documentação
- `refactor:` - Refatoração
- `style:` - Formatação
- `test:` - Testes

## � Desenvolvedor

Desenvolvido por **Francisco Edson Lopes da SIlva**

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black?logo=github&logoColor=white)](https://github.com/fcoelopes)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue?logo=linkedin&logoColor=white)](https://linkedin.com/in/franciscoedsonlopessilva)
[![Email](https://img.shields.io/badge/Email-Contact-red?logo=gmail&logoColor=white)](mailto:contato@fcoelds.dev.br)

Explore meus outros projetos e contribuições no GitHub!

---

##  Licença

Este projeto está sob licença MIT. Veja [LICENSE](./LICENSE) para mais detalhes.

## 💬 Suporte

Para dúvidas ou problemas:

1. Verifique as issues abertas
2. Consulte a seção [Troubleshooting](#troubleshooting)
3. Abra uma nova issue com:
   - Descrição do problema
   - Passos para reproduzir
   - Output de logs/erros
   - Versões do software

## 📚 Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

**Última atualização**: 2026-02-23

Desenvolvido com ❤️ para o PSC Cloud Project
