provider "docker" {
  host = "${var.docker_host}"
}

data "docker_registry_image" "ubuntu" {
  name = "${var.docker_image}"
}

resource "docker_image" "ubuntu" {
  name = "${data.docker_registry_image.ubuntu.name}"
  pull_trigger = "${data.docker_registry_image.ubuntu.sha256_digest}"
  keep_locally = true
}

resource "docker_container" "ubuntu" {
  image = "${data.docker_registry_image.ubuntu.name}"
  name = "ubuntu_container"
  ports {
    internal = 22
    external = 2222
  }
  must_run = true
}
