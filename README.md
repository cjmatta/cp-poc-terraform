# cp-poc-terraform
Terraform template for Confluent Platform POC on AWS

Can be used with Confluent's Ansible: http://github.com/confluentinc/cp-ansible

## Variables

|Property | Documentation| Default | Required? |
| ------- | ------------ | ------- | --------- |
| owner   | tag describing the owner, will be used in cluster name | | yes |
| prefix   | prefix used in naming instances | confluent-platform | no |
| aws_access_key | the access key for your AWS account | | yes |
| aws_access_key_secret | the access key secret for your AWS account | | yes |
| aws_region | AWS region | | yes |
| availability_zone | AWS availability zone for your region | | yes |
| vpc_id | your vpc | | yes |
| subnet_id | The subnet to deploy into | yes | |
| ec2_public_key_name | the name of your public key to use for SSH access | | yes |
|  cluster_name | the name of your cluster | Confluent-Platform-Cluster | no |
| broker_count   | number of Kafka brokers  | 3  | no  |
|broker_instance_type   | instance type for broker  | t2.xlarge  | no  |
|broker_tags   |  map of tags for broker instances |   |  no |
|broker_volume_size   | size of the Kafka data volume in GB  | 16  | no  |
|broker_volume_device_name   | device name for volume  | /dev/xvdf  | no  |
| broker_vpc_security_group_ids  | list of vpc security group ids  |   | no  |
|broker_associate_public_ip_address   | boolean weather to associate public IP |  true |  no |
|broker_delete_root_block_device_on_termination   | boolean weather to delete the root block device on termination  | yes  | no  |
|broker_kafka_data_dir   | directory where Kafka will store it's logs  | /var/lib/kafka  | no  |
|worker_count   | number of worker nodes  | 2  | no  |
|worker_instance_type   | worker instance type  | t2.xlarge  | no  |
|worker_vpc_security_group_ids   | list of vpnc security group ids  |   | no  |
|worker_tags   | map of tags for worker instances  |   | no  |
|worker_associate_public_ip_address   | boolean weather to associate public IP  | true  | no  |
|worker_delete_root_block_device_on_termination   | boolean weather to delete the root block device on termination  | true | no  |

## Running
Clone this repository, and create a `terraform.tfvars` file containing the above required keys/values

Run `terraform init` after cloning.

To preview your environment:
```
$ terraform plan
```

To build environment:
```
$ terraform apply
```

## AWS AMIs
Currently supporting CentOS 7 AMIs in the following regions (AMI IDs taken from [here](https://wiki.centos.org/Cloud/AWS#head-78d1e3a4e6ba5c5a3847750d88266916ffe69648)):

* ap-northeast-1
* ap-northeast-2
* ap-south-1
* ap-southeast-1
* ap-southeast-2
* ca-central-1
* eu-central-1
* eu-west-1
* eu-west-2
* eu-west-3
* sa-east-1
* us-east-1
* us-east-2
* us-west-1
* us-west-2

## Provisioning
Once you have your AWS instances created the next step is to provision the Confluent Platform inside them.

The ```create_ansible_inventory.py``` script is provided to read the terraform state in JSON and convert it to YAML for use by cp-ansible. 

By default we use the private DNS names for the AWS instances which means that you need to run ansible from one of the machines in AWS. 
```
$ terraform output -json | ./create_ansible_inventory.py > hosts.yml
```
sftp hosts.yml to one of the newly created machines, then ssh into that machine and use http://github.com/confluentinc/cp-ansible from there.

### Running ansible from same place as terraform
NB! if you use the public DNS names the Kafka brokers will be accessible from the internet.

Passing the ```-p``` or ```--public``` flags to ```create_ansible_inventory.py``` causes it to use the public DNS names instead.
```
$ terraform output -json | ./create_ansible_inventory.py -p > hosts.yml
```
When running ansible locally you need to add the public keys of the machines to the ssh known_hosts file
```
$ terraform output -json | ./register_host_keys.py
```
And then in order to actually have ansible use your AWS private key to access the machines remotely use ```ssh-agent```
```
$ ssh-agent bash
bash-3.2$  ssh-add /path/to/your.pem
bash-3.2$ ansible-playbook -i hosts.yml all.yml
```
