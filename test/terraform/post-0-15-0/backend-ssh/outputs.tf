output "bastion_host" {
  description = "The bastion host through which connections must be made."
  value       = "localhost"
}

output "hosts" {
  description = "The hosts to test"
  value       = ["localhost"]
}
