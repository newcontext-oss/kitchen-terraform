provider "docker" {
  version = "~> 1.1"
}

data "docker_registry_image" "ubuntu_sshd" {
  name = "rastasheep/ubuntu-sshd:latest"
}

resource "docker_network" "hosts" {
  ipam_config {
    gateway = "172.21.0.1"
    subnet  = "172.21.0.0/16"
  }

  name = "hosts"
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

  networks_advanced {
    ipv4_address = "172.21.0.2"
    name         = "${docker_network.hosts.name}"
  }

  ports {
    external = 2222
    internal = 22
  }

  upload {
    content = "${file("${path.module}/id_ed25519.pub")}"
    file    = "/root/.ssh/authorized_keys"
  }
}

resource "docker_container" "bastion_host" {
  image    = "${docker_image.ubuntu_sshd.name}"
  must_run = true
  name     = "bastion-host"

  networks_advanced {
    ipv4_address = "172.21.0.3"
    name         = "${docker_network.hosts.name}"
  }

  ports {
    external = 2223
    internal = 22
  }

  upload {
    content = "${file("${path.module}/id_ed25519.pub")}"
    file    = "/root/.ssh/authorized_keys"
  }
}
