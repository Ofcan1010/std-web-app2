terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}

provider "aws" { region = var.region }

data "aws_ami" "ubuntu_arm64" {
  owners      = ["099720109477"]
  most_recent = true
  filter { name = "name"   values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"] }
  filter { name = "state"  values = ["available"] }
  filter { name = "root-device-type" values = ["ebs"] }
  filter { name = "virtualization-type" values = ["hvm"] }
  filter { name = "architecture" values = ["arm64"] }
}

resource "aws_security_group" "std" {
  name        = "std-web-app2-sg"
  description = "SSH from my IP, HTTP/HTTPS from anywhere"
  ingress { from_port=22  to_port=22  protocol="tcp" cidr_blocks=[var.my_ip] }
  ingress { from_port=80  to_port=80  protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=443 to_port=443 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0   to_port=0   protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_instance" "std" {
  ami                    = data.aws_ami.ubuntu_arm64.id
  instance_type          = "t4g.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.std.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = { Name = "std-web-app2" }
}