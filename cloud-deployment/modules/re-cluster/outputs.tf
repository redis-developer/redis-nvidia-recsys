#### Outputs

output "re-cluster-url" {
  value = format("https://%s:8443", var.dns_fqdn)
}

output "re-cluster-username" {
  value = var.re_cluster_username
}

output "re-cluster-password" {
  value = var.re_cluster_password
}