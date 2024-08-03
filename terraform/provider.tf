terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
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

# provider "cloudflare" {
#
# }

# https://docs.github.com/ja/actions/security-guides/automatic-token-authentication
provider "github" {
  owner = local.github_org_name
}

# provider "kubernetes" {
#   cluster_ca_certificate = local.onp_kubernetes_cluster_ca_certificate
#   client_certificate     = local.onp_kubernetes_client_certificate
#   client_key             = local.onp_kubernetes_client_key
# }

