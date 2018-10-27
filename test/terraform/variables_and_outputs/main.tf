provider "local" {
  version = "~> 1.1"
}

resource "local_file" "from_configuration_variable" {
  content  = "${var.local_file_content_from_configuration_variable}"
  filename = "${path.module}/configuration_variable.txt"
}

resource "local_file" "from_variable_file" {
  content  = "${var.local_file_content_from_variable_file}"
  filename = "${path.module}/variable_file.txt"
}
