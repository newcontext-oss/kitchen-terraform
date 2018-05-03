# Input Variable Configuration

variable "instances_ami" {
  description = <<EOD
The Amazon Machine Image (AMI) to use for the AWS EC2 instances of the module
EOD

  type = "string"
}

variable "instances_ami_operating_system_name" {
  description = "The name of the operating system within the AMI"
  type        = "string"
}

variable "subnet_availability_zone" {
  description = <<EOD
The isolated, regional location in which to place the subnet of the module
EOD

  type = "string"
}

# Module Configuration

module "extensive_kitchen_terraform" {
  instances_ami = "${var.instances_ami}"

  # The generated key pair will be used to configure SSH authentication
  key_pair_public_key = "${file("${path.module}/../../assets/key_pair.pub")}"

  # The source of the module is the root directory of the Terraform project
  source                   = "../../../"
  subnet_availability_zone = "${var.subnet_availability_zone}"
}

# Output Configuration

# This output is used as an attribute in the operating_system control
output "instances_ami_operating_system_name" {
  description = "The name of the operating system within the AMI"

  value = "${var.instances_ami_operating_system_name}"
}

# This output is used as an attribute in the reachable_other_host control
output "reachable_other_host_id" {
  description = "The ID of the reachable_other_host instance"
  value       = "${module.extensive_kitchen_terraform.reachable_other_host_id}"
}

# This output is used as an attribute in the inspec_attributes control
output "static_terraform_output" {
  description = "A static value"
  value       = "static terraform output"
}

# This output is used as an attribute in the state_file control
output "terraform_state" {
  description = "The path to the Terraform state file"

  value = <<EOV
${path.cwd}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate
EOV
}

# This output is used to obtain targets for InSpec
output "remote_group_public_dns" {
  description = "The list of public DNS names of the remote_group instances"

  value = ["${module.extensive_kitchen_terraform.remote_group_public_dns}"]
}
