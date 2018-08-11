terraform {
  required_version = ">= 0.11.4, < 0.12.0"

  backend "local" {}
}

provider "docker" {
  host    = "unix://localhost/var/run/docker.sock"
  version = "~> 1.0"
}

provider "local" {
  version = "~> 1.1"
}

data "docker_registry_image" "ubuntu" {
  name = "rastasheep/ubuntu-sshd:latest"
}

resource "docker_image" "ubuntu" {
  keep_locally  = true
  name          = "${data.docker_registry_image.ubuntu.name}"
  pull_triggers = ["${data.docker_registry_image.ubuntu.sha256_digest}"]
}

resource "docker_container" "ubuntu" {
  image    = "${docker_image.ubuntu.name}"
  must_run = true
  name     = "ubuntu_container"
}
