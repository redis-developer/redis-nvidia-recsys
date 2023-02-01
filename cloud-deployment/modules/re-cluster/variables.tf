#### Required Variables
variable "region" {
    description = "AWS region"
}

variable "ssh_key_path" {
    description = "name of ssh key to be added to instance"
}

variable "vpc_name" {
  description = "The VPC Project Name tag"
}

####### Create Cluster Variables
####### Node and DNS outputs used to Create Cluster
#### created during node module and used as outputs (no input required)
variable "dns_fqdn" {
    description = "."
    default = ""
}

variable "re-node-internal-ips" {
    type = list
    description = "."
    default = []
}

variable "re-node-eip-ips" {
    type = list
    description = "."
    default = []
}

variable "re-data-node-eip-public-dns" {
    type = list
    description = "."
    default = []
}

############# Create RE Cluster Variables

#### Cluster Inputs
#### RE Cluster Username
variable "re_cluster_username" {
    description = "redis enterprise cluster username"
    default     = "admin@admin.com"
}

#### RE Cluster Password
variable "re_cluster_password" {
    description = "redis enterprise cluster password"
    default     = "admin"
}

