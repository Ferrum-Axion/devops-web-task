#!/usr/bin/env bash
################################
# Developer: Liad Binyamin
# Purpose: Health check script to verify that the web server is running 
# Version: 0.0.1
# Date: 10.2.26
set -o errexit
set -o pipefail
set -o nounset
################################


URL=http://localhost
URL_SSL=https://localhost

check_http_response() {
    HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}\n" "$URL")
    if [[ "$HTTP_RESPONSE" -ne 301 ]];
    then
        echo "Health check failed for $URL. HTTP response code: $HTTP_RESPONSE"
        exit 1
    fi
}

check_https_response() {
    HTTPS_RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}\n" "$URL_SSL")
    if [[ "$HTTPS_RESPONSE" -ne 200 ]];
    then
        echo "Health check failed for $URL_SSL. HTTP response code: $HTTPS_RESPONSE"
        exit 1
    fi
}

main() {
    check_http_response
    check_https_response
    echo "Health check passed successfully for both HTTP and HTTPS endpoints."
}

main