variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "zone_id" {
  description = "Zone ID of the domain"
  type        = string
}

variable "ssh_hostname" {
  description = "Public hostname for SSH, one level deep, e.g. ssh-vps1.example.com"
  type        = string
}

variable "admin_email" {
  description = "The only email allowed through Cloudflare Access"
  type        = string
}
