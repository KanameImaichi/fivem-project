# Terraformで利用するシークレット
import {
  id = "cloudflare_sso_github_client_id"
  to = google_secret_manager_secret.cloudflare_sso_github_client_id
}
import {
  id = "cloudflare_sso_github_client_secret"
  to = google_secret_manager_secret.cloudflare_sso_github_client_secret
}

resource "google_secret_manager_secret" "cloudflare_sso_github_client_id" {
  secret_id = "cloudflare_sso_github_client_id"
  replication {
    automatic = true
  }
}

data "google_secret_manager_secret_version" "cloudflare_sso_github_client_id" {
  secret  = google_secret_manager_secret.cloudflare_sso_github_client_id.id
  version = "latest"
}

resource "google_secret_manager_secret" "cloudflare_sso_github_client_secret" {
  secret_id = "cloudflare_sso_github_client_secret"
  replication {
    automatic = true
  }
}

data "google_secret_manager_secret_version" "cloudflare_sso_github_client_secret" {
  secret  = google_secret_manager_secret.cloudflare_sso_github_client_secret.id
  version = "latest"
}

# シークレットの値をローカル変数に格納
locals {
  cloudflare_sso_github_client_id = jsondecode(data.google_secret_manager_secret_version.cloudflare_sso_github_client_id.secret_data)
  cloudflare_sso_github_client_secret = jsondecode(data.google_secret_manager_secret_version.cloudflare_sso_github_client_secret.secret_data)
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
