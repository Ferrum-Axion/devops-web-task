#!/usr/bin/env bash
################################
# Developer: Liad Binyamin
# Purpose: Deploy the web server with the latest site content and nginx configuration 
# Version: 0.0.3
# Date: 10.2.26
set -o errexit
set -o pipefail
set -o nounset
################################



SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WEB_DIR=/var/www/devops-site
VERSION=$(date +"%d.%m.%Y - %H:%M:%S") 

# Check if the script is run as root
run_as_root() {
    if [[ $EUID -ne 0 ]];
    then
        echo "This script must be run with root privileges"
        exit 1
    fi 
}

# Creates webdeploy (non root) user if it doesn't exist
create_webdeploy_user() {
    if id "webdeploy" &> /dev/null;
    then
        echo "The user webdeploy is already exists"
    else
        echo "Creating a non root user named webdeploy"
        useradd -s /bin/bash -c "Webdeploy user for the DevOps task" webdeploy
        echo "User webdeploy created successfully"
    fi
}

# setup the web directory with the correct permissions and ownership for the webdeploy user
setup_web_directory() {
    mkdir -p "$WEB_DIR"
    chown -R webdeploy:webdeploy "$WEB_DIR"
    chmod -R 755 "$WEB_DIR"
    echo "Web directory is set up at $WEB_DIR with ownership to webdeploy"
    # Copy the site content to the web directory
    cp -rvu "$PROJECT_DIR/site/." "$WEB_DIR/"
    echo "Site content copied to $WEB_DIR"
}

# Checks if nginx is installed and copies the nginx configuration file to the correct location
setup_nginx() {
    if ! command -v nginx &> /dev/null;
    then
        echo "Nginx is not installed. Please install it and run the script again."
        exit 1
    else
        # Copy config to sites-available 
        echo "Setting up nginx configuration"
        cp -rvu "$PROJECT_DIR/nginx/"*.conf /etc/nginx/sites-available/
        # Create symbolic links in sites-enabled
        ln -sf /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
        ln -sf /etc/nginx/sites-available/site-ssl.conf /etc/nginx/sites-enabled/site-ssl.conf
        echo "Nginx configuration set up successfully"
    fi
}

# Checks nginx status and restarts it to apply the new configuration
restart_nginx() {
    if (nginx -t);
    then
        echo "Reloading nginx to apply the new configuration"
        systemctl reload nginx
        echo "Nginx reloaded successfully"
    else
        echo "Nginx configuration test failed. Please check the configuration files and fix any issues before running the script again."
        exit 1
    fi
}

# Prints the deployment version
print_version_complete() {
    echo "================================"
    echo "Deployment completed successfully"
    echo "Deployment version: $VERSION"
    echo "================================"
}

main() {
    run_as_root
    create_webdeploy_user
    setup_web_directory
    setup_nginx
    restart_nginx
    print_version_complete
}

main