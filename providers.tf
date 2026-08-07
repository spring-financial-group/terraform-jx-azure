terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=3.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=3.2.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "<3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.9.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

provider "kubernetes" {
  host = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(
    module.cluster.ca_certificate,
  )
  client_certificate = base64decode(
    module.cluster.client_certificate,
  )
  client_key = base64decode(
    module.cluster.client_key,
  )
}

provider "helm" {
  kubernetes {
    host = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(
      module.cluster.ca_certificate,
    )
    client_certificate = base64decode(
      module.cluster.client_certificate,
    )
    client_key = base64decode(
      module.cluster.client_key,
    )
  }
}