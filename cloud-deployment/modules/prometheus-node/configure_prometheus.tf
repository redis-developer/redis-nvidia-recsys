#### Generating Ansible config, inventory, playbook 
#### and configuring Prometheus node with Prometheus and Grafana

#### Sleeper, after instance, eip assoc, local file inventories & cfg created
#### otherwise it can run to fast, not find the inventory file and fail or hang
resource "time_sleep" "wait_30_seconds_prometheus" {
  create_duration = "30s"
  depends_on = [aws_instance.prometheus_node, 
                aws_eip_association.prometheus_eip_assoc, 
                local_file.inventory_setup_prometheus, 
                local_file.ssh-setup-prometheus,
                local_file.prometheus, 
                local_file.docker_compose]
}

# remote-config waits till the node is accessible
resource "null_resource" "remote_config_prometheus" {
  count = 1
  provisioner "remote-exec" {
        inline = ["sudo apt update > /dev/null"]

        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file(var.ssh_key_path)
            host = element(aws_eip.prometheus_node_eip.*.public_ip, count.index)
        }
    }

    depends_on = [aws_instance.prometheus_node, 
                aws_eip_association.prometheus_eip_assoc, 
                local_file.inventory_setup_prometheus, 
                local_file.ssh-setup-prometheus,
                time_sleep.wait_30_seconds_prometheus]
}

#### Generate Ansible Inventory for the node
resource "local_file" "inventory_setup_prometheus" {
    count    = 1
    content  = templatefile("${path.module}/ansible/inventories/inventory_prometheus.tpl", {
        host_ip  = element(aws_eip.prometheus_node_eip.*.public_ip, count.index)
        vpc_name = var.vpc_name
    })
    filename = "/tmp/${var.vpc_name}_prometheus_node_${count.index}.ini"
  depends_on = [aws_instance.prometheus_node, aws_eip_association.prometheus_eip_assoc]
}

#### Generate ansible.cfg file
resource "local_file" "ssh-setup-prometheus" {
    content  = templatefile("${path.module}/ansible/config/ssh.tpl", {
        vpc_name = var.vpc_name
    })
    filename = "/tmp/${var.vpc_name}_prometheus_node.cfg"
  depends_on = [aws_instance.prometheus_node, aws_eip_association.prometheus_eip_assoc]
}

################ configure prometheus and docker on node
#### Generate prometheus yml
resource "local_file" "prometheus" {
    content  = templatefile("${path.module}/ansible/prometheus/prometheus.yml.tpl", {
        cluster_fqdn = var.dns_fqdn
    })
    filename = "/tmp/prometheus.yml"
}


#### Generate docker-compose.yml file
resource "local_file" "docker_compose" {
    content  = templatefile("${path.module}/ansible/prometheus/docker-compose.yml.tpl", {
    })
    filename = "/tmp/docker-compose.yml"
}

######################
# Run ansible playbook to configure prometheus
resource "null_resource" "ansible_run_prometheus" {
  count = 1
  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ansible/playbooks/playbook_prometheus_node.yaml --private-key ${var.ssh_key_path} -i /tmp/${var.vpc_name}_prometheus_node_${count.index}.ini"
  }
  depends_on = [null_resource.remote_config_prometheus,
                time_sleep.wait_30_seconds_prometheus,
                local_file.prometheus, 
                local_file.docker_compose]
}

################ configure grafana: first prometheus as the data source

#### Generate prometheus_datasource file
resource "local_file" "prometheus_datasource" {
    content  = templatefile("${path.module}/ansible/roles/grafana-datasource/defaults/main.yml.tpl", {
        grafana_url = format("http://%s:3000", aws_eip.prometheus_node_eip[0].public_ip)
        prometheus_url = format("http://%s:9090", aws_eip.prometheus_node_eip[0].public_ip)
    })
    filename = "${path.module}/ansible/roles/grafana-datasource/defaults/main.yml"
}


resource "time_sleep" "wait_grafana" {
  create_duration = "15s"
  depends_on = [aws_instance.prometheus_node, 
                aws_eip_association.prometheus_eip_assoc, 
                local_file.inventory_setup_prometheus, 
                local_file.ssh-setup-prometheus,
                local_file.prometheus, 
                local_file.docker_compose,
                null_resource.ansible_run_prometheus]
}

######################
# Run ansible playbook to configure prometheus
resource "null_resource" "ansible_run_grafana_datasource" {
  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ansible/grafana-datasource.yml"
  }
  depends_on = [null_resource.ansible_run_prometheus,
                time_sleep.wait_30_seconds_prometheus,
                time_sleep.wait_grafana,
                local_file.prometheus_datasource]
}

###################### 
###################### Grafana Dashboard Config

#### save json files to tmp folder so I can access them
resource "local_file" "save_grafana_cluster_to_tmp" {
    content  = templatefile("${path.module}/ansible/grafana/cluster.json", {
    })
    filename = "/tmp/cluster.json"
}

resource "local_file" "save_grafana_database_to_tmp" {
    content  = templatefile("${path.module}/ansible/grafana/database.json", {
    })
    filename = "/tmp/database.json"
}

resource "local_file" "save_grafana_node_to_tmp" {
    content  = templatefile("${path.module}/ansible/grafana/node.json", {
    })
    filename = "/tmp/node.json"
}


#### Generate grafana dashboard yaml
resource "local_file" "playbook_grafana_yaml" {
    content  = templatefile("${path.module}/ansible/playbooks/playbook_grafana_dashboard.yaml.tpl", {
        grafana_url = format("http://%s:3000", aws_eip.prometheus_node_eip[0].public_ip)
    })
    filename = "${path.module}/ansible/playbooks/playbook_grafana_dashboard.yaml"
  depends_on = [time_sleep.wait_grafana, local_file.prometheus_datasource]
}


######################
# Run ansible playbook to configure grafana db
resource "null_resource" "ansible_run_grafana_dashboard" {
  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ansible/playbooks/playbook_grafana_dashboard.yaml"
  }
  depends_on = [null_resource.ansible_run_prometheus,
                null_resource.ansible_run_grafana_datasource,
                time_sleep.wait_grafana,
                local_file.prometheus_datasource,
                local_file.playbook_grafana_yaml]
}