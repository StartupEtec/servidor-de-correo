# servidor-de-correo

Configuración versionada del servidor de correo de `laborin.app`, sin secretos ni datos reales.

## Qué incluye

- `mailserver/`: Docker Compose (docker-mailserver + MariaDB + Roundcube), configs de Postfix y scripts de administración.
- `nginx-proxy/`: reverse proxy HTTP/HTTPS y los vhosts de `laborin.app` y `laborin-webmail.laborin.app`.
- `cloudflare-ddns/`: actualización de la IP pública en Cloudflare.

## URLs

- Webmail: `https://laborin-webmail.laborin.app/`
- `https://laborin.app/` queda libre para la landing.
- `https://laborin.app/webmail/` redirige al webmail por compatibilidad.

## Seguridad

Todo lo que contiene passwords, hashes, tokens, certificados o correos reales está **fuera del repo** y listo en `.gitignore`:

- `.env` reales (solo se versiona `.env.example`).
- `data/` (maildir, MySQL, estado de Postfix/Dovecot).
- `config/postfix/postfix-accounts.cf` real (usa `postfix-accounts.cf.example`).
- `config/mysql-init/init.sql` real (usa `init.sql.example` + `scripts/render.py`).
- `letsencrypt/`, `certbot/`, `logs/` y cualquier `*.bak*`.

Ver [docs/DEPLOY.md](docs/DEPLOY.md) para el paso a paso.
