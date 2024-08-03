# # シークレットの値をローカル変数に格納
# locals {
#   cloudflare_sso_github_client_id = jsondecode(data.google_secret_manager_secret_version.cloudflare_sso_github_client_id.secret_data)
#   cloudflare_sso_github_client_secret = jsondecode(data.google_secret_manager_secret_version.cloudflare_sso_github_client_secret.secret_data)
# }
#
# resource "cloudflare_access_identity_provider" "github_sso" {
#   zone_id = local.cloudflare_zone_id
#   name    = "GitHub OAuth"
#   type    = "github"
#   config {
#     client_id     = local.cloudflare_sso_github_client_id
#     client_secret = local.cloudflare_sso_github_client_secret
#   }
# }
