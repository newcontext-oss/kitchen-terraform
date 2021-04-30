terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 1.4"
    }
  }

  required_version = ">= 0.15.0, < 1.1.0"
}
