variable "cluster_name" {
  type        = "string"
  description = "Name of vms cluster"
  default     = "kitchen-terraform"
}

variable "masters_count" {
  description = "Number of master vms"
  default     = 1
}

variable "workers_count" {
  description = "Number of worker vms"
  default     = 0
}

variable "openstack_image" {
  type        = "string"
  description = "OpenStack image name for vms"
  default     = "ubuntu-16.04"
}

variable "openstack_flavor" {
  type        = "string"
  description = "OpenStack flavor name for vms"
  default     = "v.c1.m1024.d5.e0"
}

variable "public_key_path" {
  type        = "string"
  description = "Pathname of SSH public key"
  default     = "./dummy_keypair/cloud.key.pub"
}

variable "secret_key_path" {
  type        = "string"
  description = "Pathname of SSH private key"
  default     = "./dummy_keypair/cloud.key"
}

variable "ssh_user_name" {
  type        = "string"
  description = "User name to ssh log as"
  default     = "ubuntu"
}

variable "openstack_tenant_name" {
  type        = "string"
  description = "OpenStack tenant/project"
}

variable "openstack_region" {
  type        = "string"
  description = "OpenStack region"
}

variable "openstack_auth_url" {
  type        = "string"
  description = "OpenStack auth URL"
}

variable "openstack_user_name" {
  type        = "string"
  description = "OpenStack user name"
}

variable "openstack_password" {
  type        = "string"
  description = "OpenStack password"
}

variable "openstack_floatingip_pool" {
  type        = "string"
  description = "Name of OpenStack network to choose floating ip from"
}

variable "openstack_vm_network" {
  type        = "string"
  description = "Name of OpenStack internal network to assign to a vm"
}
