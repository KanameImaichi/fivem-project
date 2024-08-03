# terraform {
#   required_version = "1.9.2"
#
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "4.73.1"
#     }
#     google-beta = {
#       source  = "hashicorp/google-beta"
#       version = "4.73.1"
#     }
#   }
#
#   backend "gcs" {
#     bucket = "commet-terraform-state"
#     prefix = "dev/k8s"
#   }
#
# }
#
# provider "google" {
#   project = var.project_id
# }
#
# provider "google-beta" {
#   project = var.project_id
# }