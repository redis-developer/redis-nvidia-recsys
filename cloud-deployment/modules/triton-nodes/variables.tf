#### Required Variables

variable "region" {
    description = "AWS region"
}

variable "ssh_key_name" {
    description = "name of ssh key to be added to instance"
}

variable "ssh_key_path" {
    description = "name of ssh key to be added to instance"
}

variable "owner" {
    description = "owner tag name"
}

#### VPC
variable "vpc_cidr" {
    description = "vpc-cidr"
}

variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "vpc_name" {
  description = "The VPC Project Name tag"
}

variable "vpc_subnets_ids" {
  type        = list(any)
  description = "The list of subnets available to the VPC"
}

variable "subnet_azs" {
    type = list(any)
    description = "subnet availability zone"
    default = [""]
}

#### Triton Instance Variables

variable "triton-node-count" {
  description = "number of triton nodes"
  default     = 1
}

variable "triton_instance_type" {
    description = "instance type to use. Default: t3.micro"
    default = "g4dn.xlarge"
}

####### Node Output Variables
#### used in additional modules

variable "vpc_security_group_ids" {
    type = list
    description = "."
    default = []
}

variable "triton_ami" {
    description = "Amazon machine image for triton"
    default = "ami-0b61d2979f583d63d"
}