#### AMI for Nodes
#### find the lastest ami for ubuntu 18.04 x86 server

data "aws_ami" "re-ami" {
  most_recent = true
  name_regex  = "ubuntu\\/images\\/hvm-ssd\\/ubuntu-bionic-18.04-amd64-server"
  # This is Canonical's ID (find here: https://ubuntu.com/server/docs/cloud-images/amazon-ec2)
  owners = ["099720109477"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "ena-support"
    values = [var.ena-support]
  }
}