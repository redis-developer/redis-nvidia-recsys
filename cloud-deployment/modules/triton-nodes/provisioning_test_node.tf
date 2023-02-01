#### Generating Ansible config, inventory, playbook
#### and configuring test nodes and installing Redis and Memtier

#### Sleeper, after instance, eip assoc, local file inventories & cfg created
#### otherwise it can run to fast, not find the inventory file and fail or hang
resource "time_sleep" "wait_30_seconds_test" {
  create_duration = "30s"
  depends_on = [aws_instance.triton_node,
                aws_eip_association.triton_eip_assoc,
                local_file.inventory_setup_test,
                local_file.ssh-setup-test]
}

# remote-config waits till the node is accessible
resource "null_resource" "remote_config_test" {
  count = var.triton-node-count
  provisioner "remote-exec" {
        inline = ["sudo apt update > /dev/null"]

        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file(var.ssh_key_path)
            host = element(aws_eip.triton_node_eip.*.public_ip, count.index)
        }
    }

    depends_on = [aws_instance.triton_node,
                aws_eip_association.triton_eip_assoc,
                local_file.inventory_setup_test,
                local_file.ssh-setup-test,
                time_sleep.wait_30_seconds_test]
}

#### Generate Ansible Inventory for each node
resource "local_file" "inventory_setup_test" {
    count    = var.triton-node-count
    content  = templatefile("${path.module}/ansible/inventories/inventory_test.tpl", {
        host_ip  = element(aws_eip.triton_node_eip.*.public_ip, count.index)
        vpc_name = var.vpc_name
    })
    filename = "/tmp/${var.vpc_name}_triton_node_${count.index}.ini"
  depends_on = [aws_instance.triton_node, aws_eip_association.triton_eip_assoc]
}

#### Generate ansible.cfg file
resource "local_file" "ssh-setup-test" {
    content  = templatefile("${path.module}/ansible/config/ssh.tpl", {
        vpc_name = var.vpc_name
    })
    filename = "/tmp/${var.vpc_name}_triton_node.cfg"
  depends_on = [aws_instance.triton_node, aws_eip_association.triton_eip_assoc]
}

######################
# Run ansible playbook to install redis and memtier
resource "null_resource" "ansible_test_run" {
  count = var.triton-node-count
  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ansible/playbooks/playbook_test_node.yaml --private-key ${var.ssh_key_path} -i /tmp/${var.vpc_name}_triton_node_${count.index}.ini"
  }
  depends_on = [null_resource.remote_config_test, time_sleep.wait_30_seconds_test]
}
