#### Create EC2 Nodes for Triton

resource "aws_instance" "triton_node" {
  count                       = var.triton-node-count
  ami                         = var.triton_ami
  associate_public_ip_address = true
  availability_zone           = element(var.subnet_azs, count.index)
  subnet_id                   = element(var.vpc_subnets_ids, count.index)
  instance_type               = var.triton_instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  source_dest_check           = false

  tags = {
    Name = format("%s-triton-node-%s", var.vpc_name,count.index+1),
    Owner = var.owner
  }

}