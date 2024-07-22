resource "google_service_account" "eso" {
  project      = var.project_id
  account_id   = "${var.env}-eso"
  display_name = "${var.env}-eso"
}

resource "google_project_iam_member" "eso" {
  for_each = toset(var.iam_roles)
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.eso.email}"
}