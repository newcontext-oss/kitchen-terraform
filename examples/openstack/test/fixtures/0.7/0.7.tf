module "default" {
  source = "../../../"

  cluster_name = "${var.cluster_name}"
  masters_count = "${var.masters_count}"
  workers_count = "${var.workers_count}"
  openstack_image = "${var.openstack_image}"
  openstack_flavor = "${var.openstack_flavor}"

  public_key_path = "${var.public_key_path}"
  secret_key_path = "${var.secret_key_path}"
  ssh_user_name = "${var.ssh_user_name}"

  openstack_tenant_name = "${var.openstack_tenant_name}"
  openstack_region = "${var.openstack_region}"
  openstack_auth_url = "${var.openstack_auth_url}"
  openstack_user_name = "${var.openstack_user_name}"
  openstack_password = "${var.openstack_password}"

  openstack_floatingip_pool = "${var.openstack_floatingip_pool}"
  openstack_vm_network = "${var.openstack_vm_network}"
}
