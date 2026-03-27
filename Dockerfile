# Utilise une image Nginx légère basée sur Alpine Linux
FROM nginx:alpine

# Métadonnées de l'image (mal gérées)
LABEL maintainer="Projet Devsecops"
LABEL description="Application DevOps sécurisée"
LABEL maintainer=" Garance Ledoigt <gledoigt40@gmail.com>" 

# Installation (non optimisée)
RUN apk add --no-cache \
    ca-certificates \
    wget \
    curl \
    vim \
    && rm -rf /var/cache/apk/*

# Copie sans contrôle de permissions
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY src/ /usr/share/nginx/html/

# Permissions incorrectes (user inexistant)
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chmod -R 777 /usr/share/nginx/html

# Mauvaise gestion des fichiers système
RUN touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/cache/nginx

# Passage à un utilisateur non créé , on va déclarer 
USER root

# Port privilégié avec non-root
EXPOSE 80

# Healthcheck fragile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --spider http://localhost/ || exit 1

# Lancement nginx
CMD ["nginx", "-g", "daemon off;"]

