#### Create & attach EBS volumes for RE nodes

# Attach Ephemeral Volumes
# Instance 1
resource "aws_ebs_volume" "ephemeral_re_cluster_instance" {
  count             = var.data-node-count
  availability_zone = element(var.subnet_azs, count.index)
  size              = var.re-volume-size

  tags = {
    Name = format("%s-ec2-%s-ephemeral", var.vpc_name, count.index+1),
    Owner = var.owner
  }
}

resource "aws_volume_attachment" "ephemeral_re_cluster_instance" {
  count       = var.data-node-count
  device_name = "/dev/sdh"
  volume_id   = element(aws_ebs_volume.ephemeral_re_cluster_instance.*.id, count.index)
  instance_id = element(aws_instance.re_cluster_instance.*.id, count.index)
}

# Attach Persistent Volumes
# Instance 1
resource "aws_ebs_volume" "persistent_re_cluster_instance" {
  count             = var.data-node-count
  availability_zone = element(var.subnet_azs, count.index)
  size              = var.re-volume-size

  tags = {
    Name = format("%s-ec2-%s-persistent", var.vpc_name, count.index+1),
    Owner = var.owner
  }
}

resource "aws_volume_attachment" "persistent_re_cluster_instance" {
  count       = var.data-node-count
  device_name = "/dev/sdj"
  volume_id   = element(aws_ebs_volume.persistent_re_cluster_instance.*.id, count.index)
  instance_id = element(aws_instance.re_cluster_instance.*.id, count.index)
}