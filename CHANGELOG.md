# Changelog

## [1.0.0] - 2026-10-30

### 📚 Documentation

- *(readme)* Accept host key and rerun site.yml after a new install
## [0.1.0] - 2026-10-29

### 🚀 Features

- *(ansible)* Add bootstrap and verify playbooks for SSH hardening
- *(terraform)* Add Cloudflare tunnel, DNS and Access for SSH
- *(ansible)* Add cloudflared tunnel playbook
- *(ansible)* Split inventory into bootstrap and tunnel, add site.yml
- *(ansible)* Verify through the tunnel, check cloudflared, sudo and root keys
- *(ansible)* Harden cloudflared service and auto-update it, ignore Terraform local files
- *(ansible)* Set admin password once, upgrade packages, extend verify
- *(ansible)* Close SSH on the public IP once the tunnel is connected

### 🐛 Bug Fixes

- *(ansible)* Restart cloudflared in the background, expose readiness on localhost

### ⚙️ Miscellaneous Tasks

- *(release)* V0.1.0
