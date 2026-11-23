# Deploy

## Estructura en el servidor

```
/home/Startup/servidor-de-correo/   # este repo: configs + datos reales ignorados
├── landing/          # estático de laborin.app (ignorado)
├── mailserver/       # compose real + .env + data/ (ignorados)
├── nginx-proxy/      # conf.d/ + certbot/ + letsencrypt/ + logs/ (ignorados salvo conf.d)
└── cloudflare-ddns/  # docker-compose.yml + .env (ignorado)
```

No hay directorio `runtime`: todo se ejecuta desde la raíz del repo.

## 1. Preparar secretos

```bash
cd /home/Startup/servidor-de-correo

cp .env.example mailserver/.env
cp cloudflare-ddns/.env.example cloudflare-ddns/.env
# completar passwords y CLOUDFLARE_API_TOKEN en esos .env

python3 mailserver/scripts/render.py \
  mailserver/config/mysql-init/init.sql.example \
  mailserver/config/mysql-init/init.sql

# El archivo real se genera en el servidor; NUNCA se commitea:
docker exec -it mailserver setup email add usuario@laborin.app
```

La red externa `proxy` debe existir: `docker network create proxy`.

## 2. Levantar

```bash
cd /home/Startup/servidor-de-correo

docker compose --project-directory mailserver -f mailserver/docker-compose.yml up -d
docker compose --project-directory nginx-proxy -f nginx-proxy/docker-compose.yml up -d
docker compose --project-directory cloudflare-ddns -f cloudflare-ddns/docker-compose.yml up -d
```

Verificar: `docker exec mailserver setup email list` y `docker ps`.

## 3. Certificados

Los certificados de `laborin.app` están en `/etc/letsencrypt` y los administra el `certbot.timer` del host (root). El de `laborin-webmail.laborin.app` vive en `nginx-proxy/letsencrypt` y lo administra este repo.

Emisión inicial (solo si hay que recrearlo):

```bash
cd /home/Startup/servidor-de-correo/nginx-proxy

docker run --rm \
  -v ./certbot/www:/var/www/certbot \
  -v ./letsencrypt:/etc/letsencrypt \
  certbot/certbot:latest certonly --webroot -w /var/www/certbot \
  -d laborin-webmail.laborin.app --agree-tos --register-unsafely-without-email
```

Renovación (desde la raíz del repo):

```bash
./scripts/renew-webmail-cert.sh
```

El compose de nginx monta `./letsencrypt` como `/etc/letsencrypt-new`. El script renueva con el mismo volumen y recarga nginx al finalizar.

## 4. DNS

`DOMAINS` en `cloudflare-ddns/.env` incluye `laborin.app`, `www`, `mx` y `laborin-webmail.laborin.app`. `PROXIED=!is(mx.laborin.app)` deja `mx` sin proxy (SMTP directo) y el resto detrás de Cloudflare.

## 5. Landing

El export de `Landing/out/` se publica en `landing/` (ignorado por git). El compose de nginx monta `../landing` como `/var/www/landing:ro` y `conf.d/laborin.conf` sirve el estático con `try_files`.

Verificar después de publicar:

```bash
curl -sS -o /dev/null -w '%{http_code}\n' 'https://laborin.app/'
curl -sS 'https://laborin.app/' | grep -o '<title>[^<]*'
```

## 6. Seguridad antes de commitear

```bash
cd /home/Startup/servidor-de-correo

git check-ignore -v mailserver/.env mailserver/data \
  mailserver/comandos mailserver/config/postfix/postfix-accounts.cf \
  mailserver/config/mysql-init/init.sql nginx-proxy/letsencrypt \
  nginx-proxy/certbot nginx-proxy/logs cloudflare-ddns/.env

git grep -nIE '(PASSWORD=|TOKEN=|SECRET=|\$6\$|PRIVATE KEY)' -- ':!*.example'
```
