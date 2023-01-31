#### DNS variables

variable "dns_hosted_zone_id" {
    description = "DNS hosted zone Id"
}

variable "vpc_name" {
  description = "The VPC Name tag"
}

variable "data-node-count" {
  description = "number of data nodes"
  default     = 3
}

variable "re-data-node-eips" {
  type        = list(any)
  description = "List of Elastic IP address to add as A records"
  default     = []
}