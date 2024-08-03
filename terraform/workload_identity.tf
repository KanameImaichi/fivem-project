# Wrokload Identity for GHA.
resource "google_iam_workload_identity_pool" "github_actions" {

  provider = google-beta
  workload_identity_pool_id = "github-action-deploy-pool"
  # If pool has same id exists in the project, you need to change id to another name.
  project  = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {

  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "github-actions-provider"
  project                            = var.project_id
  attribute_condition                = <<-EOT
  attribute.repository == "${var.repository_organization_name}/${var.repository_name}"
  EOT
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.aud"        = "assertion.aud"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# # Add workload identity user role to the service account.
resource "google_service_account_iam_member" "workload_identity_account_iam" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${var.repository_organization_name}/${var.repository_name}"
}

resource "google_iam_workload_identity_pool" "github_actions_infra" {

  provider = google-beta
  workload_identity_pool_id = "github-action-deploy-pool-infra"
  # If pool has same id exists in the project, you need to change id to another name.
  project  = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github_actions_infra" {

  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_infra.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider-infra"
  display_name                       = "github-actions-provider-infra"
  project                            = var.project_id
  attribute_condition                = <<-EOT
  attribute.repository == "${var.repository_organization_name_infra}/${var.repository_name_infra}"
  EOT
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.aud"        = "assertion.aud"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# # Add workload identity user role to the service account.
resource "google_service_account_iam_member" "workload_identity_account_iam_infra" {
  service_account_id = google_service_account.github_actions_builder.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions_infra.name}/attribute.repository/${var.repository_organization_name_infra}/${var.repository_name_infra}"
}