terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.11"
    }
  }

  required_version = ">= 0.15, < 1.1.0"
}
