# Terraformで利用するシークレット
resource "google_secret_manager_secret" "terraform_secrets" {
  secret_id = "secret"
  replication {
    automatic = true
  }
}

# シークレットから最新バージョンを取得する設定
data "google_secret_manager_secret_version" "gcp_secrets" {
  secret  = google_secret_manager_secret.terraform_secrets.id
  version = "latest"
}

# シークレットの値をローカル変数に格納
locals {
  cloudflare_sso_github_client_id     = jsondecode(data.google_secret_manager_secret_version.gcp_secrets.secret_data)["cloudflare_sso_github_client_id"]
  cloudflare_sso_github_client_secret = jsondecode(data.google_secret_manager_secret_version.gcp_secrets.secret_data)["cloudflare_sso_github_client_secret"]
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
