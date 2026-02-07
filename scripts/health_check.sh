#!/usr/bin/env bash
###################
#
# Created by: Elena Kuznetsov
# Purpose: Health Status Check
# Version: 0.0.1
# Date: 7/2/2026
#
###################
#
#
#
URL="https://localhost"

echo "Ok, lets check the health of $URL site"

HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" "$URL")

if [ "$HTTP_CODE" -eq 200 ];
then 
    echo "The site is healthy like a horse, it has returned $HTTP_CODE!"
    exit 0
else
    echo "Oh no, it says $HTTP_CODE"
    eixt 1
fi



