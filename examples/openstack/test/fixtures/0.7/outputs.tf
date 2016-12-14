output "masters_ips" {
  value = "${module.default.master_0_public_ip}"
}
output "workers_ips" {
  value = "${module.default.workers_public_ips}"
}
