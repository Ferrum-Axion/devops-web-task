### DevOps Web Task by Fasloli ###

This project automates everything for a site with SSL with grace and class

### How to use ###
1. **SSL**: Run `./scripts/ssl_selfsign.sh` to get the  keys
2. **Deploy**: Run `./scripts/deploy.sh` to start the site
3. **Check**: Run `./scripts/health_check.sh` to check the return status
4. **Backup**: Run `./scripts/backup.sh` This script automatically creates a backup folder at `~/backups` (in your home directory) if it's not already there, t keeps only the last 5 copies to save space
5. **Rollback**: Run `./scripts/roll-back.sh` if you broke something
