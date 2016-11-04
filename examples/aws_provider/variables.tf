variable "access_key" {
  type = "string"
  description = "AWS access key ID"
}

variable "amis" {
  type = "map"
  description = "Map of AWS regions to AMIs"
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
  }
}

variable "public_key_pathname" {
  type = "string"
  description = "Pathname of SSH public key"
}

variable "region" {
  type = "string"
  description = "AWS region"
  default = "us-east-1"
}

variable "secret_key" {
  type = "string"
  description = "AWS secret access key"
}

variable "user" {
  type = "string"
  description = "Username of account running Terraform"
}
