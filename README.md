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
ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk_vps                            # hardware-backed key
cp authorized_keys.local.example authorized_keys.local                          # add your .pub keys
cp ansible/inventory/hosts.local.yml.example ansible/inventory/hosts.local.yml  # fill in
```

## New VPS

Run from `ansible/`:

```bash
ssh-keygen -R <ip>                                              # forget old host key
ssh-copy-id -i ~/.ssh/id_ed25519_sk_vps.pub root@<ip>           # root's key, once
ansible-playbook playbooks/bootstrap.yml -e ansible_user=root   # harden
ansible-playbook playbooks/verify.yml -K                        # prove it worked
```

## Later runs

Root login is now disabled, so connect as the admin user:

```bash
ansible-playbook playbooks/bootstrap.yml -K   # e.g. after adding a key
```

## Cloudflare Tunnel

API token permissions: Account → Cloudflare Tunnel Edit, Account → Access: Apps and Policies Edit, Zone → DNS Edit.

From `terraform/`:

```bash
cp terraform.tfvars.example terraform.tfvars                # fill in
echo 'CLOUDFLARE_API_TOKEN=...' > cloudflare.local.env && chmod 600 cloudflare.local.env
set -a; source cloudflare.local.env; set +a
terraform init && terraform apply
```

From `ansible/`:

```bash
ansible-playbook playbooks/tunnel.yml -K   # installs cloudflared with the token from Terraform
```

Connect:

```bash
ssh -o ProxyCommand="cloudflared access ssh --hostname %h" \
    -i ~/.ssh/id_ed25519_sk_vps -o IdentitiesOnly=yes <admin>@<ssh_hostname>
```
