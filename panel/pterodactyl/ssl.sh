#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'
PHP_VERSION="${PHP_VERSION:-8.3}"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this configurator as root." >&2
    exit 1
fi

clear 2>/dev/null || true
echo -e "${CYAN}${BOLD}=========================================${NC}"
echo -e "${CYAN}      PTERODACTYL NGINX CONFIGURATOR     ${NC}"
echo -e "${CYAN}=========================================${NC}"
echo

read -r -p "Enter your domain (for example, panel.example.com): " DOMAIN
if [[ ! "$DOMAIN" =~ ^([A-Za-z0-9-]+\.)+[A-Za-z]{2,}$ ]]; then
    echo "Invalid domain name." >&2
    exit 1
fi

PANEL_DIR="/var/www/pterodactyl"
if [[ ! -d "$PANEL_DIR" ]]; then
    echo "Pterodactyl directory not found: $PANEL_DIR" >&2
    exit 1
fi
cd "$PANEL_DIR"

echo -e "${BOLD}Select Configuration Mode:${NC}"
echo -e "  ${GREEN}[1]${NC} SSL using an existing certificate"
echo -e "  ${YELLOW}[2]${NC} HTTP only (not recommended for production)"
echo -e "  ${CYAN}[3]${NC} Request a Let's Encrypt certificate"
read -r -p "Select option [1-3]: " OPTION

if [[ "$OPTION" != "1" && "$OPTION" != "2" && "$OPTION" != "3" ]]; then
    echo "Invalid option." >&2
    exit 1
fi

rm -f /etc/nginx/sites-enabled/default

write_php_location() {
    cat <<EOF
    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
EOF
}

if [[ "$OPTION" == "1" ]]; then
    read -r -p "Use Let's Encrypt certificate path? [y/N]: " SSLTYPE
    if [[ "$SSLTYPE" =~ ^[Yy]$ ]]; then
        FULLCHAIN="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
        PRIVKEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
    else
        FULLCHAIN="/etc/certs/panel/fullchain.pem"
        PRIVKEY="/etc/certs/panel/privkey.pem"
    fi
    [[ -f "$FULLCHAIN" && -f "$PRIVKEY" ]] || {
        echo "Certificate files were not found." >&2
        exit 1
    }
    sed -i "s|^APP_URL=.*|APP_URL=https://${DOMAIN}|" .env
    cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl http2;
    server_name ${DOMAIN};
    root /var/www/pterodactyl/public;
    index index.php;
    ssl_certificate ${FULLCHAIN};
    ssl_certificate_key ${PRIVKEY};
    client_max_body_size 100m;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
$(write_php_location)
    location ~ /\.ht { deny all; }
}
EOF
elif [[ "$OPTION" == "2" ]]; then
    sed -i "s|^APP_URL=.*|APP_URL=http://${DOMAIN}|" .env
    cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    root /var/www/pterodactyl/public;
    index index.php;
    client_max_body_size 100m;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
$(write_php_location)
    location ~ /\.ht { deny all; }
}
EOF
else
    apt-get update -y
    apt-get install -y certbot python3-certbot-nginx
    read -r -p "Email for certificate renewal notices: " EMAIL
    if [[ ! "$EMAIL" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]; then
        echo "A valid email address is required." >&2
        exit 1
    fi
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect
    echo -e "${GREEN}✔ SSL installed and HTTPS redirection enabled.${NC}"
    exit 0
fi

ln -sfn /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
nginx -t
systemctl restart nginx
echo -e "${GREEN}✔ Nginx configuration completed.${NC}"