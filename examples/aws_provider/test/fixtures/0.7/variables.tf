variable "public_key_pathname" {
  type        = "string"
  description = "Pathname of SSH public key"
}

variable "region" {
  type        = "string"
  description = "AWS region"
  default     = "us-east-1"
}
