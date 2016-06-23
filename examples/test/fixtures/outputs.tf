output "contrived_hostnames" {
  value = "${module.example.public_dns_1}"
}

output "other_hostname" {
  value = "${module.example.public_ip_2}"
}
