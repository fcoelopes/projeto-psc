# Usa uma imagem leve do Nginx
FROM nginx:alpine

# Remove a página padrão do Nginx
RUN rm /usr/share/nginx/html/index.html

# Copia o HTML customizado para o local correto
# O caminho 'html/' deve estar na mesma pasta que este Dockerfile
COPY html/index.html /usr/share/nginx/html/index.html

# Expõe a porta 80
EXPOSE 80