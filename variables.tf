variable "aws_access_key" {}
variable "aws_access_key_secret" {}

variable "aws_region" {}

variable "availability_zone" {}

variable "subnet_id" {}

variable "vpc_id" {}

variable "os" {
  type    = string
  default = "ubuntu_20"
  validation {
    condition     = contains(["centos_7", "centos_8", "centos_9", "ubuntu_16", "ubuntu_18", "ubuntu_20", "ubuntu_22"], var.os)
    error_message = "OS value should be either of the following: centos_7, centos_8, centos_9, ubuntu_16, ubuntu_18, ubuntu_20, ubuntu_22"
  }
}



variable "cluster_name" {
  default = "Confluent-Platform-Cluster"
}

variable "security_group_cidr" {
  default = ["0.0.0.0/0"]
}

variable "owner" {}

variable "prefix" {
  default = "confluent-platform"
}

# Broker variables
variable "broker_count" {
  default = "3"
}

variable "broker_instance_type" {
  default = "t2.large"
}

variable "broker_tags" {
  type    = map(string)
  default = {}
}

variable "broker_volume_size" {
  default = "16"
}

variable "broker_root_volume_size" {
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
  default = "t2.large"
}

variable "ec2_public_key_name" {}

variable "worker_vpc_security_group_ids" {
  default = []
}

variable "worker_tags" {
  type    = map(string)
  default = {}
}

variable "worker_associate_public_ip_address" {
  default = true
}

variable "worker_delete_root_block_device_on_termination" {
  default = true
}
