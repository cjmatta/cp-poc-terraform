variable "owner" {
  default = "myowner"
}

variable "aws_access_key" {
  default = "my_access_key"
}

variable "aws_access_key_secret" {
  default = "my_access_key_secret"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "availability_zone" {
  default = "us-east-2b"
}

variable "subnet_id" {
  default = "subnet-a71c12df"
}

variable "vpc_id" {
  default = "vpc-0be80162"
}

variable "ec2_public_key_name" {
  default = "my_public_key"
}

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
    "us-east-1" = 	"ami-4bf3d731"
    "us-east-2" = 	"ami-e1496384"
    "us-west-1" = 	"ami-65e0e305"
    "us-west-2" = 	"ami-a042f4d8"
  }
}

variable "cluster_name" {
  default = "Confluent-Platform-Cluster"
}

# Bastion variables
variable "bastion_vpc_security_group_ids" {
  default = []
}

variable "bastion_delete_root_block_device_on_termination" {
  default = true
} 

# Broker variables
variable "broker_count" {
  default = "3"
}

variable "broker_instance_type" {
  default = "t2.xlarge"
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

#Schema Registry variables
variable "schema_registry_count" {
  default = "1"
}

variable "schema_registry_instance_type" {
  default = "t2.xlarge"
}

variable "schema_registry_vpc_security_group_ids" {
  default = []
}

variable "schema_registry_associate_public_ip_address" {
  default = true
}

variable "schema_registry_delete_root_block_device_on_termination" {
  default = true
}

variable "schema_registry_tags" {
  type = "map"
  default = {}
}

#Control Center Variables
variable "control_center_count" {
  default = "1"
}

variable "control_center_instance_type" {
  default = "t2.xlarge"
}

variable "control_center_vpc_security_group_ids" {
  default = []
}

variable "control_center_associate_public_ip_address" {
  default = true
}

variable "control_center_delete_root_block_device_on_termination" {
  default = true
}

variable "control_center_tags" {
  type = "map"
  default = {}
}

#Connect Distributed Variables
variable "connect_distributed_count" {
  default = "0"
}

variable "connect_distributed_instance_type" {
  default = "t2.xlarge"
}

variable "connect_distributed_vpc_security_group_ids" {
  default = []
}

variable "connect_distributed_associate_public_ip_address" {
  default = true
}

variable "connect_distributed_delete_root_block_device_on_termination" {
  default = true
}

variable "connect_distributed_tags" {
  type = "map"
  default = {}
}

#Kafka REST Variables
variable "kafka_rest_count" {
  default = "0"
}

variable "kafka_rest_instance_type" {
  default = "t2.xlarge"
}

variable "kafka_rest_vpc_security_group_ids" {
  default = []
}

variable "kafka_rest_associate_public_ip_address" {
  default = true
}

variable "kafka_rest_delete_root_block_device_on_termination" {
  default = true
}

variable "kafka_rest_tags" {
  type = "map"
  default = {}
}

#KSQL Server Variables
variable "ksql_count" {
  default = "0"
}

variable "ksql_instance_type" {
  default = "t2.xlarge"
}

variable "ksql_vpc_security_group_ids" {
  default = []
}

variable "ksql_associate_public_ip_address" {
  default = true
}

variable "ksql_delete_root_block_device_on_termination" {
  default = true
}

variable "ksql_tags" {
  type = "map"
  default = {}
}

