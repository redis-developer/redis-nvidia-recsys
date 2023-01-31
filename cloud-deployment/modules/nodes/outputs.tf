#### Outputs

output "re-data-node-eips" {
  value = aws_eip.re_cluster_instance_eip[*].public_ip
}

output "re-data-node-internal-ips" {
  value = aws_instance.re_cluster_instance[*].private_ip
}

output "re-data-node-eip-public-dns" {
  value = aws_eip.re_cluster_instance_eip[*].public_dns #ec2 public dns after EIP association
}

#### Output variables

#vpc_security_group_ids
output "vpc_security_group_ids" {
  value = [ aws_security_group.re_sg.id ]
}

#re_ami
output "re_ami" {
  value = data.aws_ami.re-ami.id
}