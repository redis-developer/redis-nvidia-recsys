#### Create EC2 Nodes for RE

# create nodes for your Redis Enterprise cluster
resource "aws_instance" "re_cluster_instance" {
  count                       = var.data-node-count
  ami                         = data.aws_ami.re-ami.id
  associate_public_ip_address = true
  availability_zone           = element(var.subnet_azs, count.index)
  subnet_id                   = element(var.vpc_subnets_ids, count.index)
  instance_type               = var.re_instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [ aws_security_group.re_sg.id ]
  root_block_device             { volume_size = var.node-root-size }

  tags = {
    Name = format("%s-node-%s", var.vpc_name,count.index+1),
    Owner = var.owner
  }

}