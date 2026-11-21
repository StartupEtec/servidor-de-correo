# Deploy

## Estructura en el servidor

```
/home/Startup/
├── servidor-de-correo/   # este repo (solo configs, sin secretos)
└── runtime/
    ├── mailserver/       # compose real + data/ + .env (gitignore)
    ├── nginx-proxy/      # conf.d/ + letsencrypt/ + certbot/ + logs/
    └── cloudflare-ddns/  # docker-compose.yml + .env (gitignore)
```

## 1. Preparar secretos

```bash
cp .env.example /ruta/segura/mailserver.env   # completar passwords
python3 mailserver/scripts/render.py mailserver/config/mysql-init/init.sql.example /home/Startup/runtime/mailserver/config/mysql-init/init.sql
cp mailserver/config/postfix/postfix-accounts.cf.example /tmp/accounts.example
# El archivo real se genera con: docker exec -it mailserver setup email add usuario@laborin.app
```

La red externa `proxy` debe existir: `docker network create proxy`.

## 2. Levantar

```bash
docker compose --project-directory /home/Startup/runtime/mailserver \
  -f /home/Startup/runtime/mailserver/docker-compose.yml up -d
docker compose --project-directory /home/Startup/runtime/nginx-proxy \
  -f /home/Startup/runtime/nginx-proxy/docker-compose.yml up -d
docker compose --project-directory /home/Startup/runtime/cloudflare-ddns \
  -f /home/Startup/runtime/cloudflare-ddns/docker-compose.yml up -d
```

Verificar: `docker exec mailserver setup email list` y `docker ps`.

## 3. Certificados

Los certificados de `laborin.app` están en `/etc/letsencrypt` (root). El de `laborin-webmail.laborin.app` se emite en un directorio propiedad del usuario:

```bash
docker run --rm \
  -v /home/Startup/runtime/nginx-proxy/certbot/www:/var/www/certbot \
  -v /home/Startup/runtime/nginx-proxy/letsencrypt:/etc/letsencrypt \
  certbot/certbot:latest certonly --webroot -w /var/www/certbot \
  -d laborin-webmail.laborin.app --agree-tos --register-unsafely-without-email
```

El compose de nginx lo monta como `/etc/letsencrypt-new`. Renovar con el mismo comando; luego `docker exec nginx-proxy nginx -s reload`.

## 4. DNS

`DOMAINS` en `cloudflare-ddns/.env` incluye `laborin.app`, `www`, `mx` y `laborin-webmail.laborin.app`. `PROXIED=!is(mx.laborin.app)` deja `mx` sin proxy (SMTP directo) y el resto detrás de Cloudflare.

## 5. Seguridad antes de commitear

```bash
git check-ignore -v /home/Startup/runtime/mailserver/.env \
  /home/Startup/runtime/mailserver/data /home/Startup/runtime/nginx-proxy/letsencrypt
git grep -nIE '(PASSWORD=|TOKEN=|SECRET=|\$6\$|PRIVATE KEY)' -- ':!*.example'
```
