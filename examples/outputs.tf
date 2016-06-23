output "public_dns_1" {
  value = "${join(",", aws_instance.kitchen_terraform_example_1.*.public_dns)}"
}

output "public_ip_2" {
  value = "${aws_instance.kitchen_terraform_example_2.public_ip}"
}
