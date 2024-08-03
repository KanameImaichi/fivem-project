# resource "google_secret_manager_secret" "cloudflare_sso_github_client_id" {
#   project   = var.project_id
#   secret_id = "cloudflare_sso_github_client_secret"
#
#   replication {
#     automatic = true
#   }
# }
# data "google_secret_manager_secret_version" "cloudflare_sso_github_client_id" {
#   secret  = google_secret_manager_secret.cloudflare_sso_github_client_id.id
#   version = "latest"
# }
#
# resource "google_secret_manager_secret" "cloudflare_sso_github_client_secret" {
#   project   = var.project_id
#   secret_id = "cloudflare_sso_github_client_secret"
#
#   replication {
#     automatic = true
#   }
# }
#
#
# data "google_secret_manager_secret_version" "cloudflare_sso_github_client_secret" {
#   secret  = google_secret_manager_secret.cloudflare_sso_github_client_secret.id
#   version = "latest"
# }