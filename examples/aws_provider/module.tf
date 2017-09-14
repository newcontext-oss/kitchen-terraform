variable "instances_ami" {
  description = "The AMI of the instances"
  type        = "string"
}

variable "key_pair_public_key" {
  description = "The public key of the key pair"
  type        = "string"
}

variable "provider_region" {
  description = "The geographic area in which the provider will place resources"
  type        = "string"
}

variable "subnet_availability_zone" {
  description = "The isolated, regional location in which to place the subnet"
  type        = "string"
}

provider "aws" {
  region  = "${var.provider_region}"
  version = "~> 0.1"
}

resource "aws_vpc" "example" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    Name = "kitchen_terraform_example"
  }
}

resource "aws_subnet" "example" {
  availability_zone       = "${var.subnet_availability_zone}"
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = "${aws_vpc.example.id}"

  tags {
    Name = "kitchen_terraform_example"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = "${aws_vpc.example.id}"

  tags {
    Name = "kitchen_terraform_example"
  }
}

resource "aws_route_table" "example" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.example.id}"
  }

  tags {
    Name = "kitchen_terraform_example"
  }
}

resource "aws_route_table_association" "example" {
  subnet_id      = "${aws_subnet.example.id}"
  route_table_id = "${aws_route_table.example.id}"
}

resource "aws_security_group" "example" {
  description = "Allow all inbound traffic"
  name        = "kitchen-terraform-example"
  vpc_id      = "${aws_vpc.example.id}"

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
    Name      = "kitchen-terraform-example"
    Terraform = "true"
  }
}

resource "aws_key_pair" "example" {
  key_name   = "kitchen-terraform-example"
  public_key = "${var.key_pair_public_key}"
}

resource "aws_instance" "reachable_other_host" {
  ami                         = "${var.instances_ami}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.example.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.example.id}"]
  subnet_id                   = "${aws_subnet.example.id}"

  tags {
    Name      = "kitchen-terraform-reachable-other-host"
    Terraform = "true"
  }
}

resource "aws_instance" "test_target" {
  ami                    = "${var.instances_ami}"
  count                  = 2
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.example.key_name}"
  subnet_id              = "${aws_subnet.example.id}"
  vpc_security_group_ids = ["${aws_security_group.example.id}"]

  tags {
    Name      = "kitchen-terraform-test-target-${count.index}"
    Terraform = "true"
  }
}

output "reachable_other_host_public_ip" {
  description = "The public IP address of the reachable_other_host instance"
  value       = "${aws_instance.reachable_other_host.public_ip}"
}

output "security_group" {
  description = "The name of the security group"
  value       = "${aws_security_group.example.name}"
}

output "test_target_public_dns" {
  description = "The list of public DNS names assigned to the test_target instances"
  value       = ["${aws_instance.test_target.*.public_dns}"]
}
