provider "local" {
  version = "~> 1.1"
}

resource "local_file" "static_file" {
  content  = "abc"
  filename = "${path.module}/static_file.txt"
}
