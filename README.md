# vps-bootstrap

Ansible and Terraform that harden a fresh Ubuntu 24.04 VPS and put SSH behind a Cloudflare Tunnel: admin user with a hardware SSH key, no root or password login, firewall on. No secrets in the repo; real values live in git-ignored `*.local` files.

## Prerequisites

- Ansible with `passlib` (Homebrew's `ansible` includes it) and OpenSSH 8.2+
- Terraform and `cloudflared`
- FIDO2 hardware key (e.g. YubiKey)
- Fresh Ubuntu 24.04 VPS with root password login
- Domain on Cloudflare with Zero Trust enabled

## New VPS

### 1. Local files (once)

From the repo root:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk_vps    # hardware-backed key
cp authorized_keys.local.example authorized_keys.local  # add your .pub keys
cp ansible/inventory/bootstrap.local.yml.example ansible/inventory/bootstrap.local.yml  # server IP, as root
cp ansible/inventory/hosts.local.yml.example ansible/inventory/hosts.local.yml          # tunnel hostname, as admin
```

### 2. Cloudflare (once per server)

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

### 3. Server

From `ansible/`:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_sk_vps.pub root@<ip>                 # root's key, last use of the root password
ansible -i inventory/bootstrap.local.yml all -m ping                  # reachable as root
ansible-playbook -i inventory/bootstrap.local.yml playbooks/site.yml  # tunnel, then harden; asks admin password twice
```

`site.yml` installs the tunnel first, while root can still log in, then upgrades all packages and disables root login. The first upgrade can take several minutes with no output.

### 4. Verify through the tunnel

From `ansible/`:

```bash
ssh -o ProxyCommand="cloudflared access ssh --hostname %h" \
    -i ~/.ssh/id_ed25519_sk_vps -o IdentitiesOnly=yes <admin>@<ssh_hostname>  # accept host key, then exit
ansible-playbook playbooks/verify.yml -K
```

If `verify.yml` warns that a reboot is required, reboot through the tunnel (`sudo reboot`) and run it again.

## Reinstall

Forget the old host keys, then repeat steps 3 and 4 (Terraform is not needed):

```bash
ssh-keygen -R <ip>
ssh-keygen -R <ssh_hostname>
```

## Later runs

From `ansible/`, through the tunnel, as the admin user:

```bash
ansible-playbook playbooks/site.yml -K
ansible-playbook playbooks/verify.yml -K
```

If `tunnel.yml` changed, run `site.yml` over the IP instead, because restarting cloudflared cuts a run that goes through the tunnel:

```bash
ansible-playbook -i inventory/bootstrap.local.yml playbooks/site.yml -e ansible_user=<admin> -K
```
