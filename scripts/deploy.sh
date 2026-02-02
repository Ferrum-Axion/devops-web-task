#!/usr/bin/env bash

###################
#
# Created by: Elena Kuznetsov
# Purpose: Site and config deployment
# Version: 0.0.1
# Date: 2/2/2026
#
###################
#
#
#
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

MY_SITE="$PROJECT_ROOT/site"
MY_CONFIG="$PROJECT_ROOT/nginx/devops-site"

SITE_DEST="/var/www/devops-site"
CONFIG_DEST="/etc/nginx/sites-available/devops-site"

echo "Starting Deploy..."


#Step 1
echo "Copying files from $MY_SITE to $SITE_DEST..." 
if sudo cp -r "$MY_SITE/"* "$SITE_DEST";
then 
    echo "Successfuly copied the files!"
else
    echo "Something went wrong"
    exit 1
fi



#Step2
echo "Updating Config..."

if sudo cp "$MY_CONFIG" "$CONFIG_DEST";
then
    echo "Successfuly updated config!"
else
    echo "Something went wrong"
    exit 1
fi


#Step 3
if sudo nginx -t;
then
    echo "Nginx configuration is correct! Restarting Ngnix..."
    sudo systemctl reload nginx
    echo "Success!"
    
    exit 0
else
    echo "ERROR: something went wrong:\("

    exit 1
fi

