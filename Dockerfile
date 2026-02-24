# Usa uma imagem leve do Nginx
FROM nginx:alpine

# Metadados da imagem
LABEL maintainer="Edson Lopes <contato@fcoelds.dev.br>"
LABEL description="Servidor Nginx com página HTML customizada para o projeto PSC"
LABEL version="1.0"

# Remove a página padrão do Nginx
RUN rm /usr/share/nginx/html/index.html

# Copia o arquivo index.html customizado para o diretório do Nginx
COPY html/index.html /usr/share/nginx/html/index.html

# Define um ponto de montagem em /var/log/nginx para armazenar os logs do Nginx
# Permite que os logs persistam fora do filesystem do container e sejam compartilhados com o host ou outros containers
VOLUME ["/var/log/nginx"]

# Health check para monitorar saúde do container
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Expõe a porta 80
EXPOSE 80