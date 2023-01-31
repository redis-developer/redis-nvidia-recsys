#### Create & associate EIP with Prometheus Node

#####################
#### Prometheus Nodes EIP
resource "aws_eip" "prometheus_node_eip" {
  count = 1
  network_border_group = var.region
  vpc      = true

  tags = {
      Name = format("%s-prometheus-eip-%s", var.vpc_name, count.index+1),
      Owner = var.owner
  }

}

#### Prometheus Node Elastic IP association
resource "aws_eip_association" "prometheus_eip_assoc" {
  count = 1
  instance_id   = element(aws_instance.prometheus_node.*.id, count.index)
  allocation_id = element(aws_eip.prometheus_node_eip.*.id, count.index)
  depends_on    = [aws_instance.prometheus_node, aws_eip.prometheus_node_eip]
}
