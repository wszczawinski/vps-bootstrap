# vps-bootstrap

VPS setup with a Cloudflare Tunnel.

Ansible hardens a fresh Ubuntu 24.04 server and Terraform creates the tunnel, so SSH works only through Cloudflare: admin user with a hardware SSH key, no root or password login, no open inbound ports. No secrets in the repo; real values live in git-ignored `*.local` files.

## Prerequisites

- Ansible with `passlib` (Homebrew's `ansible` includes it), OpenSSH 8.2+
- Terraform, `cloudflared`
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
terraform init && terraform apply               # tunnel, DNS record, Access app
```

### 3. Server

From `ansible/`:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_sk_vps.pub root@<ip>                 # last use of the root password
ansible -i inventory/bootstrap.local.yml all -m ping
ansible-playbook -i inventory/bootstrap.local.yml playbooks/site.yml  # asks the admin password twice
ssh -o ProxyCommand="cloudflared access ssh --hostname %h" \
    -i ~/.ssh/id_ed25519_sk_vps -o IdentitiesOnly=yes <admin>@<ssh_hostname>  # accept host key, then exit
ansible-playbook playbooks/site.yml -K                                # through the tunnel, expect changed=0
```

`site.yml` installs the tunnel, upgrades packages (can take minutes with no output), hardens SSH, then closes SSH on the IP. After this, SSH works only through the tunnel. Ansible cannot accept a new host key, so the manual `ssh` above does it once.

### 4. Verify

From `ansible/`:

```bash
ansible-playbook playbooks/verify.yml -K
```

If it warns that a reboot is required: `sudo reboot` through the tunnel, then run it again.

## Later runs

From `ansible/`, through the tunnel:

```bash
ansible-playbook playbooks/site.yml -K
ansible-playbook playbooks/verify.yml -K
```

Touch the security key when it blinks. unattended-upgrades installs security and cloudflared updates.

## Reinstall

Terraform is not needed. Forget the old host keys, then repeat steps 3 and 4:

```bash
ssh-keygen -R <ip>
ssh-keygen -R <ssh_hostname>
```

## Locked out

Log in through the provider's rescue console as root and run `ufw allow OpenSSH`.
