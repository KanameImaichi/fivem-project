variable "project_id" {
  type    = string
  default = "kubernetes"
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "env" {
  type    = string
  default = "dev"

}

variable "iam_roles" {
  type = list(string)
  default = [
    "roles/secretmanager.secretAccessor"
  ]

}