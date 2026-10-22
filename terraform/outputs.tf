output "tunnel_token" {
  description = "Token cloudflared uses to run the vps1 tunnel"
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.vps1.token
  sensitive   = true
}
