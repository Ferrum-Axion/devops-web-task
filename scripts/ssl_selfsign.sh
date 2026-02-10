#!/usr/bin/env bash
################################
# Developer: Liad Binyamin
# Purpose: Deploy a self-signed SSL certificate 
# Version: 0.0.3
# Date: 10.2.26
set -o errexit
set -o pipefail
set -o nounset
################################

CERT_DIR="/etc/nginx/ssl"
CERT_KEY="${CERT_DIR}/devops-task.key"
CERT_CRT="${CERT_DIR}/devops-task.crt"

# Check if the the script is run as root
run_as_root() {
    if [[ $EUID -ne 0 ]];
    then
        echo "This script must be run with root privileges"
        exit 1
    fi 
}


# Checks if the folder exists, if not it creates it
check_cert_dir() {
    if [[ ! -d "$CERT_DIR" ]];
    then
        echo "Creating a directory for the SSL certificate at $CERT_DIR"
        mkdir -p "$CERT_DIR"
    else
        echo "The certificate directory already exists at $CERT_DIR"
    fi
}

# Checks if openssl is installed and generates a self-signed SSL certificate
generate_ssl_certificate() {
    if ! command -v openssl &> /dev/null;
    then
        echo "openssl is not installed. Please install it and run the script again."
        exit 1
    else
        echo "Generating a self-signed certificate"
        openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
            -keyout "$CERT_KEY" \
            -out "$CERT_CRT" \
            -subj "/CN=localhost"
        echo "Certificate generated successfully at $CERT_CRT"
    fi
}

main() {
    run_as_root
    check_cert_dir
    generate_ssl_certificate
}