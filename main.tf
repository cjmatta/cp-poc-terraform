locals {
  common_tags = "${map(
    "Cluster", "${var.cluster_name}",
    "Owner", "${var.owner}"
    )}"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_access_key_secret}"
  region     = "${var.aws_region}"
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

# Security Groups
resource "aws_security_group" "allow-all-vpc" {
  description = "All traffic in the VPC - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-allow-all-vpc-security-group"
  vpc_id ="${var.vpc_id}"

  ingress = {
    protocol = "-1"
    cidr_blocks =  ["${data.aws_vpc.selected.cidr_block}"]
    from_port = 0
    to_port = 0
  }

  egress = {
    protocol = "-1"
    cidr_blocks =  ["${data.aws_vpc.selected.cidr_block}"]
    from_port = 0
    to_port = 0
  }
}

resource "aws_security_group" "ssh" {
  description = "SSH Security Group - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-ssh-security-group"
  vpc_id = "${var.vpc_id}"
  # ssh from anywhere
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "broker" {
  description = "Broker Security Group - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-broker-security-group"
  vpc_id = "${var.vpc_id}"
  # broker from anywhere
  ingress {
      from_port = 9092
      to_port = 9092
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "connect_distributed" {
  description = "Connect security group - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-connect_distributed-security-group"
  vpc_id = "${var.vpc_id}"
  # connect http interface - only accessable on host, without this
  # c3 needs access
  ingress {
      from_port = 8083
      to_port = 8083
      protocol = "TCP"
      self = true
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "schema_registry" {
  description = "Schema Registry security group - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-schema_registry-security-group"
  vpc_id = "${var.vpc_id}"
  # schema_registry http interface - only accessable on host, without this
  # c3 needs access
  ingress {
      from_port = 8081
      to_port = 8081
      protocol = "TCP"
      self = true
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "control_center" {
  description = "Control Center security group - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-control_center"
  vpc_id = "${var.vpc_id}"
  # control_center http interface - only accessable on host, without this
  # c3 needs access
  ingress {
      from_port = 9021
      to_port = 9021
      protocol = "TCP"
      self = true
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kafka_rest" {
  description = "Kafka REST security group - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-kafka_rest"
  vpc_id = "${var.vpc_id}"
  # kafka REST http interface 
  ingress {
      from_port = 8082
      to_port = 8082
      protocol = "TCP"
      self = true
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ksql" {
  description = "KSQL server security group - Managed by Terraform"
  name = "${var.cluster_name}-${var.owner}-ksql"
  vpc_id = "${var.vpc_id}"
  # KSQL server interface
  ingress {
      from_port = 8088
      to_port = 8088
      protocol = "TCP"
      self = true
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# instances
resource "aws_instance" "bastion" {
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.medium"
  associate_public_ip_address = "true"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.ec2_public_key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_security_group_ids = "${var.bastion_vpc_security_group_ids}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.allow-all-vpc.id}",
    "${var.bastion_vpc_security_group_ids}"
  ]
  root_block_device {
    delete_on_termination = "${var.bastion_delete_root_block_device_on_termination}"
  }

  tags ="${merge(
    map("Name", "confluent-platform-bastion"),
    local.common_tags,
    )}" 
}

resource "aws_instance" "broker" {
  count = "${var.broker_count}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.broker_instance_type}"
  associate_public_ip_address = "${var.broker_associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.ec2_public_key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_security_group_ids = "${var.broker_vpc_security_group_ids}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.broker.id}",
    "${aws_security_group.allow-all-vpc.id}",
    "${var.broker_vpc_security_group_ids}"
  ]
  root_block_device {
    delete_on_termination = "${var.broker_delete_root_block_device_on_termination}"
  }

  tags ="${merge(
    map("Name", "confluent-platform-kafka-broker"),
    local.common_tags,
    var.broker_tags
    )}"
}

resource "aws_instance" "schema_registry" {
  count = "${var.schema_registry_count}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.schema_registry_instance_type}"
  associate_public_ip_address = "${var.schema_registry_associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.ec2_public_key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_security_group_ids = "${var.schema_registry_vpc_security_group_ids}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.schema_registry.id}",
    "${aws_security_group.allow-all-vpc.id}",
    "${var.schema_registry_vpc_security_group_ids}"
  ]

  root_block_device {
    delete_on_termination = "${var.schema_registry_delete_root_block_device_on_termination}"
  }

  tags ="${merge(
    map("Name", "confluent-platform-schema_registry-node"),
    local.common_tags,
    var.schema_registry_tags
    )}"
}

