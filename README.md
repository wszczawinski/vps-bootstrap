# vps-bootstrap

Ansible playbooks that harden a fresh Ubuntu 24.04 VPS: admin user with a hardware SSH key, no root or password login, firewall on. No secrets in the repo; real values live in git-ignored `*.local` files.

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
