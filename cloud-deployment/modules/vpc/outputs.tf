
output "base_name" {
  value = var.base_name
}

output "region" {
  value = var.region
}

output "subnet-azs" {
  value = var.subnet_azs
}


output "subnet-ids" {
  value = [aws_subnet.re_subnet1.id,
           aws_subnet.re_subnet2.id,
           aws_subnet.re_subnet3.id]
}

output "vpc-id" {
  value = aws_vpc.redis_cluster_vpc.id
}

output "vpc-name" {
  description = "get all tags, get the Project Name tag for the VPC"
  value = aws_vpc.redis_cluster_vpc.tags_all.Project
}