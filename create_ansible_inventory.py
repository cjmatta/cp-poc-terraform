#!/usr/bin/env python
# This script is meant to be used in conjunction with the JSON formatted
# output of `https://github.com/cjmatta/cp-poc-terraform
# Usage: terraform output -json` | ./create_ansible_inventory.py
import json
import argparse
from jinja2 import Template
import sys

template = Template("""all:
  vars:
    ansible_connection: ssh
    ansible_user: centos
    ansible_become: true

    #### SASL Authentication Configuration ####
    ## By default there will be no SASL Authentication
    ## For SASL/PLAIN uncomment this line:
    # sasl_protocol: plain
    ## For SASL/SCRAM uncomment this line:
    # sasl_protocol: scram
    ## For SASL/GSSAPI uncomment this line and see Kerberos Configuration properties below
    # sasl_protocol: kerberos

   #### TLS Configuration ####
    ## By default, data will NOT be encrypted. To turn on TLS encryption, uncomment this line
    # ssl_enabled: true
    ## By default, the components will be configured with One-Way TLS, to turn on TLS mutual auth, uncomment this line:
    # ssl_mutual_auth_enabled: true
    ## By default, the certs for this configuration will be self signed, to deploy custom certificates there are two options.
    ## Option 1: Custom Certs
    ## You will need to provide the path to the Certificate Authority Cert used to sign each hosts' certs
    ## As well as the signed certificate path and the key for that certificate for each host.
    ## These will need to be set for the correct host
    # ssl_custom_certs: true
    # ssl_custom_certs_remote_src: true # set to true if key crt and ca file already on hosts, file paths must still be set
    # ssl_ca_cert_filepath: "/tmp/certs/ca.crt" # Can be a bundle of ca certs to be included in truststore
    # ssl_signed_cert_filepath: "/tmp/certs/inventory_hostname-signed.crt" # Can be a full chain of certs
    # ssl_key_filepath: "/tmp/certs/inventory_hostname-key.pem"
    # ssl_key_password: <password for key for each host, will be inputting in the form -passin pass:ssl_key_password >
    ## Option 2: Custom Keystores and Truststores
    ## CP-Ansible can move keystores/truststores to their corresponding hosts and configure the components to use them. Set These vars
    # ssl_provided_keystore_and_truststore: true
    # ssl_keystore_filepath: "/tmp/certs/inventory_hostname-keystore.jks"
    # ssl_keystore_key_password: mystorepassword
    # ssl_keystore_store_password: mystorepassword
    # ssl_truststore_filepath: "/tmp/certs/truststore.jks"
    # ssl_truststore_password: truststorepass
    # ssl_truststore_ca_cert_alias: <alias to the ca certificate in the truststore eg. CARoot>

    #### Zookeeper TLS Configuration ####
    ## Zookeeper can also have TLS Encryption and mTLS Authentication
    ## For backwards compatibility both will be turned off by default, even if ssl_enabled is set to true
    ## To enable TLS encryption and mTLS authentication uncomment these respectively
    # zookeeper_ssl_enabled: true
    # zookeeper_ssl_mutual_auth_enabled: true

    #### Certificate Regeneration ####
    ## When using self signed certificates, each playbook run will regenerate the CA, to turn this off, uncomment this line:
    # regenerate_ca: false
    ## By default, the playbook will recreate them keystores and truststores on each run,
    ## To prevent this, uncomment this line:
    # regenerate_keystore_and_truststore: false

    # zookeeper_custom_properties:
    #   key: val
    # kafka_broker_custom_properties:
    #   key: val
    # schema_registry_custom_properties:
    #   key: val
    # control_center_custom_properties:
    #   key: val
    # kafka_connect_custom_properties:
    #   key: val
    # kafka_rest_custom_properties:
    #   key: val
    # ksql_custom_properties:
    #   key: val

zookeeper:
  hosts:
{%- for broker in broker_dns.value %}
    {{broker}}:
{%- endfor %}

kafka_broker:
  vars:
  hosts:
{%- for broker in broker_dns.value %}
    {{broker}}:
      broker_id: {{loop.index}}
{%- endfor %}

schema_registry:
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

control_center:
  hosts:
    {{worker_dns.value[0]}}:
      confluent.controlcenter.connect.cluster: {% for worker in worker_dns.value -%}
        {{worker}}:8083
        {%- if not loop.last %},{% endif %}
        {%- endfor %}

kafka_connect:
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

kafka_rest:
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

ksql:
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

""")

def read_stdin_json():
    try:
        input_json = json.loads(sys.stdin.read())
        return input_json
    except ValueError as e:
        print("Error: STDIN is not JSON")
        sys.exit(1)

input = read_stdin_json()

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-p", "--public", action="store_true",
  help="Use public DNS from terraform, default is private")
args = ap.parse_args()

if args.public:
    dns_type = 'public'
else:
    dns_type = 'private'
template_params = {
    "worker_dns": input['worker_'+dns_type+'_dns'], 
    "broker_dns": input['broker_'+dns_type+'_dns']
}
print(template.render(template_params))