resource "aws_instance" "control_center" {
  count = "${var.control_center_count}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.control_center_instance_type}"
  associate_public_ip_address = "${var.control_center_associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.ec2_public_key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_security_group_ids = "${var.control_center_vpc_security_group_ids}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.control_center.id}",
    "${aws_security_group.allow-all-vpc.id}",
    "${var.control_center_vpc_security_group_ids}"
  ]

  root_block_device {
    delete_on_termination = "${var.control_center_delete_root_block_device_on_termination}"
  }

  tags ="${merge(
    map("Name", "confluent-platform-control_center-node"),
    local.common_tags,
    var.control_center_tags
    )}"
}

resource "aws_instance" "connect_distributed" {
  count = "${var.connect_distributed_count}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.connect_distributed_instance_type}"
  associate_public_ip_address = "${var.connect_distributed_associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.ec2_public_key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_security_group_ids = "${var.connect_distributed_vpc_security_group_ids}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.connect_distributed.id}",
    "${aws_security_group.allow-all-vpc.id}",
    "${var.connect_distributed_vpc_security_group_ids}"
  ]

  root_block_device {
    delete_on_termination = "${var.connect_distributed_delete_root_block_device_on_termination}"
  }

  tags ="${merge(
    map("Name", "confluent-platform-connect_distributed-node"),
    local.common_tags,
    var.connect_distributed_tags
    )}"
}

resource "aws_instance" "kafka_rest" {
  count = "${var.kafka_rest_count}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.kafka_rest_instance_type}"
  associate_public_ip_address = "${var.kafka_rest_associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.ec2_public_key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_security_group_ids = "${var.kafka_rest_vpc_security_group_ids}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.kafka_rest.id}",
    "${aws_security_group.allow-all-vpc.id}",
    "${var.kafka_rest_vpc_security_group_ids}"
  ]

  root_block_device {
    delete_on_termination = "${var.kafka_rest_delete_root_block_device_on_termination}"
  }

  tags ="${merge(
    map("Name", "confluent-platform-kafka_rest-node"),
    local.common_tags,
    var.kafka_rest_tags
    )}"
}

resource "aws_instance" "ksql" {
  count = "${var.ksql_count}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.ksql_instance_type}"
  associate_public_ip_address = "${var.ksql_associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.ec2_public_key_name}"
  availability_zone = "${var.availability_zone}"
  vpc_security_group_ids = "${var.ksql_vpc_security_group_ids}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ksql.id}",
    "${aws_security_group.allow-all-vpc.id}",
    "${var.ksql_vpc_security_group_ids}"
  ]

  root_block_device {
    delete_on_termination = "${var.ksql_delete_root_block_device_on_termination}"
  }

  tags ="${merge(
    map("Name", "confluent-platform-ksql-node"),
    local.common_tags,
    var.ksql_tags
    )}"
}

resource "aws_ebs_volume" "broker_volume" {
  count = "${var.broker_count}"
  availability_zone = "${var.availability_zone}"
  size = "${var.broker_volume_size}"
}

resource "aws_volume_attachment" "broker_volume" {
  count = "${var.broker_count}"
  device_name = "${var.broker_volume_device_name}"
  volume_id = "${element(aws_ebs_volume.broker_volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.broker.*.id, count.index)}"
}

output "bastion_public_dns" {
  description = "Public DNS for bastion"
  value = "${aws_instance.bastion.*.public_dns}"
}

output "broker_public_dns" {
  description = "Public DNS for Brokers"
  value = "${aws_instance.broker.*.public_dns}"
}

output "broker_private_dns" {
  description = "Private DNS for Brokers"
  value = "${aws_instance.broker.*.private_dns}"
}

output "schema_registry_public_dns" {
  description = "Public DNS for Schema Registry"
  value = "${aws_instance.schema_registry.*.public_dns}"
}

output "schema_registry_private_dns" {
  description = "Private DNS for Schema Registry"
  value = "${aws_instance.schema_registry.*.private_dns}"
}

output "control_center_public_dns" {
  description = "Public DNS for Control Center"
  value = "${aws_instance.control_center.*.public_dns}"
}

output "control_center_private_dns" {
  description = "Private DNS for Control Center"
  value = "${aws_instance.control_center.*.private_dns}"
}

output "connect_distributed_public_dns" {
  description = "Public DNS for Connect Distributed"
  value = "${aws_instance.connect_distributed.*.public_dns}"
}

output "connect_distributed_private_dns" {
  description = "Private DNS for Connect Distributed"
  value = "${aws_instance.connect_distributed.*.private_dns}"
}

output "kafka_rest_public_dns" {
  description = "Public DNS for Kafka REST"
  value = "${aws_instance.kafka_rest.*.public_dns}"
}

output "kafka_rest_private_dns" {
  description = "Private DNS for Kafka REST"
  value = "${aws_instance.kafka_rest.*.private_dns}"
}

output "ksql_public_dns" {
  description = "Public DNS for KSQL Server"
  value = "${aws_instance.ksql.*.public_dns}"
}

output "ksql_private_dns" {
  description = "Private DNS for KSQL Server"
  value = "${aws_instance.ksql.*.private_dns}"
}
