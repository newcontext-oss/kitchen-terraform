output "local_file_content_from_configuration_variable" {
  description = "The content of the local_file provided by a configuration variable"
  value       = "${local_file.from_configuration_variable.content}"
}

output "local_file_content_from_variable_file" {
  description = "The content of the local_file provided by a variable file"
  value       = "${local_file.from_variable_file.content}"
}
