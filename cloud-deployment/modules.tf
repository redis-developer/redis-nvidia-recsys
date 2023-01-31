########## Create an RE cluster on AWS from scratch #####
#### Modules to create the following:
#### Brand new VPC
#### RE nodes and install RE software (ubuntu)
#### Triton node with Redis and Memtier
#### Prometheus Node for advanced monitoring of Redis Enterprise Cluster
#### DNS (NS and A records for RE nodes)
#### Create and Join RE cluster


########### VPC Module
#### create a brand new VPC, use its outputs in future modules
#### If you already have an existing VPC, comment out and
#### enter your VPC params in the future modules
module "vpc" {
    source             = "./modules/vpc"
    aws_creds          = var.aws_creds
    owner              = var.owner
    region             = var.region
    base_name          = var.base_name
    vpc_cidr           = var.vpc_cidr
    subnet_cidr_blocks = var.subnet_cidr_blocks
    subnet_azs         = var.subnet_azs
}

### VPC outputs
### Outputs from VPC outputs.tf,
### must output here to use in future modules)
output "subnet-ids" {
  value = module.vpc.subnet-ids
}

output "vpc-id" {
  value = module.vpc.vpc-id
}

output "vpc_name" {
  description = "get the VPC Name tag"
  value = module.vpc.vpc-name
}

########### Node Module
#### Create RE nodes
#### Ansible playbooks configure and install RE software on nodes
module "nodes" {
    source             = "./modules/nodes"
    owner              = var.owner
    region             = var.region
    vpc_cidr           = var.vpc_cidr
    subnet_azs         = var.subnet_azs
    ssh_key_name       = var.ssh_key_name
    ssh_key_path       = var.ssh_key_path
    re_download_url    = var.re_download_url
    data-node-count    = var.data-node-count
    re_instance_type   = var.re_instance_type
    re-volume-size     = var.re-volume-size
    allow-public-ssh   = var.allow-public-ssh
    open-nets          = var.open-nets
    ### vars pulled from previous modules
    ## from vpc module outputs
    ##(these do not need to be varibles in the variables.tf outside the modules folders
    ## since they are refrenced from the other module, but they need to be variables
    ## in the variables.tf inside the nodes module folder )
    vpc_name           = module.vpc.vpc-name
    vpc_subnets_ids    = module.vpc.subnet-ids
    vpc_id             = module.vpc.vpc-id
}

#### Node Outputs to use in future modules
output "re-data-node-eips" {
  value = module.nodes.re-data-node-eips
}

output "re-data-node-internal-ips" {
  value = module.nodes.re-data-node-internal-ips
}

output "re-data-node-eip-public-dns" {
  value = module.nodes.re-data-node-eip-public-dns
}

output "vpc_security_group_ids" {
  value = module.nodes.vpc_security_group_ids
}

output "re_ami" {
  value = module.nodes.re_ami
}


########### Triton Node Module
#### Create Triton nodes
module "triton-nodes" {
    source             = "./modules/triton-nodes"
    owner              = var.owner
    region             = var.region
    vpc_cidr           = var.vpc_cidr
    subnet_azs         = var.subnet_azs
    ssh_key_name       = var.ssh_key_name
    ssh_key_path       = var.ssh_key_path
    triton_instance_type = var.triton_instance_type
    triton-node-count    = var.triton-node-count #if you want a tester node, enter 1 or greater, else 0
    ### vars pulled from previous modules
    vpc_name           = module.vpc.vpc-name
    vpc_subnets_ids    = module.vpc.subnet-ids
    vpc_id             = module.vpc.vpc-id
    vpc_security_group_ids = module.nodes.vpc_security_group_ids
    triton_ami             = var.triton_ami

    depends_on = [module.vpc, module.nodes]
}

output "triton-node-eips" {
  value = module.triton-nodes.triton-node-eips
}

########### DNS Module
#### Create DNS (NS record, A records for each RE node and its eip)
#### Currently using existing dns hosted zone
module "dns" {
    source             = "./modules/dns"
    dns_hosted_zone_id = var.dns_hosted_zone_id
    data-node-count    = var.data-node-count
    ### vars pulled from previous modules
    vpc_name           = module.vpc.vpc-name
    re-data-node-eips  = module.nodes.re-data-node-eips
}

#### dns FQDN output used in future modules
output "dns-ns-record-name" {
  value = module.dns.dns-ns-record-name
}

############## RE Cluster
#### Ansible Playbook runs locally to create the cluster
module "create-cluster" {
  source               = "./modules/re-cluster"
  ssh_key_path         = var.ssh_key_path
  region               = var.region
  re_cluster_username  = var.re_cluster_username
  re_cluster_password  = var.re_cluster_password
  ### vars pulled from previous modules
  vpc_name             = module.vpc.vpc-name
  re-node-internal-ips = module.nodes.re-data-node-internal-ips
  re-node-eip-ips      = module.nodes.re-data-node-eips
  re-data-node-eip-public-dns   = module.nodes.re-data-node-eip-public-dns
  dns_fqdn             = module.dns.dns-ns-record-name

  depends_on           = [module.vpc, module.nodes, module.dns]
}

#### Cluster Outputs
output "re-cluster-url" {
  value = module.create-cluster.re-cluster-url
}

output "re-cluster-username" {
  value = module.create-cluster.re-cluster-username
}

output "re-cluster-password" {
  value = module.create-cluster.re-cluster-password
}

######### Prometheus and Grafana Module
#### configure prometheus and grafana on new node
######## IF YOU DONT WANT A GRAFANA NODE, Comment out this module and its outputs
module "prometheus-node" {
    source             = "./modules/prometheus-node"
    owner              = var.owner
    region             = var.region
    vpc_cidr           = var.vpc_cidr
    subnet_azs         = var.subnet_azs
    ssh_key_name       = var.ssh_key_name
    ssh_key_path       = var.ssh_key_path
    prometheus_instance_type = var.prometheus_instance_type
    ### vars pulled from previous modules
    vpc_name           = module.vpc.vpc-name
    vpc_subnets_ids    = module.vpc.subnet-ids
    vpc_id             = module.vpc.vpc-id
    vpc_security_group_ids = module.nodes.vpc_security_group_ids
    re_ami             = module.nodes.re_ami
    dns_fqdn           = module.dns.dns-ns-record-name


    depends_on = [module.vpc, module.nodes, module.dns, module.create-cluster]
}

#### dns FQDN output used in future modules
output "grafana_url" {
  value = module.prometheus-node.grafana_url
}

output "grafana_username" {
  value = "admin"
}

output "grafana_password" {
  value = "secret"
}