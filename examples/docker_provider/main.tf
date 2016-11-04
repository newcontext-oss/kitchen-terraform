provider "docker" {
  host = "${var.docker_host}"
}

data "docker_registry_image" "chef_client" {
  name = "errygg/chef-client"
}

resource "docker_image" "chef_client" {
  name = "${data.docker_registry_image.chef_client.name}"
  pull_trigger = "${data.docker_registry_image.chef_client.sha256_digest}"
  keep_locally = true
}

resource "docker_container" "chef_client" {
  image = "${data.docker_registry_image.chef_client.name}"
  name = "chef_client"
  #command = [ "chef-client", "-z" ]
  ports {
    internal = 22
    external = 2222
  }
}
