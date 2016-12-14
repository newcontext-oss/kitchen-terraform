# IP of one specified master vm
output "master_0_public_ip" {
  value = "${openstack_networking_floatingip_v2.master.0.address}"
}
# IPs of all master vms
output "masters_public_ips" {
  value = ["${openstack_networking_floatingip_v2.master.*.address}"]
}
# IP of one specified worker vm
output "worker_0_public_ip" {
  value = "${openstack_networking_floatingip_v2.worker.0.address}"
}
# IPs of all worker vms
output "workers_public_ips" {
  value = ["${openstack_networking_floatingip_v2.worker.*.address}"]
}
