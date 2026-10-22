resource "cloudflare_dns_record" "ssh" {
  zone_id = var.zone_id
  name    = var.ssh_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.vps1.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
