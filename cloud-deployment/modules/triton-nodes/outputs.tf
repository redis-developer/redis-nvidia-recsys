#### Outputs

### triton node
output "triton-node-eips" {
  value = aws_eip.triton_node_eip[*].public_ip
}
