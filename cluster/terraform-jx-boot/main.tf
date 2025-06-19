terraform {
  required_version = ">= 1.3.2"
  required_providers {
    helm = {
      version = "<3.0.0"
    }
  }
}
