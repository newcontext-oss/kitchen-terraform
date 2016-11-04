output "example_1_public_dns" {
  value = "${join(",", aws_instance.kitchen_terraform_example_1.*.public_dns)}"
}

output "example_2_public_ip" {
  value = "${aws_instance.kitchen_terraform_example_2.public_ip}"
}
