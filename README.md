# vps-bootstrap

Ansible and Terraform that harden a fresh Ubuntu 24.04 VPS and put SSH behind a Cloudflare Tunnel: admin user with a hardware SSH key, no root or password login, firewall on. No secrets in the repo; real values live in git-ignored `*.local` files.

## Prerequisites

- Ansible and OpenSSH 8.2+
- Terraform and `cloudflared`
- FIDO2 hardware key (e.g. YubiKey)
- Fresh Ubuntu 24.04 VPS
- Domain on Cloudflare with Zero Trust enabled

## One-time setup

```bash
ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk_vps    # hardware-backed key
cp authorized_keys.local.example authorized_keys.local  # add your .pub keys
cp ansible/inventory/bootstrap.local.yml.example ansible/inventory/bootstrap.local.yml  # server IP, as root
cp ansible/inventory/hosts.local.yml.example ansible/inventory/hosts.local.yml          # tunnel hostname, as admin
```

## Cloudflare (once per server)

API token permissions: Account → Cloudflare Tunnel Edit, Account → Access: Apps and Policies Edit, Zone → DNS Edit.

From `terraform/`:

```bash
cp terraform.tfvars.example terraform.tfvars    # fill in
touch cloudflare.local.env && chmod 600 cloudflare.local.env
# add one line with an editor: CLOUDFLARE_API_TOKEN=<token>
set -a; source cloudflare.local.env; set +a
terraform init && terraform apply
```

Creates the tunnel, DNS record and Access app. Survives server reinstalls.

## New VPS

From `ansible/`:

```bash
ssh-keygen -R <ip>                                                   # forget old host key
ssh-copy-id -i ~/.ssh/id_ed25519_sk_vps.pub root@<ip>                # root's key, once
ansible-playbook -i inventory/bootstrap.local.yml playbooks/site.yml # tunnel, then harden
```

`site.yml` installs the tunnel first, while root can still log in, then disables root login.

## Later runs

Through the tunnel, as the admin user:

```bash
ansible-playbook playbooks/site.yml -K
ansible-playbook playbooks/verify.yml -K
```

Manual SSH:

```bash
ssh -o ProxyCommand="cloudflared access ssh --hostname %h" \
    -i ~/.ssh/id_ed25519_sk_vps -o IdentitiesOnly=yes <admin>@<ssh_hostname>
```
