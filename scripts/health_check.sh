#!/usr/bin/env bash
###################
#
# Created by: Elena Kuznetsov
# Purpose: Health Status Check
# Version: 0.0.1
# Date: 25/2/2026
#
###################

set -euo pipefail

URL="https://localhost"

check_health() {
    echo "Ok, lets check the health of $URL site"

    HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" "$URL")

    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "The site is healthy like a horse, it has returned $HTTP_CODE!"
        return 0
    else
        echo "Oh no, it says $HTTP_CODE"
        return 1
    fi
}

if check_health; then
    exit 0
else
    exit 1
fi
