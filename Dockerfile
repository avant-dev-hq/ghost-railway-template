FROM ghost:latest

# Copy production config
COPY config.production.json /var/lib/ghost/config.production.json

# Ghost runs on 8080 in Railway
ENV PORT=8080
EXPOSE 8080
