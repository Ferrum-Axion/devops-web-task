#!/usr/bin/env bash
###################
#
# Created by: Elena Kuznetsov
# Purpose: Backup creator script
# Version: 0.0.1
# Date: 25/2/2026
#
###################

set -euo pipefail

SOURCE_DIR="/var/www/devops-site"
BACKUP_DIR="$HOME/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="fasloli_site_backup_$TIMESTAMP.tar.gz"

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)"
   exit 1
fi

make_backup() {
    echo "Starting backup creation..."
    mkdir -p "$BACKUP_DIR"
    if tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$SOURCE_DIR" .; then
        echo "Success! Backup created: $BACKUP_FILE"
    else
        echo "Captain, abort the mission! Backup failed!"
        exit 1
    fi
}

cleanup_old_backups() {
    echo "Checking for old baggage (max 5)..."
    cd "$BACKUP_DIR" || exit 1

    local deleted_count=0
    for old_file in $(ls -t fasloli_site_backup_*.tar.gz 2>/dev/null | tail -n +6); do
        echo "Removing old backup: $old_file"
        rm "$old_file"
        deleted_count=$((deleted_count + 1))
    done

    if [ "$deleted_count" -eq 0 ]; then
        echo "Its ok I did not delete anything this time."
    else
        echo "Had to delete $deleted_count old backup to keep the place clean, sorry"
    fi
}

make_backup
cleanup_old_backups

echo "Mission complete!"
exit 0

