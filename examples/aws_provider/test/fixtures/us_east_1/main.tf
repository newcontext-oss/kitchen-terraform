terraform {
  required_version = "~> 0.10.2"
}

variable "public_key_material" {
  description = "The public key material to use for SSH authentication with the instances"
  type        = "string"
}

module "example" {
  instances_ami            = "ami-1d4e7a66"
  key_pair_public_key      = "${var.public_key_material}"
  provider_region          = "us-east-1"
  source                   = "../../../"
  subnet_availability_zone = "us-east-1b"
}

output "reachable_other_host_public_ip" {
  description = "The public IP address of the reachable_other_host instance"
  value       = "${module.example.reachable_other_host_public_ip}"
}

output "security_group" {
  description = "The name of the security group"
  value       = "${module.example.security_group}"
}

output "terraform_state" {
  description = "The path to the backend state file"
  value       = "${module.example.terraform_state}"
}

output "test_target_public_dns" {
  description = "The list of public DNS names assigned to the test_target instances"
  value       = ["${module.example.test_target_public_dns}"]
}
