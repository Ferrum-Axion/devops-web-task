#!/usr/bin/env bash
################################
# Developer: Liad Binyamin
# Purpose: Rollback to the latest backup
# Version: 0.0.1
# Date: 14.2.26
set -o errexit
set -o pipefail
set -o nounset
################################
BACKUP_DIR=/var/backups/devops-site
WEB_DIR=/var/www/devops-site
CONF_DIR=/etc/nginx/sites-available

# Check if the script is run as root
run_as_root() {
    if [[ $EUID -ne 0 ]];
    then
        echo "This script must be run with root privileges"
        exit 1
    fi 
}

# Find the latest backup file in the backup directory
find_latest_backup() {
    if [[ ! -d "$BACKUP_DIR" ]];
    then
        echo "Backup directory $BACKUP_DIR does not exist"
        exit 1
    fi

    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | head -n 1)
    
    if [[ -z "$LATEST_BACKUP" ]];
    then
        echo "No backup files found in $BACKUP_DIR"
        exit 1
    fi
    
    echo "Latest backup found: $LATEST_BACKUP"
}

# Extract the backup to a temporary directory
extract_backup() {
    TEMP_DIR=/tmp/devops-rollback-$(date +"%d.%m.%Y - %H:%M:%S")
    mkdir -p "$TEMP_DIR"
    echo "Extracting backup to temporary directory: $TEMP_DIR"
    
    tar -xzvf "$LATEST_BACKUP" -C "$TEMP_DIR"
    echo "Backup extracted successfully"
}

# Restore HTML files to the web directory
restore_web_files() {
    echo "Restoring web files to $WEB_DIR"
    
    # Copy HTML and related web files from temp directory to web directory
    # This will replace existing files with the same name
    if [[ -d "$TEMP_DIR" ]];
    then
        find "$TEMP_DIR" -type f -name "*.html" -exec cp -fv {} "$WEB_DIR/" \;
        echo "Web files restored successfully"
    else
        echo "No web files found in backup"
    fi
}

# Restore nginx configuration files
restore_nginx_config() {
    echo "Restoring nginx configuration files to $CONF_DIR"
    
    # Find and restore .conf files from the backup
    if [[ -d "$TEMP_DIR" ]];
    then
        find "$TEMP_DIR" -type f -name "*.conf" -exec cp -fv {} "$CONF_DIR/" \;
        
        # Recreate symbolic links in sites-enabled
        echo "Creating symbolic links in sites-enabled"
        ln -sf "$CONF_DIR/site.conf" /etc/nginx/sites-enabled/site.conf
        ln -sf "$CONF_DIR/site-ssl.conf" /etc/nginx/sites-enabled/site-ssl.conf
        
        echo "Nginx configuration files restored successfully"
    else
        echo "No configuration files found in backup"
    fi
}


# Test and reload nginx
reload_nginx() {
    echo "Testing nginx configuration"
    
    if nginx -t;
    then
        echo "Nginx configuration test passed. Reloading nginx..."
        systemctl reload nginx
        echo "Nginx reloaded successfully"
    else
        echo "Nginx configuration test failed. Please check the configuration files."
        exit 1
    fi
}

# Clean up temporary directory
cleanup() {
    if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "$TEMP_DIR" ]];
    then
        echo "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
        echo "Cleanup completed"
    fi
}

# Print rollback completion message
print_rollback_complete() {
    echo "================================"
    echo "Rollback completed successfully"
    echo "Restored from: $(basename "$LATEST_BACKUP")"
    echo "================================"
}

# Main function
main() {
    run_as_root
    find_latest_backup
    extract_backup
    restore_web_files
    restore_nginx_config
    reload_nginx
    cleanup
    print_rollback_complete
}

main