#!/usr/bin/env bash
# Generate a self-signed SSL certificate for devops-site. Run from repo root.
# Usage: ./scripts/ssl_selfsign.sh [output-dir]
##### ==>> almost none of the things suggest during the shell programming lessons are here: it works, barely... 75
set -e

OUTPUT_DIR="${1:-nginx}"
KEY_FILE="$OUTPUT_DIR/devops-site.key"
CRT_FILE="$OUTPUT_DIR/devops-site.crt"
DAYS="${SSL_DAYS:-365}"
BITS="${SSL_BITS:-2048}"

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Error: Output directory $OUTPUT_DIR not found" >&2
  exit 1
fi

if [ -f "$KEY_FILE" ] || [ -f "$CRT_FILE" ]; then
  echo "Error: Certificate or key already exists. Remove $KEY_FILE and $CRT_FILE first." >&2
  exit 1
fi

echo "Generating self-signed certificate ($BITS bits, valid ${DAYS} days)..."

openssl req -x509 -nodes -days "$DAYS" -newkey rsa:"$BITS" \
  -keyout "$KEY_FILE" -out "$CRT_FILE" \
  -subj "/CN=localhost/O=DevOps-Site/C=US"

chmod 600 "$KEY_FILE"
chmod 644 "$CRT_FILE"

echo "Created: $KEY_FILE, $CRT_FILE"
exit 0
