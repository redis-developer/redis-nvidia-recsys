#### Create & associate EIP with RE

#### RE Nodes EIP
resource "aws_eip" "re_cluster_instance_eip" {
  count = var.data-node-count
  network_border_group = var.region
  vpc      = true

  tags = {
      Name = format("%s-eip-%s", var.vpc_name, count.index+1),
      Owner = var.owner
  }

}

#### RE Node Elastic IP association
resource "aws_eip_association" "re-eip-assoc" {
  count = var.data-node-count
  instance_id   = element(aws_instance.re_cluster_instance.*.id, count.index)
  allocation_id = element(aws_eip.re_cluster_instance_eip.*.id, count.index)
  depends_on    = [aws_instance.re_cluster_instance, aws_eip.re_cluster_instance_eip]
}