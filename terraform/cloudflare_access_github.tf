resource "cloudflare_access_identity_provider" "github_oauth" {
  zone_id = local.cloudflare_zone_id
  name    = "GitHub OAuth"
  type    = "github"
  config {
    client_id     = local.github_cloudflare_oauth_client_id
    client_secret = local.github_cloudflare_oauth_client_secret
  }
}
