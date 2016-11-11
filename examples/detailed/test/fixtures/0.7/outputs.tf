output "contrived_hostnames" {
  value = ["${split(",", module.example.example_1_public_dns)}"]
}

output "other_host_address" {
  value = "${module.example.example_2_public_ip}"
}
