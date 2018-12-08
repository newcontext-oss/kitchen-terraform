provider "docker" {
  host    = "unix://localhost/var/run/docker.sock"
  version = "~> 1.1"
}

resource "docker_image" "eg_sshd" {
  keep_locally = true
  name         = "eg_sshd"
}

resource "docker_container" "host" {
  image    = "${docker_image.eg_sshd.name}"
  must_run = true
  name     = "host"

  ports {
    external = 2222
    internal = 22
  }
}
