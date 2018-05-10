# cp-poc-terraform
Terraform template for Confluent Platform POC on AWS

Can be used with Confluent's Ansible: http://github.com/confluentinc/cp-ansible

## Running

Clone this repository, and create a `terraform.tfvars` file containing the following keys/values:

|Property | Documentation|
| ------- | ------------ |
| owner   | tag describing the owner, will be used in cluster name |
| aws_access_key | the access key for your AWS account |
| aws_access_key_secret | the access key secret for your AWS account |
| aws_region | AWS region |
| availability_zone | AWS availability zone for your region |
| vpc_id | your vpc |
| subnet_id | The subnet to deploy into |
| ec2_public_key_name | the name of your public key to use for SSH access |

To preview your environment:
```
$ terraform plan
```

To build environment:
```
$ terraform apply
```
