# DevOps Integrated Assignment 

## Project Title
Static Website Deployment with Automation and Self-Signed SSL

---

## Scenario
You are a junior DevOps engineer tasked with deploying a static website on a Linux server.  
You must automate deployment tasks using POSIX-compliant shell scripts, configure NGINX (HTTP + HTTPS) and manage the project with Git/GitHub.

---

## Required Project Structure

```sh
devops-web-task/
├── site/
│ ├── index.html
│ └── health.html
├── nginx/
│ ├── site.conf
│ └── site-ssl.conf
├── scripts/
│ ├── deploy.sh
│ ├── backup.sh
│ ├── health_check.sh
│ ├── roll-back.sh # Was missing on the original md
│ └── ssl_selfsign.sh
├── .gitignore
└── README.md
```

### Tasks & Requirements

#### 1. Linux Fundamentals
- Create a non-root deployment user (`webdeploy`)
- Website located at `/var/www/devops-site`
- Correct ownership and permissions
- Verify NGINX service and port 80/443 listening

#### 2. POSIX Shell Scripting
All scripts must:
- Use `#!/usr/bin/env bash`
- Be POSIX-compliant (no Bash-only syntax)
- Use proper exit codes

##### Scripts:
- `deploy.sh`: deploy site, validate NGINX config, reload service and provide version of deployment
- `backup.sh`: create timestamped backups, keep last 5
- `health_check.sh`: return 0 if site healthy, 1 otherwise
- `roll-back.sh`: takes previous version of deployment and installs it instead of latest 
- `ssl_selfsign.sh`: generate self-signed SSL cert safely

#### 3. NGINX Configuration
- Custom HTTP server block (`site.conf`)
- HTTPS server block using self-signed cert (`site-ssl.conf`)
- Default site disabled
- Access and error logs enabled
- HTTP -> HTTPS redirect 

#### 4. Git & GitHub
- Initialize Git repository
- Meaningful commit history
- `.gitignore` excludes logs and backups
- Push to GitHub
- README includes deploy, backup, and rollback instructions

## Grading Summary (100 Points)
- Linux fundamentals: 20
- POSIX shell scripting: 40
- NGINX configuration: 20
- Git & GitHub usage: 20

