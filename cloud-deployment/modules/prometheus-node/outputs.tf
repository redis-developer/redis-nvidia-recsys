#### Outputs

output "grafana_url" {
  value = format("http://%s:3000", aws_eip.prometheus_node_eip[0].public_ip)
}