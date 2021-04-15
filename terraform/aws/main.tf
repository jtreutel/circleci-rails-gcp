

resource "aws_security_group" "rails_app" {
  name        = "%{if var.resource_prefix != ""}${var.resource_prefix} %{endif}Rails App SG"
  description = "Allows outbound traffic, optionally allows inbound SSH."
  vpc_id      = var.vpc_id
}
resource "aws_security_group_rule" "allow_inbound_ssh" {
  count             = var.inbound_cidrs != null ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.inbound_cidrs
  security_group_id = aws_security_group.rails_app.id
}
resource "aws_security_group_rule" "allow_inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rails_app.id
}
resource "aws_security_group_rule" "allow_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.outbound_cidrs != null ? var.outbound_cidrs : ["0.0.0.0/0"]
  security_group_id = aws_security_group.rails_app.id
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "rails_app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_size
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name != "" ? var.key_name : null
  associate_public_ip_address = var.assign_public_ip
  vpc_security_group_ids      = [aws_security_group.rails_app.id]

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    tags = merge(
      var.extra_tags,
      {
        Name = format("%{if var.resource_prefix != ""}${var.resource_prefix}-%{endif}rails-app-root")
      }
    )

  }

  user_data = file("${path.module}/userdata/install.sh")

  tags = merge(
    var.extra_tags,
    {
      Name = format("%{if var.resource_prefix != ""}${var.resource_prefix}-%{endif}rails-app")
    }
  )

  lifecycle {
    ignore_changes = [ami] #to avoid undesired create/destroy of instances when a newer AMI is released.
  }
}
