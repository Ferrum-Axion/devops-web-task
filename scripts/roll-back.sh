#!/usr/bin/env bash
###################
#
# Created by: Elena Kuznetsov
# Purpose: Rollback site to the latest backup
# Version: 0.0.1
# Date: 25/2/2026
#
###################

set -euo pipefail

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

BACKUP_DIR="$REAL_HOME/backups"
DEST_DIR="/var/www/devops-site"

check_if_root() {
    if [[ $EUID -ne 0 ]];
    then
        echo "Error: This script must be run as root. Try: sudo $0"
        exit 1
    fi
}

find_latest_backup() {
    echo "Starting the rolling back proccess... lets search for the latest backup in $BACKUP_DIR..."
    
    if [ ! -d "$BACKUP_DIR" ];
    then
        echo "Error: Directory $BACKUP_DIR does not exist."
        exit 1
    fi

    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/fasloli_site_backup_*.tar.gz 2>/dev/null | head -n 1)

    if [ -z "$LATEST_BACKUP" ];
    then
        echo "Panic! No backups found in $BACKUP_DIR. We are doomed, good luck"
        exit 1
    fi

    echo "Found it, restoring from the: $LATEST_BACKUP"
}

restore_backup() {
    rm -rf "${DEST_DIR:?}"/*

    if tar -xzf "$LATEST_BACKUP" -C "$DEST_DIR";
    then
        echo "Success! The site has been restored to its former glory, reloading nginx..."
        systemctl reload nginx
        echo "Nginx reloaded, check the site now!"
    else
        echo "Oh crap, something went wrong, sorry"
        exit 1
    fi
}

check_if_root
find_latest_backup
restore_backup

exit 0
