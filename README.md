# Static Website Deployment with Automation and Self-Signed SSL

A DevOps solution for deploying a static website on Linux with automated deployment, backup, and rollback using POSIX-compliant shell scripts.

## Quick Start

```bash
# 1. Generate SSL certificate
sudo bash scripts/ssl_selfsign.sh

# 2. Deploy website
sudo bash scripts/deploy.sh

# 3. Verify health
bash scripts/health_check.sh
```

## Scripts Overview

### ssl_selfsign.sh
Generates a self-signed SSL certificate for HTTPS.
- Creates `/etc/nginx/ssl` directory
- Generates 4096-bit RSA certificate valid for 3650 days
- Creates `/etc/nginx/ssl/devops-task.key` and `/etc/nginx/ssl/devops-task.crt`
- Requires root privileges

```bash
sudo bash scripts/ssl_selfsign.sh
```

### deploy.sh
Complete website deployment automation.
- Verifies root privileges
- Creates `webdeploy` non-root user
- Sets up `/var/www/devops-site` with correct permissions
- Copies website content from `site/` directory
- Configures NGINX with HTTP and HTTPS blocks
- Validates and reloads NGINX
- Displays deployment version with timestamp

```bash
sudo bash scripts/deploy.sh
```

### backup.sh
Creates timestamped backups of website and NGINX configuration.
- Creates backup directory at `/var/backups/devops-site`
- Compresses website files and configs into tar.gz archive
- Automatically keeps last 5 backups, deletes older ones
- Backup naming: `backup_DD.MM.YYYY - HH:MM:SS.tar.gz`
- Requires root privileges

```bash
sudo bash scripts/backup.sh
```

### roll-back.sh
Restores website from the latest backup.
- Finds the most recent backup file
- Extracts backup to temporary directory
- Restores HTML files to `/var/www/devops-site`
- Restores NGINX configuration files
- Validates and reloads NGINX configuration
- Cleans up temporary files
- Requires root privileges

```bash
sudo bash scripts/roll-back.sh
```

### health_check.sh
Verifies website health and endpoint availability.
- Checks HTTP endpoint (port 80) expects 301 redirect to HTTPS
- Checks HTTPS endpoint (port 443) expects HTTP 200 status
- Returns 0 if healthy, 1 if unhealthy
- Does not require root privileges

```bash
bash scripts/health_check.sh
```

## Directory Structure

```
devops-web-task/
├── site/
│   ├── index.html              # Homepage
│   └── health.html             # Health check page
├── nginx/
│   ├── site.conf               # HTTP → HTTPS redirect
│   └── site-ssl.conf           # HTTPS server block
├── scripts/
│   ├── deploy.sh               # Deploy website
│   ├── backup.sh               # Create backups
│   ├── roll-back.sh            # Restore from backup
│   ├── health_check.sh         # Verify service health
│   └── ssl_selfsign.sh         # Generate SSL cert
└── README.md                   # This file
```

## Locations

| Item | Location |
|------|----------|
| Website files | `/var/www/devops-site` |
| NGINX configs | `/etc/nginx/sites-available/` |
| SSL certificate | `/etc/nginx/ssl/devops-task.crt` |
| SSL private key | `/etc/nginx/ssl/devops-task.key` |
| Backups | `/var/backups/devops-site/` |
| Deployment user | `webdeploy` |

## Typical Workflow

```bash
# Initial setup
sudo bash scripts/ssl_selfsign.sh
sudo bash scripts/deploy.sh
bash scripts/health_check.sh

# Before updates
sudo bash scripts/backup.sh

# After issues, restore
sudo bash scripts/roll-back.sh
```

## NGINX Configuration

**site.conf:** Listens on port 80, redirects all traffic to HTTPS  
**site-ssl.conf:** Listens on port 443 with SSL, serves static files

- `/` → serves `index.html`
- `/health` → serves `health.html`
- All other paths → 404 error
