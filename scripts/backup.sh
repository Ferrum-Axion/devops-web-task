#!/usr/bin/env bash
################################
# Developer: Liad Binyamin
# Purpose: Backup the current state of the web server
# Version: 0.0.1
# Date: 14.2.26
set -o errexit
set -o pipefail
set -o nounset
################################

SOURCE_SITE_DIR=/var/www/devops-site
SOURCE_CONF_DIR=/etc/nginx/sites-available
BACKUP_DIR=/var/backups/devops-site
VERSION=$(date +"%d.%m.%Y - %H:%M:%S")
BACKUP_FILE="$BACKUP_DIR/backup_$VERSION.tar.gz"

runs_as_root() {
    if [[ $EUID -ne 0 ]];
    then
        echo "This script must be run with root privileges"
        exit 1
    fi
}

# Creates a backup directory and sets the correct permissions for the webdeploy user
setup_backup_directory() {
    mkdir -p "$BACKUP_DIR"
    chown -R webdeploy:webdeploy "$BACKUP_DIR"
    chmod -R 755 "$BACKUP_DIR"
    echo "Backup directory is set up at $BACKUP_DIR"
}

# Compresses the site content and nginx configuration files into a tar.gz archive and saves it in the backup directory with a timestamp
create_backup() {
    tar -czvf "$BACKUP_FILE" -C "$SOURCE_SITE_DIR" . -C "$SOURCE_CONF_DIR" .
    echo "Backup created successfully at $BACKUP_FILE"
}

# Saves the last 5 backup files in the backup directory and deletes older backups
manage_backup_retention() {
    BACKUP_FILES=("$BACKUP_DIR"/backup_*.tar.gz)
    if [[ ${#BACKUP_FILES[@]} -gt 5 ]];
    then
        echo "Managing backup retention. Keeping the last 5"
        ls -t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +6 | xargs rm -f
        echo "Old backups deleted successfully"
    else
        echo "No old backups to delete"
    fi
}

main() {
    runs_as_root
    setup_backup_directory
    create_backup
    manage_backup_retention
}

main