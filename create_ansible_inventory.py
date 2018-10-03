#!/usr/bin/env python
# This script is meant to be used in conjunction with the JSON formatted
# output of `https://github.com/cjmatta/cp-poc-terraform
# Usage: terraform output -json` | ./create_ansible_inventory.py
import json
from jinja2 import Template
import sys

template = Template("""all:
  vars:
    ansible_connection: ssh
    ansible_ssh_user: centos
    ansible_become: true
    security_mode: sasl_ssl
preflight:
  hosts:
{%- for broker in broker_public_dns.value %}
    {{broker}}:
{%- endfor %}
{%- for worker in worker_public_dns.value %}
    {{worker}}:
{%- endfor %}
ssl_CA:
  hosts:
    {{broker_public_dns.value[0]}}:
zookeeper:
  hosts:
{%- for broker in broker_public_dns.value %}
    {{broker}}:
{%- endfor %}
broker:
  hosts:
{%- for broker in broker_public_dns.value %}
    {{broker}}:
      kafka:
        broker:
          id: {{loop.index}}
{%- endfor %}
schema-registry:
  hosts:
{%- for worker in worker_public_dns.value %}
    {{worker}}:
{%- endfor %}
control-center:
  hosts:
    {{worker_public_dns.value[0]}}:
      confluent:
        control:
          center:
            config:
              confluent.controlcenter.connect.cluster: {% for worker in worker_public_dns.value -%}
                {{worker}}:8083
                {%- if not loop.last %},{% endif %}
                {%- endfor %}
connect-distributed:
  hosts:
{%- for worker in worker_public_dns.value %}
    {{worker}}:
{%- endfor %}
kafka-rest:
  hosts:
{%- for worker in worker_public_dns.value %}
    {{worker}}:
{%- endfor %}
ksql:
  hosts:
{%- for worker in worker_public_dns.value %}
    {{worker}}:
{%- endfor %}
tools:
  hosts:
    {{worker_public_dns.value[0]}}:""")

def read_stdin_json():
    try:
        input_json = json.loads(sys.stdin.read())
        return input_json
    except ValueError, e:
        print "Error: STDIN is not JSON"
        sys.exit(1)

input = read_stdin_json()
print(template.render(input))