provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "ubuntu_test" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids =[aws_security_group.ubuntu_test.id]

  tags = {
    Name = var.instance_name
  }
}

resource "aws_security_group" "ubuntu_test" {
  name        = "ubuntu_test"
  description = "Allow http and https in. Allow everything out"

  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ubuntu_test_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ubuntu_test.id
}

resource "aws_security_group_rule" "ubuntu_test_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ubuntu_test.id
}

resource "aws_security_group_rule" "ubuntu_test_everything_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ubuntu_test.id
}

