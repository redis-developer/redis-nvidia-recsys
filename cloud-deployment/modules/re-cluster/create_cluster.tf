#### Generate ansible inventory file & extra_vars file, run ansible playbook to create cluster

#### Sleeper, just to make sure nodes module is complete and everything is installed
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}

##### Generate ansible inventory.ini for any number of nodes
resource "local_file" "dynamic_inventory_ini" {
    content  = templatefile("${path.module}/inventories/inventory.tpl", {
      re-data-node-eip-public-dns = var.re-data-node-eip-public-dns
      re-node-internal-ips        = var.re-node-internal-ips
      re-node-eip-ips             = var.re-node-eip-ips
    })
    filename = "${path.module}/inventories/${var.vpc_name}_inventory.ini"
}

##### Generate extra_vars.yaml file
resource "local_file" "extra_vars" {
    content  = templatefile("${path.module}/extra_vars/inventory.yaml.tpl", {
      ansible_user        = "ubuntu"
      dns_fqdn            = var.dns_fqdn
      re_cluster_username = var.re_cluster_username
      re_cluster_password = var.re_cluster_password
      re_email_from       = "admin@domain.tld"
      re_smtp_host        = "smtp.domain.tld"
    })
    filename = "${path.module}/extra_vars/${var.vpc_name}_inventory.yaml"
}

######################
# Run ansible-playbook to create cluster
resource "null_resource" "ansible-run" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=\"False\" ansible-playbook ${path.module}/redislabs-create-cluster.yaml --private-key ${var.ssh_key_path} -i ${path.module}/inventories/${var.vpc_name}_inventory.ini -e @${path.module}/extra_vars/${var.vpc_name}_inventory.yaml -e @${path.module}/group_vars/all/main.yaml" 
    }
    depends_on = [local_file.dynamic_inventory_ini, 
                  time_sleep.wait_30_seconds, 
                  local_file.extra_vars]
}