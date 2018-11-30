provider "local" {
  version = "~> 1.1"
}

resource "local_file" "string" {
  content  = "${var.string}"
  filename = "${path.module}/string.txt"
}

resource "local_file" "map" {
  content = "${var.map["key"]}"
  filename = "${path.module}/map.txt"
}

resource "local_file" "list" {
  content = "${join("; ", var.list)}"
  filename = "${path.module}/list.txt"
}

resource "local_file" "variable_file" {
  content  = "${var.local_file_content_from_variable_file}"
  filename = "${path.module}/variable_file.txt"
}
