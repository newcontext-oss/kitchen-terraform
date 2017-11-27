terraform {
<<<<<<< HEAD
  required_version = ">= 0.10.2, < 0.12.0"

  backend "local" {}
=======
  required_version = "~> 0.10.2"

  backend "local" {
    path = "local.tfstate"
  }
>>>>>>> add back docker provider example
}

provider "docker" {
  host    = "unix://localhost/var/run/docker.sock"
  version = "~> 0.1"
}

<<<<<<< HEAD
provider "local" {
  version = "~> 1.0"
}

=======
>>>>>>> add back docker provider example
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

  ports {
    external = 2222
    internal = 22
  }
}

output "backend_state" {
  description = "The path to the backend state file"
<<<<<<< HEAD
  value       = "${path.module}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
=======
  value       = "${path.module}/local.tfstate"
>>>>>>> add back docker provider example
}

output "hostnames" {
  description = "The hostnames to test"
  value       = ["localhost"]
}
