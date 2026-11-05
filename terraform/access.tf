resource "cloudflare_zero_trust_access_policy" "admin_only" {
  account_id       = var.account_id
  name             = "Admin only"
  decision         = "allow"
  session_duration = "24h"

  include = [
    { email = { email = var.admin_email } },
  ]
}

resource "cloudflare_zero_trust_access_application" "ssh" {
  account_id       = var.account_id
  name             = "SSH vps1"
  type             = "self_hosted"
  domain           = var.ssh_hostname
  session_duration = "24h"

  destinations = [
    { type = "public", uri = var.ssh_hostname },
  ]

  policies = [
    { id = cloudflare_zero_trust_access_policy.admin_only.id, precedence = 1 },
  ]
}

resource "cloudflare_zero_trust_access_application" "dokploy" {
  account_id       = var.account_id
  name             = "Dokploy vps1"
  type             = "self_hosted"
  domain           = var.dokploy_hostname
  session_duration = "24h"

  destinations = [
    { type = "public", uri = var.dokploy_hostname },
  ]

  policies = [
    { id = cloudflare_zero_trust_access_policy.admin_only.id, precedence = 1 },
  ]
}
