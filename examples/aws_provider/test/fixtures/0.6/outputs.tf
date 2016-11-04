output "contrived_hostnames" {
  value = "${module.example.example_1_public_dns}"
}

output "different_host_address" {
  value = "${module.example.example_2_public_ip}"
}
