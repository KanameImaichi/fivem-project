resource "random_password" "tunnel_secret" {
  length = 64
}

# Creates a new locally-managed tunnel for the GCP VM.
resource "cloudflare_tunnel" "auto_tunnel" {
  account_id = local.cloudflare_account_id
  name       = "Terraform GCP tunnel"
  secret = base64sha256(random_password.tunnel_secret.result)
}

# Creates the CNAME record that routes http_app.${var.cloudflare_zone} to the tunnel.
resource "cloudflare_record" "http_app" {
  zone_id = local.cloudflare_zone_id
  name    = "argocd"
  content   = cloudflare_tunnel.auto_tunnel.cname
  type    = "CNAME"
  proxied = true
}

# Creates the configuration for the tunnel.
resource "cloudflare_tunnel_config" "auto_tunnel" {
  tunnel_id  = cloudflare_tunnel.auto_tunnel.id
  account_id = local.cloudflare_account_id
  config {
    ingress_rule {
      hostname = cloudflare_record.http_app.hostname
      service  = "https://192.168.0.11:30277"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_access_application" "onp_admin_proxmox" {
  zone_id          = local.cloudflare_zone_id
  name             = "Proxmox administration"
  domain           = "proxmox.onp.admin.${local.root_domain}"
  type             = "self_hosted"
  session_duration = "24h"

  http_only_cookie_attribute = true
}
# シークレットの値をローカル変数に格納
locals {
  cloudflare_sso_github_client_id     = data.google_secret_manager_secret_version.cloudflare_sso_github_client_id.secret_data
  cloudflare_sso_github_client_secret = data.google_secret_manager_secret_version.cloudflare_sso_github_client_secret.secret_data
}

resource "cloudflare_access_identity_provider" "github_sso" {
  zone_id = local.cloudflare_zone_id
  name    = "GitHub OAuth"
  type    = "github"
  config {
    client_id     = local.cloudflare_sso_github_client_id
    client_secret = local.cloudflare_sso_github_client_secret
  }
}

resource "cloudflare_access_policy" "onp_admin_proxmox" {
  application_id = cloudflare_access_application.onp_admin_proxmox.id
  zone_id        = local.cloudflare_zone_id
  name           = "Require to be in a GitHub team to access"
  precedence     = "1"
  decision       = "allow"

#   include {
#     github {
#       name                 = local.github_org_name
#       teams = ["admin-team"]
#       identity_provider_id = cloudflare_access_identity_provider.github_sso.id
#     }
#   }
  include {
    email = ["kaname.imaichi@gmail.com"]
  }
}