variable "access_key" {
  type        = "string"
  description = "AWS access key ID"
}

variable "public_key_pathname" {
  type        = "string"
  description = "Pathname of SSH public key"
}

variable "region" {
  type        = "string"
  description = "AWS region"
  default     = "us-east-1"
}

variable "secret_key" {
  type        = "string"
  description = "AWS secret access key"
}
