output "contrived_hostnames" {
  value = "${join(",", aws_instance.kitchen_terraform_example_1.*.public_dns)}"
}

output "different_host_address" {
  value = "${aws_instance.kitchen_terraform_example_2.public_ip}"
}
