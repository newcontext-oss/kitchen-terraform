provider "docker" {
  host    = "unix://127.0.0.1/var/run/docker.sock"
  version = "~> 1.1"
}

data "docker_registry_image" "ubuntu_sshd" {
  name = "rastasheep/ubuntu-sshd:latest"
}

resource "docker_image" "ubuntu_sshd" {
  keep_locally  = true
  name          = "${data.docker_registry_image.ubuntu_sshd.name}"
  pull_triggers = ["${data.docker_registry_image.ubuntu_sshd.sha256_digest}"]
}

resource "docker_container" "host" {
  image    = "${docker_image.ubuntu_sshd.name}"
  must_run = true
  name     = "host"

  ports {
    external = 2222
    internal = 22
  }

  upload {
    content = "${file("${path.module}/id_ed25519.pub")}"
    file    = "/root/.ssh/authorized_keys"
  }
}
