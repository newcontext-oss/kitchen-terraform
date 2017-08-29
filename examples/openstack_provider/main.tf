terraform {
  required_version = "~> 0.10.2"
}

variable "compute_instances_network_name" {
  description = "The human-readable name of the network of the compute instances"
  type        = "string"
}

variable "networking_floatingips_pool" {
  description = "The name of the pool from which to obtain the floating IP addresses"
  type        = "string"
}

variable "provider_auth_url" {
  description = "The identity authentication URL"
  type        = "string"
}

variable "provider_password" {
  description = "The password to login with"
  type        = "string"
}

variable "provider_region" {
  description = "The cloud region to use"
  type        = "string"
}

variable "provider_tenant_name" {
  description = "The name of the tenant to login with"
  type        = "string"
}

variable "provider_user_name" {
  description = "The user ID to login with"
  type        = "string"
}

provider "openstack" {
  auth_url    = "${var.provider_auth_url}"
  password    = "${var.provider_password}"
  region      = "${var.provider_region}"
  tenant_name = "${var.provider_tenant_name}"
  user_name   = "${var.provider_user_name}"
}

resource "openstack_compute_keypair_v2" "kitchen-terraform" {
  name       = "kitchen-terraform-example"
  public_key = "${file("./dummy_keypair/cloud.key.pub")}"
}

resource "openstack_networking_floatingip_v2" "master" {
  pool = "${var.networking_floatingips_pool}"
}

resource "openstack_compute_instance_v2" "master" {
  flavor_name = "v.c1.m1024.d5.e0"
  floating_ip = "${element(openstack_networking_floatingip_v2.master.*.address, 0)}"
  image_name  = "ubuntu-16.04"
  key_pair    = "${openstack_compute_keypair_v2.kitchen-terraform.name}"
  name        = "kitchen-terraform-example-master"

  connection {
    host        = "${self.floating_ip}"
    private_key = "${file("./dummy/cloud.key")}"
    type        = "ssh"
    user        = "ubuntu"
  }

  metadata = {
    ssh_user = "ubuntu"
  }

  network {
    name = "${var.compute_instances_network_name}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get install --no-install-recommends --yes nano"]
  }
}

resource "openstack_networking_floatingip_v2" "workers" {
  count = 2
  pool  = "${var.networking_floatingips_pool}"
}

resource "openstack_compute_instance_v2" "worker" {
  count       = 2
  flavor_name = "v.c1.m1024.d5.e0"
  floating_ip = "${element(openstack_networking_floatingip_v2.workers.*.address, count.index)}"
  image_name  = "ubuntu-16.04"
  key_pair    = "${openstack_compute_keypair_v2.kitchen-terraform.name}"
  name        = "kitchen-terraform-example-worker-${count.index+1}"

  connection {
    host        = "${self.floating_ip}"
    private_key = "${file("./dummy/cloud.key")}"
    type        = "ssh"
    user        = "ubuntu"
  }

  metadata = {
    ssh_user = "ubuntu"
  }

  network {
    name = "${var.compute_instances_network_name}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get install --no-install-recommends --yes curl"]
  }
}

output "master_address" {
  value = "${openstack_networking_floatingip_v2.master.address}"
}

output "workers_addresses" {
  value = ["${openstack_networking_floatingip_v2.workers.*.address}"]
}
