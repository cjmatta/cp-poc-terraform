variable "aws_access_key" {}
variable "aws_access_key_secret" {}

variable "aws_region" {}

variable "availability_zone" {}

variable "subnet_id" {}

variable "vpc_id" {}

variable "aws_amis" {
  default = {
    "ap-northeast-1" = 	"ami-25bd2743"
    "ap-northeast-2" = 	"ami-7248e81c"
    "ap-south-1" = 	"ami-5d99ce32"
    "ap-southeast-1" = 	"ami-d2fa88ae"
    "ap-southeast-2" = 	"ami-b6bb47d4"
    "ca-central-1" = 	"ami-dcad28b8"
    "eu-central-1" = 	"ami-337be65c"
    "eu-west-1" = 	"ami-6e28b517"
    "eu-west-2" = 	"ami-ee6a718a"
    "eu-west-3" = 	"ami-bfff49c2"
    "sa-east-1" = 	"ami-f9adef95"
    "us-east-1" = 	"ami-02eac2c0129f6376b"
    "us-east-2" = 	"ami-0f2b4fc905b0bd1f1"
    "us-west-1" = 	"ami-65e0e305"
    "us-west-2" = 	"ami-a042f4d8"
  }
}

variable "cluster_name" {
  default = "Confluent-Platform-Cluster"
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
  type = "map"
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
  type = "map"
  default = {}
}

variable "worker_associate_public_ip_address" {
  default = true
}

variable "worker_delete_root_block_device_on_termination" {
  default = true
}
