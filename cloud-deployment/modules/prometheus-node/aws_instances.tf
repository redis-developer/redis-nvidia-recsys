#### Create EC2 Nodes for Prometheus Node

# create Prometheus node
resource "aws_instance" "prometheus_node" {
  count                       = 1
  ami                         = var.re_ami
  associate_public_ip_address = true
  availability_zone           = element(var.subnet_azs, count.index)
  subnet_id                   = element(var.vpc_subnets_ids, count.index)
  instance_type               = var.prometheus_instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  source_dest_check           = false

  tags = {
    Name = format("%s-prometheus-node-%s", var.vpc_name,count.index+1),
    Owner = var.owner
  }

}