terraform {
  required_version = ">= 0.11.4, < 0.12.0"

  backend "local" {}
}

provider "docker" {
  host    = "unix://localhost/var/run/docker.sock"
  version = "~> 0.1"
}

provider "local" {
  version = "~> 1.0"
}

data "docker_registry_image" "ubuntu" {
  name = "${var.docker_registry_image_name}"
}

resource "docker_image" "ubuntu" {
  keep_locally  = true
  name          = "${data.docker_registry_image.ubuntu.name}"
  pull_triggers = ["${data.docker_registry_image.ubuntu.sha256_digest}"]
}

resource "docker_container" "ubuntu" {
  image    = "${docker_image.ubuntu.name}"
  must_run = true
  name     = "${var.docker_container_name}"
}
