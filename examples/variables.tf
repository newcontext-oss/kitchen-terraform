variable "access_key" {}

variable "amis" {
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
  }
}

variable "public_key_pathname" {
  type = "string"
}

variable "region" {
  default = "us-east-1"
}

variable "secret_key" {
  type = "string"
}

variable "user" {
  type = "string"
}
