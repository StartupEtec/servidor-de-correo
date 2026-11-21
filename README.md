# servidor-de-correo

Configuración y datos operativos del servidor de correo de `laborin.app`. Todo vive en este único directorio; lo sensible está ignorado por `git` y nunca se sube a GitHub.

## Estructura

```
/home/Startup/servidor-de-correo/
├── .env.example
├── .gitignore
├── README.md
├── docs/
├── scripts/                  # renovación del certificado del webmail
├── mailserver/
│   ├── .env                  # real, ignorado
│   ├── docker-compose.yml
│   ├── comandos              # real, ignorado
│   ├── config/
│   └── data/                 # correos, MySQL y estado: ignorado
├── nginx-proxy/
│   ├── docker-compose.yml
│   ├── conf.d/               # vhosts activos, versionados
│   ├── certbot/              # ignorado
│   ├── letsencrypt/          # certificado del webmail, ignorado
│   └── logs/                 # ignorado
└── cloudflare-ddns/
    ├── docker-compose.yml
    ├── .env.example
    └── .env                  # token real, ignorado
```

No existe `/home/Startup/runtime`.

## Operación

```bash
cd /home/Startup/servidor-de-correo

docker compose --project-directory mailserver -f mailserver/docker-compose.yml up -d
docker compose --project-directory nginx-proxy -f nginx-proxy/docker-compose.yml up -d
docker compose --project-directory cloudflare-ddns -f cloudflare-ddns/docker-compose.yml up -d

./scripts/renew-webmail-cert.sh
```

## URLs

- Webmail: `https://laborin-webmail.laborin.app/`
- `https://laborin.app/` queda libre para la landing.
- `https://laborin.app/webmail/` redirige al webmail por compatibilidad.

## Seguridad

Los archivos reales con passwords, hashes, tokens, certificados, correos y datos están en este directorio pero cubiertos por `.gitignore`:

- `.env` reales (solo se versionan `.env.example`).
- `mailserver/data/`, `mailserver/comandos`, `postfix-accounts.cf`, `init.sql`.
- `nginx-proxy/certbot/`, `letsencrypt/`, `logs/` y cualquier `*.bak*`.

Ver [docs/DEPLOY.md](docs/DEPLOY.md) para el paso a paso.
