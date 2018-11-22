provider "local" {
  version = "~> 1.1"
}

resource "local_file" "variable" {
  content  = "${var.local_file_content_from_variable}"
  filename = "${path.module}/variable.txt"
}

resource "local_file" "variable_file" {
  content  = "${var.local_file_content_from_variable_file}"
  filename = "${path.module}/variable_file.txt"
}
