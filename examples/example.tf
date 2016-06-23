provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_security_group" "kitchen_terraform_example" {
  name = "kitchen-terraform-example-${var.user}"
  description = "Allow all inbound traffic"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

  tags {
    Name = "kitchen-terraform-example-${var.user}"
    Terraform = "true"
  }
}

resource "aws_key_pair" "kitchen_terraform_example" {
  key_name = "kitchen-terraform-example-${var.user}"
  public_key = "${file("${var.public_key_pathname}")}"
}

resource "aws_instance" "kitchen_terraform_example_1" {
  count = 2

  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.kitchen_terraform_example.key_name}"
  security_groups = ["${aws_security_group.kitchen_terraform_example.name}"]

  tags {
    Name = "kitchen-terraform-example-1-${var.user}-${count.index}"
    Terraform = "true"
  }
}

resource "aws_instance" "kitchen_terraform_example_2" {
  ami = "${lookup(var.amis, var.region)}"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.kitchen_terraform_example.key_name}"
  security_groups = ["${aws_security_group.kitchen_terraform_example.name}"]

  tags {
    Name = "kitchen-terraform-example-2-${var.user}"
    Terraform = "true"
  }
}
