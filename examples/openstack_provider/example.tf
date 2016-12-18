provider "openstack" {
  tenant_name = "${var.openstack_tenant_name}"
  auth_url    = "${var.openstack_auth_url}"
  user_name   = "${var.openstack_user_name}"
  password    = "${var.openstack_password}"
}

resource "openstack_compute_keypair_v2" "kitchen-terraform" {
  name       = "${var.cluster_name}"
  public_key = "${file(var.public_key_path)}"
}

# resources for master VM(s)
resource "openstack_networking_floatingip_v2" "master" {
  count = "${var.masters_count}"
  pool  = "${var.openstack_floatingip_pool}"
}

resource "openstack_compute_instance_v2" "master" {
  name        = "${var.cluster_name}-master-${count.index+1}"
  region      = "${var.openstack_region}"
  count       = "${var.masters_count}"
  image_name  = "${var.openstack_image}"
  flavor_name = "${var.openstack_flavor}"
  key_pair    = "${openstack_compute_keypair_v2.kitchen-terraform.name}"

  network {
    name = "${var.openstack_vm_network}"
  }

  floating_ip = "${element(openstack_networking_floatingip_v2.master.*.address, count.index)}"

  metadata = {
    ssh_user = "${var.ssh_user_name}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_user_name}"
    private_key = "${file(var.secret_key_path)}"
    host        = "${self.floating_ip}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get install --no-install-recommends -y nano"]
  }
}

# resources for worker VM(s)
resource "openstack_networking_floatingip_v2" "worker" {
  count = "${var.workers_count}"
  pool  = "${var.openstack_floatingip_pool}"
}

resource "openstack_compute_instance_v2" "worker" {
  name        = "${var.cluster_name}-worker-${count.index+1}"
  region      = "${var.openstack_region}"
  count       = "${var.workers_count}"
  image_name  = "${var.openstack_image}"
  flavor_name = "${var.openstack_flavor}"
  key_pair    = "${openstack_compute_keypair_v2.kitchen-terraform.name}"

  network {
    name = "${var.openstack_vm_network}"
  }

  floating_ip = "${element(openstack_networking_floatingip_v2.worker.*.address, count.index)}"

  metadata = {
    ssh_user = "${var.ssh_user_name}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_user_name}"
    private_key = "${file(var.secret_key_path)}"
    host        = "${self.floating_ip}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get install --no-install-recommends -y curl"]
  }
}
