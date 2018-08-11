terraform {
  required_version = ">= 0.11.4, < 0.12.0"

  backend "local" {}
}

provider "local" {
  version = "~> 1.1"
}

resource "local_file" "test" {
  content  = "This is a test"
  filename = "${path.module}/test.txt"
}
