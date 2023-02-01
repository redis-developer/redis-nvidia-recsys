variable "region" {
    description = "AWS region"
}

variable "aws_creds" {
    description = "Access key and Secret key for AWS [Access Keys, Secret Key]"
}

variable "owner" {
    description = "owner tag name"
}

#### VPC
variable "vpc_cidr" {
    description = "vpc-cidr"
    default = "10.0.0.0/16"
}

variable "base_name" {
    description = "base name for resources"
    default = "redisuser1-tf"
}

variable "subnet_cidr_blocks" {
    type = list(any)
    description = "subnet_cidr_block"
    default = ["10.0.0.0/24","10.0.16.0/24","10.0.32.0/24"]
}

variable "subnet_azs" {
    type = list(any)
    description = "subnet availability zone (3 required)"
    default = [""]
}


