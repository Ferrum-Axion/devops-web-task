#!/usr/bin/env bash
###################
#
# Created by: Elena Kuznetsov
# Purpose: Backup creator script
# Version: 0.0.1
# Date: 7/2/2026
#
###################


SOURCE_DIR="/var/www/devops-site"
BACKUP_DIR="$HOME/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Starting backup creation..."
mkdir -p "$BACKUP_DIR"

BACKUP_FILE="fasloli_site_backup_$TIMESTAMP.tar.gz"

if sudo tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$SOURCE_DIR" .; then
    echo "Success! Backup created: $BACKUP_FILE"
else
    echo "Captain, abort the mission! Backup failed!"
    exit 1
fi

echo "Checking for old baggage (max 5)..."
cd "$BACKUP_DIR" || exit 1

DELETED_COUNT=0

for old_file in $(ls -t fasloli_site_backup_*.tar.gz | tail -n +6); do
    echo "Removing old backup: $old_file"
    rm "$old_file"
    DELETED_COUNT=$((DELETED_COUNT + 1))
done

if [ "$DELETED_COUNT" -eq 0 ];
then
    echo "Its ok I did not delete anything this time."
else
    echo "Had to delete $DELETED_COUNT old backup to keep the place clean, sorry"
fi

echo "Mission complete!"
exit 0
