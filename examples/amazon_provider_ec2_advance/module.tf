# Terraform Configuration

terraform {
  # The configuration is restricted to Terraform versions supported by Kitchen-Terraform
  required_version = ">= 0.10.2, < 0.12.0"
}

# Input Variable Configuration

variable "instances_ami" {
  description = "The Amazon Machine Image (AMI) to use for the AWS EC2 instances"
  type        = "string"
}

variable "key_pair_public_key" {
  description = "The public key material to use for SSH authentication with the instances"
  type        = "string"
}

variable "subnet_availability_zone" {
  description = "The isolated, regional location in which to place the subnet"
  type        = "string"
}

# Provider Configuration

provider "aws" {
  version = "~> 0.1"
}

provider "random" {
  version = "~> 1.0"
}

# Resource Configuration

# These aws_instances will be targeted with the operating_system control and the reachable_other_host control.
resource "aws_instance" "remote_group" {
  ami                    = "${var.instances_ami}"
  count                  = 2
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.extensive_suite_tutorial.key_name}"
  subnet_id              = "${aws_subnet.extensive_suite_tutorial.id}"
  vpc_security_group_ids = ["${aws_security_group.extensive_suite_tutorial.id}"]

  tags {
    Name      = "kitchen-terraform-test-target-${count.index}"
    Terraform = "true"
  }
}

# The reachable_other_host control will attempt to connect to this aws_instance from each of the remote_group
# aws_instances which will verify the configuration of the associated aws_security_group.
resource "aws_instance" "reachable_other_host" {
  ami                         = "${var.instances_ami}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.extensive_suite_tutorial.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.extensive_suite_tutorial.id}"]
  subnet_id                   = "${aws_subnet.extensive_suite_tutorial.id}"

  tags {
    Name      = "kitchen-terraform-reachable-other-host"
    Terraform = "true"
  }
}

resource "aws_key_pair" "extensive_suite_tutorial" {
  key_name   = "kitchen-terraform-extensive_suite_tutorial-${random_string.key_name}"
  public_key = "${var.key_pair_public_key}"
}

resource "random_string" "key_name" {
  length  = 9
  special = false
}

resource "aws_security_group" "extensive_suite_tutorial" {
  description = "Allow all inbound traffic"
  name        = "kitchen-terraform-extensive_suite_tutorial"
  vpc_id      = "${aws_vpc.extensive_suite_tutorial.id}"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags {
    Name      = "kitchen-terraform-extensive_suite_tutorial"
    Terraform = "true"
  }
}

resource "aws_subnet" "extensive_suite_tutorial" {
  availability_zone       = "${var.subnet_availability_zone}"
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = "${aws_vpc.extensive_suite_tutorial.id}"

  tags {
    Name = "kitchen_terraform_extensive_suite_tutorial"
  }
}

resource "aws_route_table_association" "extensive_suite_tutorial" {
  subnet_id      = "${aws_subnet.extensive_suite_tutorial.id}"
  route_table_id = "${aws_route_table.extensive_suite_tutorial.id}"
}

resource "aws_route_table" "extensive_suite_tutorial" {
  vpc_id = "${aws_vpc.extensive_suite_tutorial.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.extensive_suite_tutorial.id}"
  }

  tags {
    Name = "kitchen_terraform_extensive_suite_tutorial"
  }
}

resource "aws_vpc" "extensive_suite_tutorial" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    Name = "kitchen_terraform_extensive_suite_tutorial"
  }
}

# Output Configuration

output "reachable_other_host_id" {
  description = "The ID of the reachable_other_host instance"
  value       = "${aws_instance.reachable_other_host.id}"
}

output "remote_group_public_dns" {
  description = "The list of public DNS names assigned to the remote_group instances"
  value       = ["${aws_instance.remote_group.*.public_dns}"]
}
