#!/usr/bin/env bash

###################
#
# Created by: Elena Kuznetsov
# Purpose: Site and config deployment
# Version: 0.0.1
# Date: 25.2.26
#
###################

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MY_SITE="$PROJECT_ROOT/site"
MY_CONFIG="$PROJECT_ROOT/nginx/site.conf"
MY_SSL_CONFIG="$PROJECT_ROOT/nginx/site-ssl.conf"

SITE_DEST="/var/www/devops-site"
CONFIG_DEST="/etc/nginx/sites-available/devops-site"
SSL_CONFIG_DEST="/etc/nginx/sites-available/devops-site-ssl"

check_if_root() {
    if [[ $EUID -ne 0 ]];
    then
        echo "Error: This script must be run as root. Try: sudo $0"
        exit 1
    fi
}

deploy_files() {
    echo "Copying files to $SITE_DEST..."
    mkdir -p "$SITE_DEST"
    cp -r "$MY_SITE/"* "$SITE_DEST"
}

update_configs() {
    echo "Updating NGINX Config with dynamic paths..."
    cp "$MY_CONFIG" "$CONFIG_DEST"

    sed -e "s|{{CERT}}|/etc/nginx/ssl/nginx-selfsigned.crt|g" \
        -e "s|{{KEY}}|/etc/nginx/ssl/nginx-selfsigned.key|g" \
        -e "s|{{ROOT}}|$SITE_DEST|g" \
        "$MY_SSL_CONFIG" > "$SSL_CONFIG_DEST"

    ln -sf "$CONFIG_DEST" "/etc/nginx/sites-enabled/devops-site"
    ln -sf "$SSL_CONFIG_DEST" "/etc/nginx/sites-enabled/devops-site-ssl"
}

restart_nginx() {
    if nginx -t;
    then
        systemctl reload nginx
        return 0
    else
        return 1
    fi
}


check_if_root

echo "Starting Deploy..."

if deploy_files && update_configs && restart_nginx;
then
    echo "Success!"
    exit 0
else
    echo "Deployment failed!"
    exit 1
fi
