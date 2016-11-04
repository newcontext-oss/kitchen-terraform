output "contrived_hostnames" {
  value = ["${split(",", module.example.example_1_public_dns)}"]
}

output "other_host_address" {
  value = "${module.example.example_2_public_ip}"
}

output "security_group" {
  value = "${module.example.security_group}"
}
