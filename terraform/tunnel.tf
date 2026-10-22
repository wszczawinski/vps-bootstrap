resource "cloudflare_zero_trust_tunnel_cloudflared" "vps1" {
  account_id = var.account_id
  name       = "vps1"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "vps1" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.vps1.id

  config = {
    ingress = [
      {
        hostname = var.ssh_hostname
        service  = "ssh://localhost:22"
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "vps1" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.vps1.id
}
