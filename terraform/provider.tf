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
# variable "cloudflare-api-token" {
#   sensitive = true
# }
#
# provider "cloudflare" {
#   api_token = var.cloudflare-api-token
# }
provider "cloudflare" {}

# https://docs.github.com/ja/actions/security-guides/automatic-token-authentication
provider "github" {
  owner = local.github_org_name
}

provider "kubernetes" {
  config_path = "./kubeconfig/config"
}

