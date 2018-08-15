output "reachable_other_host_ip_address" {
  description = <<EOD
This output is used as an attribute in the reachable_other_host control
EOD

  value = <<EOV
${module.extensive_kitchen_terraform.reachable_other_host_ip_address}
EOV
}

output "static_terraform_output" {
  description = <<EOD
This output is used as an attribute in the inspec_attributes control
EOD

  value = "static terraform output"
}

output "terraform_state" {
  description = "This output is used as an attribute in the state_file control"

  value = <<EOV
${path.cwd}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate
EOV
}

output "remote_group_public_dns" {
  description = "This output is used to obtain targets for InSpec"

  value = ["${module.extensive_kitchen_terraform.remote_group_public_dns}"]
}
