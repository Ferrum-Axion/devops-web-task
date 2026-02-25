#!/usr/bin/env bash
###################
#
# Created by: Elena Kuznetsov
# Purpose: SSL Self Sign
# Version: 0.0.1
# Date: 7/2/2026
#
###################

set -euo pipefail

SSL_DIR="/etc/nginx/ssl/"

check_if_root() {
    if [[ $EUID -ne 0 ]];
    then
       echo "Error: This script must be run as root (use sudo)"
       exit 1
    fi
}

create_folder() {
    echo "Creating a folder for the keys..."
    if mkdir -p "$SSL_DIR";
    then
        echo "Ok, the folder is ready"
    else
        echo "Something went wrong, abort the mission, capatin!"
        exit 1
    fi
}

generate_key() {
    echo "Creating the Key..."
    if openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/nginx-selfsigned.key" \
        -out "$SSL_DIR/nginx-selfsigned.crt" \
        -subj "/C=RU/ST=State/L=City/O=Organization/CN=localhost";
    then
        echo "The Key has been created succesfully!"
    else
        echo "Something went wrong, abort the mission, captain!"
        exit 1
    fi
}

set_permissions() {
    echo "Configuring access permissions..."
    if chmod 600 "$SSL_DIR/nginx-selfsigned.key" && chmod 644 "$SSL_DIR/nginx-selfsigned.crt";
    then
        echo "Okay, the key has been created, congrats!"
    else
        echo "Something went wrong, abort the mission, captain!"
        exit 1
    fi
}

check_if_root

echo "Starting creating SSL certificate..."

create_folder
generate_key
set_permissions

echo "Yay! The key is ready and and is stored in $SSL_DIR!"
exit 0
