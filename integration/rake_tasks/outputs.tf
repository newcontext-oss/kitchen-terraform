output "backend_state" {
  description = "The path to the backend state file"
  value       = "${path.module}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
}

output "hosts" {
  description = "The hosts to test"
  value       = ["${docker_container.ubuntu.name}"]
}
