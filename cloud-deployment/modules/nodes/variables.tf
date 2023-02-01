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

############## Redis Enterprise Nodes Variables

#### RE Software download url (MUST BE ubuntu 18.04)
#### example: re_download_url = "https://s3.amazonaws.com/redis-enterprise-software-downloads/x.x.xx/redislabs-x.x.xx-68-bionic-amd64.tar"
variable "re_download_url" {
  description = "re download url"
  default     = ""
}

#### how many data nodes, 3 minimum
variable "data-node-count" {
  description = "number of data nodes"
  default     = 3
}

variable "ena-support" {
  description = "choose AMIs that have ENA support enabled"
  default     = true
}

variable "re_instance_type" {
    description = "re instance type"
    default     = "t2.xlarge"
}

variable "node-root-size" {
  description = "The size of the root volume"
  default     = "50"
}

##### EBS volume for persistent and ephemeral storage
variable "re-volume-size" {
  description = "The size of the ephemeral and persistent volumes to attach"
  default     = "150"
}

#### Security
variable "open-nets" {
  type        = list(any)
  description = "CIDRs that will have access to everything"
  default     = []
}

variable "allow-public-ssh" {
  description = "Allow SSH to be open to the public - enabled by default"
  default     = "1"
}

variable "internal-rules" {
  description = "Security rules to allow for connectivity within the VPC"
  type        = list(any)
  default = [
    {
      type      = "ingress"
      from_port = "22"
      to_port   = "22"
      protocol  = "tcp"
      comment   = "SSH from VPC"
    },
    {
      type      = "ingress"
      from_port = "1968"
      to_port   = "1968"
      protocol  = "tcp"
      comment   = "Proxy traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "3333"
      to_port   = "3341"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "3343"
      to_port   = "3344"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "36379"
      to_port   = "36380"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "8001"
      to_port   = "8001"
      protocol  = "tcp"
      comment   = "Traffic from application to RS Discovery Service"
    },
    {
      type      = "ingress"
      from_port = "8002"
      to_port   = "8002"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8004"
      to_port   = "8004"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8006"
      to_port   = "8006"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8443"
      to_port   = "8443"
      protocol  = "tcp"
      comment   = "Secure (HTTPS) access to the management web UI"
    },
    {
      type      = "ingress"
      from_port = "8444"
      to_port   = "8444"
      protocol  = "tcp"
      comment   = "nginx <-> cnm_http/cm traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "9080"
      to_port   = "9080"
      protocol  = "tcp"
      comment   = "nginx <-> cnm_http/cm traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "9081"
      to_port   = "9081"
      protocol  = "tcp"
      comment   = "For CRDB management (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "8070"
      to_port   = "8071"
      protocol  = "tcp"
      comment   = "Prometheus metrics exporter"
    },
    {
      type      = "ingress"
      from_port = "9443"
      to_port   = "9443"
      protocol  = "tcp"
      comment   = "REST API traffic, including cluster management and node bootstrap"
    },
    {
      type      = "ingress"
      from_port = "10000"
      to_port   = "19999"
      protocol  = "tcp"
      comment   = "Database traffic - if manually creating db ports pare down"
    },
    {
      type      = "ingress"
      from_port = "20000"
      to_port   = "29999"
      protocol  = "tcp"
      comment   = "Database shards traffic - if manually creating db ports pare down"
    },
    {
      type      = "ingress"
      from_port = "53"
      to_port   = "53"
      protocol  = "udp"
      comment   = "DNS Traffic"
    },
    {
      type      = "ingress"
      from_port = "5353"
      to_port   = "5353"
      protocol  = "udp"
      comment   = "DNS Traffic"
    },
    {
      type      = "ingress"
      from_port = "-1"
      to_port   = "-1"
      protocol  = "icmp"
      comment   = "Ping for connectivity checks between nodes"
    },
    {
      type      = "egress"
      from_port = "-1"
      to_port   = "-1"
      protocol  = "icmp"
      comment   = "Ping for connectivity checks between nodes"
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "tcp"
      comment   = "Let TCP out to the VPC"
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "udp"
      comment   = "Let UDP out to the VPC"
    },
    #    {
    #      type      = "ingress"
    #      from_port = "8080"
    #      to_port   = "8080"
    #      protocol  = "tcp"
    #      comment   = "Allow for host check between nodes"
    #    },
  ]
}

variable "external-rules" {
  description = "Security rules to allow for connectivity external to the VPC"
  type        = list(any)
  default = [
    {
      type      = "ingress"
      from_port = "53"
      to_port   = "53"
      protocol  = "udp"
      cidr      = ["0.0.0.0/0"]
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "tcp"
      cidr      = ["0.0.0.0/0"]
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "udp"
      cidr      = ["0.0.0.0/0"]
    }
  ]
}