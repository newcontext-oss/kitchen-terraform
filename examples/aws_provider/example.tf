provider "aws" {
  region     = "${var.region}"
}

resource "aws_vpc" "kitchen_terraform_example" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    Name = "kitchen_terraform_example"
  }
}

resource "aws_subnet" "kitchen_terraform_example_1b" {
  vpc_id = "${aws_vpc.kitchen_terraform_example.id}"

  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags {
    Name = "kitchen_terraform_example_1b"
  }
}

resource "aws_internet_gateway" "kitchen_terraform_example_igw" {
  vpc_id = "${aws_vpc.kitchen_terraform_example.id}"

  tags {
    Name = "kitchen_terraform_example_igw"
  }
}

resource "aws_route_table" "kitchen_terraform_example_rt" {
  vpc_id = "${aws_vpc.kitchen_terraform_example.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kitchen_terraform_example_igw.id}"
  }

  tags {
    Name = "kitchen_terraform_example_rt"
  }
}

resource "aws_route_table_association" "us-east-1b-public" {
  subnet_id      = "${aws_subnet.kitchen_terraform_example_1b.id}"
  route_table_id = "${aws_route_table.kitchen_terraform_example_rt.id}"
}

resource "aws_security_group" "kitchen_terraform_example" {
  name        = "kitchen-terraform-example"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.kitchen_terraform_example.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  egress {
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

resource "aws_key_pair" "kitchen_terraform_example" {
  key_name   = "kitchen-terraform-example"
  public_key = "${file("${var.public_key_pathname}")}"
}

resource "aws_instance" "kitchen_terraform_example_1" {
  count = 2

  ami                    = "${lookup(var.amis, var.region)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.kitchen_terraform_example.key_name}"
  vpc_security_group_ids = ["${aws_security_group.kitchen_terraform_example.id}"]
  subnet_id              = "${aws_subnet.kitchen_terraform_example_1b.id}"

  tags {
    Name      = "kitchen-terraform-example-1-${count.index}"
    Terraform = "true"
  }
}

resource "aws_instance" "kitchen_terraform_example_2" {
  ami                         = "${lookup(var.amis, var.region)}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.kitchen_terraform_example.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.kitchen_terraform_example.id}"]
  subnet_id                   = "${aws_subnet.kitchen_terraform_example_1b.id}"

  tags {
    Name      = "kitchen-terraform-example-2"
    Terraform = "true"
  }
}
