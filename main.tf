locals {
  common_tags = tomap(
    {"Cluster" = "${var.cluster_name}",
    "Owner" = "${var.owner}"
}
  )

  amis  = tomap({
    centos_7 = data.aws_ami.centos_7.id,
    ubuntu_18 = data.aws_ami.ubuntu_18.id,
    ubuntu_20 = data.aws_ami.ubuntu_20.id
  })
}



provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_access_key_secret
  region     = var.aws_region
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Security Groups
resource "aws_security_group" "allow_all_vpc" {
  description = "All traffic in the VPC - Managed by Terraform"
  name        = "${var.cluster_name}-${var.owner}-allow-all-vpc-security-group"
  vpc_id      = var.vpc_id

  ingress = [{
    description      = null,
    protocol         = "-1",
    cidr_blocks      = ["${data.aws_vpc.selected.cidr_block}"],
    from_port        = 0,
    to_port          = 0,
    ipv6_cidr_blocks = null,
    prefix_list_ids  = null,
    security_groups  = null,
    self             = null
  }]

  egress = [{
    description      = null,
    protocol         = "-1",
    cidr_blocks      = ["${data.aws_vpc.selected.cidr_block}"],
    from_port        = 0,
    to_port          = 0,
    ipv6_cidr_blocks = null,
    prefix_list_ids  = null,
    security_groups  = null,
    self             = null
  }]
}

resource "aws_security_group" "external_connectivity" {
  description = "External Connectivity Security Group - Managed by Terraform"
  name        = "${var.cluster_name}-${var.owner}-external-connectivity-security-group"
  vpc_id      = var.vpc_id
  # ssh from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  # broker from anywhere
  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  # MDS from anywhere
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  # joloklia from anywhere
  ingress {
    from_port   = 7771
    to_port     = 7771
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  # connect http interface - only accessable on host, without this
  # c3 needs access
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  # schema-registry http interface - only accessable on host, without this
  # c3 needs access
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  # control-center http interface - only accessable on host, without this
  # c3 needs access
  ingress {
    from_port   = 9021
    to_port     = 9021
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  # KSQL access
  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "TCP"
    cidr_blocks = var.security_group_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# instances
resource "aws_instance" "broker" {
  count                       = var.broker_count
  ami                         = local.amis[var.os]
  instance_type               = var.broker_instance_type
  associate_public_ip_address = var.broker_associate_public_ip_address
  subnet_id                   = var.subnet_id
  key_name                    = var.ec2_public_key_name
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = var.broker_vpc_security_group_ids
  security_groups = [
    "${aws_security_group.external_connectivity.id}",
    "${aws_security_group.allow_all_vpc.id}"
  ]
  root_block_device {
    volume_size           = var.broker_root_volume_size
    delete_on_termination = var.broker_delete_root_block_device_on_termination
  }

  tags = merge(
    tomap({"Name" = "${var.prefix}-kafka-broker"}),
    local.common_tags,
    var.broker_tags
  )
}

resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = local.amis[var.os]
  instance_type               = var.worker_instance_type
  associate_public_ip_address = var.worker_associate_public_ip_address
  subnet_id                   = var.subnet_id
  key_name                    = var.ec2_public_key_name
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = var.worker_vpc_security_group_ids
  security_groups = [
    "${aws_security_group.external_connectivity.id}",
    "${aws_security_group.allow_all_vpc.id}"
  ]

  root_block_device {
    delete_on_termination = var.worker_delete_root_block_device_on_termination
  }

  tags = merge(
    tomap({"Name" = "${var.prefix}-worker-node"}),
    local.common_tags,
    var.worker_tags
  )
}

resource "aws_ebs_volume" "broker_volume" {
  count             = var.broker_count
  availability_zone = var.availability_zone
  size              = var.broker_volume_size
}

resource "aws_volume_attachment" "broker_volume" {
  count       = var.broker_count
  device_name = var.broker_volume_device_name
  volume_id   = element(aws_ebs_volume.broker_volume.*.id, count.index)
  instance_id = element(aws_instance.broker.*.id, count.index)
}

output "broker_public_dns" {
  description = "Public DNS for Brokers"
  value       = aws_instance.broker.*.public_dns
}

output "broker_private_dns" {
  description = "Private DNS for Brokers"
  value       = aws_instance.broker.*.private_dns
}

output "worker_public_dns" {
  description = "Public DNS for Workers"
  value       = aws_instance.worker.*.public_dns
}

output "worker_private_dns" {
  description = "Private DNS for Workers"
  value       = aws_instance.worker.*.private_dns
}
