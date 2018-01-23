# Input Variable Configuration

variable "instances_ami" {
  description = "The Amazon Machine Image (AMI) to use for the AWS EC2 instances of the module"
  type        = "string"
}

variable "instances_ami_operating_system_name" {
  description = "The name of the operating system within the AMI"
  type        = "string"
}

variable "subnet_availability_zone" {
  description = "The isolated, regional location in which to place the subnet of the module"
  type        = "string"
}

# Module Configuration

module "extensive_kitchen_terraform" {
  instances_ami = "${var.instances_ami}"

  # The generated key pair will be used to configure SSH authentication
  key_pair_public_key = "${file("../../assets/key_pair.pub")}"

  # The source of the module is the root directory of the Terraform project
  source                   = "../../../"
  subnet_availability_zone = "${var.subnet_availability_zone}"
}

# Output Configuration

output "instances_ami_operating_system_name" {
  description = "The name of the operating system within the AMI; used in the operating_system control"
  value       = "${var.instances_ami_operating_system_name}"
}

output "reachable_other_host_id" {
  description = "The ID of the reachable_other_host instance; used in the reachable_other_host control"
  value       = "${module.example.reachable_other_host_id}"
}

output "static_terraform_output" {
  description = "A static value; used in the inspec_attributes control"
  value       = "static terraform output"
}

output "terraform_state" {
  description = "The path to the Terraform state file; used in the state_file control"
  value       = "${path.cwd}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
}

output "remote_group_public_dns" {
  description = "The list of public DNS names assigned to the remote_group instances; used by the remote group"
  value       = ["${module.example.remote_group_public_dns}"]
}
