variable "aws_access_key" {}
variable "aws_access_key_secret" {}

variable "aws_region" {}

variable "availability_zone" {}

variable "subnet_id" {}

variable "vpc_id" {}

variable "aws_amis" {
  default = {
    "us-east-1" = "ami-2051294a"
  }
}

variable "cluster_name" {
  default = "Confluent-Platform-Cluster"
}

variable "owner" {}

# Broker variables
variable "broker_count" {
  default = "3"
}

variable "broker_instance_type" {
  default = "t2.medium"
}

variable "broker_tags" {
  type = "map"
  default = {}
}

variable "broker_volume_size" {
  default = "16"
}

variable "broker_volume_device_name" {
  default = "/dev/xvdf"
}

variable "broker_vpc_security_group_ids" {
  default = []
}

variable "broker_associate_public_ip_address" {
  default = true
}

variable "broker_delete_root_block_device_on_termination" {
  default = true
}

variable "broker_kafka_data_dir" {
  default = "/var/lib/kafka"
}

# Worker variables
variable "worker_count" {
  default = "2"
}

variable "worker_instance_type" {
  default = "t2.medium"
}

variable "ec2_public_key_name" {}

variable "worker_vpc_security_group_ids" {
  default = []
}

variable "worker_tags" {
  type = "map"
  default = {}
}

variable "worker_associate_public_ip_address" {
  default = true
}

variable "worker_delete_root_block_device_on_termination" {
  default = true
}
