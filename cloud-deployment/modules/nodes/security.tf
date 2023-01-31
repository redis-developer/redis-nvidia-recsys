#### Create Security Group

resource "aws_security_group" "re_sg" {
  name        = format("%s-re-sg", var.vpc_name)
  description = "Redis Enterprise Security Group"
  vpc_id      = var.vpc_id
  
  tags = {
    Name = format("%s-re-sg", var.vpc_name),
    Owner = var.owner
  }
}

resource "aws_security_group_rule" "internal_rules" {
  count             = length(var.internal-rules)
  type              = lookup(var.internal-rules[count.index], "type")
  from_port         = lookup(var.internal-rules[count.index], "from_port")
  to_port           = lookup(var.internal-rules[count.index], "to_port")
  protocol          = lookup(var.internal-rules[count.index], "protocol")
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.re_sg.id
}

resource "aws_security_group_rule" "external_rules" {
  count             = length(var.external-rules)
  type              = lookup(var.external-rules[count.index], "type")
  from_port         = lookup(var.external-rules[count.index], "from_port")
  to_port           = lookup(var.external-rules[count.index], "to_port")
  protocol          = lookup(var.external-rules[count.index], "protocol")
  cidr_blocks       = lookup(var.external-rules[count.index], "cidr")
  security_group_id = aws_security_group.re_sg.id
}

resource "aws_security_group_rule" "open_nets" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "65535"
  protocol          = "all"
  cidr_blocks       = var.open-nets
  security_group_id = aws_security_group.re_sg.id
}

resource "aws_security_group_rule" "allow_public_ssh" {
  count             = var.allow-public-ssh
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.re_sg.id
}