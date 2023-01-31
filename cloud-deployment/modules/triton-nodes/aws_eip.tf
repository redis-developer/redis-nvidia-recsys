#### Create & associate EIP with Triton Nodes

#####################
#### Triton Nodes EIP
resource "aws_eip" "triton_node_eip" {
  count = var.triton-node-count
  network_border_group = var.region
  vpc      = true

  tags = {
      Name = format("%s-triton-eip-%s", var.vpc_name, count.index+1),
      Owner = var.owner
  }

}

#### Test Node Elastic IP association
resource "aws_eip_association" "triton_eip_assoc" {
  count = var.triton-node-count
  instance_id   = element(aws_instance.triton_node.*.id, count.index)
  allocation_id = element(aws_eip.triton_node_eip.*.id, count.index)
  depends_on    = [aws_instance.triton_node, aws_eip.triton_node_eip]
}
