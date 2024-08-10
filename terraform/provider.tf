terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.73.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.73.1"
    }
  }
  backend "gcs" {
    bucket = "commet-terraform"
    prefix = "dev/k8s"
  }
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

provider "cloudflare" {}

# https://docs.github.com/ja/actions/security-guides/automatic-token-authentication
provider "github" {
  owner = local.github_org_name
}

variable "onp_k8s_server_url" {
  description = "URL at which k8s server is exposed"
  type        = string
  sensitive   = true
}

variable "onp_k8s_kubeconfig" {
  description = "On-premise cluster's kubeconfig.yaml content"
  type        = string
  sensitive   = true
}

# オンプレクラスタの kubeconfig.yaml は、cluster CA certificate、client certificate、client keyをそれぞれ
#  - clusters[?].cluster.certificate-authority-data に
#  - users[?].user.client-certificate-data に
#  - users[?].user.client-key-data に
# base64で保持している。

locals {
  onp_kubernetes_cluster_ca_certificate = base64decode(yamldecode(var.onp_k8s_kubeconfig).clusters[0].cluster.certificate-authority-data)
  onp_kubernetes_client_certificate     = base64decode(yamldecode(var.onp_k8s_kubeconfig).users[0].user.client-certificate-data)
  onp_kubernetes_client_key             = base64decode(yamldecode(var.onp_k8s_kubeconfig).users[0].user.client-key-data)
}

provider "kubernetes" {
  host                   = var.onp_k8s_server_url
  cluster_ca_certificate = local.onp_kubernetes_cluster_ca_certificate
  client_certificate     = local.onp_kubernetes_client_certificate
  client_key             = local.onp_kubernetes_client_key
}
