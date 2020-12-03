# Copyright 2016-2019 New Context, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
  }
  # because the docker provider needs the above for TF version 0.13+, we must restrict this one,
  # because the syntax cannot be compatible
  required_version = ">= 0.13, < 0.15.0"
}
provider "docker" {
  #version = "1.1.1"
  version = "2.7.2"
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
    content = "${file("${path.cwd}/id_ed25519.pub")}"
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
    content = "${file("${path.cwd}/id_ed25519.pub")}"
    file    = "/root/.ssh/authorized_keys"
  }
}
