# variable "project_id" {
#   type    = string
#   default = "scientific-base-418013"
# }
#
# variable "region" {
#   type    = string
#   default = "asia-northeast1"
# }
#
# variable "env" {
#   type    = string
#   default = "dev"
#
# }
#
# # ------------ Workload Identity (GHA) ------------
# variable "repository_organization_name" {
#   type    = string
#   default = "KanameImaichi"
# }
#
# variable "repository_name" {
#   type    = string
#   default = "fivem-server-list"
# }
#
# variable "repository_organization_name_infra" {
#   type    = string
#   default = "KanameImaichi"
# }
#
# variable "repository_name_infra" {
#   type    = string
#   default = "fivem-project"
# }
#
# variable "iam_roles" {
#   type = list(string)
#   default = [
#     "roles/secretmanager.secretAccessor"
#   ]
# }
#
# # Roles for service account which will be used to deploy Cloud Run by GHA.
# variable "github_actions_roles" {
#   type = list(string)
#   default = [
#     "roles/run.admin",
#     "roles/storage.admin",
#     "roles/storage.objectAdmin",
#     "roles/iam.serviceAccountUser",
#     "roles/artifactregistry.writer",
#     "roles/secretmanager.secretAccessor"
#   ]
# }