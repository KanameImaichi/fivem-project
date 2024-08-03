variable "project_id" {
  type    = string
  default = "commet-431413"
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}


locals {
  github_org_name       = "CommetDevTeam"
  cloudflare_account_id = "8ecf8f7b5d3ef7e806492e7a0439305d"
  cloudflare_zone_id    = "1896647049ae7604a5ff04f5c7287f62"
  root_domain           = "commet.jp"
}

#region on-premise k8s access configuration

# variable "onp_k8s_kubeconfig" {
#   description = "On-premise cluster's kubeconfig.yaml content"
#   type        = string
#   sensitive   = true
# }
#
# # オンプレクラスタの kubeconfig.yaml は、cluster CA certificate、client certificate、client keyをそれぞれ
# #  - clusters[?].cluster.certificate-authority-data に
# #  - users[?].user.client-certificate-data に
# #  - users[?].user.client-key-data に
# # base64で保持している。
#
# locals {
#   onp_kubernetes_cluster_ca_certificate = base64decode(yamldecode(var.onp_k8s_kubeconfig).clusters[0].cluster.certificate-authority-data)
#   onp_kubernetes_client_certificate = base64decode(yamldecode(var.onp_k8s_kubeconfig).users[0].user.client-certificate-data)
#   onp_kubernetes_client_key = base64decode(yamldecode(var.onp_k8s_kubeconfig).users[0].user.client-key-data)
# }

variable "env" {
  type    = string
  default = "dev"

}

# ------------ Workload Identity (GHA) ------------
variable "repository_organization_name" {
  type    = string
  default = "KanameImaichi"
}

variable "repository_name" {
  type    = string
  default = "fivem-server-list"
}

variable "repository_organization_name_infra" {
  type    = string
  default = "KanameImaichi"
}

variable "repository_name_infra" {
  type    = string
  default = "fivem-project"
}

variable "iam_roles" {
  type = list(string)
  default = [
    "roles/secretmanager.secretAccessor"
  ]
}

variable "github_actions_roles" {
  type = list(string)
  default = [
    "roles/run.admin",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/secretmanager.secretAccessor"
  ]
}
variable "github_actions_builder_roles" {
  type = list(string)
  default = [
    "roles/run.admin",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/secretmanager.admin",
    "roles/iam.workloadIdentityPoolAdmin"
  ]
}
# Roles for service account which will be used to deploy Cloud Run by GHA.