#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NGINX_DIR="$REPO_ROOT/nginx-proxy"
CERTBOT_IMAGE="${CERTBOT_IMAGE:-certbot/certbot:latest}"

docker run --rm \
  -v "$NGINX_DIR/certbot/www:/var/www/certbot" \
  -v "$NGINX_DIR/letsencrypt:/etc/letsencrypt" \
  "$CERTBOT_IMAGE" renew --webroot -w /var/www/certbot --quiet

docker exec nginx-proxy nginx -s reload
