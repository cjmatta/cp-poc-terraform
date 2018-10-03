#!/usr/bin/env python
# This script is meant to be used in conjunction with the JSON formatted
# output of `https://github.com/cjmatta/cp-poc-terraform
# Usage: terraform output -json` | ./register_host_keys.py
import json
import sys
import subprocess

def read_stdin_json():
    try:
        input_json = json.loads(sys.stdin.read())
        return input_json
    except ValueError, e:
        print "Error: STDIN is not JSON"
        sys.exit(1)

input = read_stdin_json()
for broker in input['broker_public_dns']['value']:
    s = ['ssh-keyscan  -t ecdsa ', broker, ' >> ~/.ssh/known_hosts']
    subprocess.call("ssh-keyscan  -t ecdsa %s >> ~/.ssh/known_hosts" % broker, shell=True)
for worker in input['worker_public_dns']['value']:
    s = ['ssh-keyscan  -t ecdsa ', worker, ' >> ~/.ssh/known_hosts']
    subprocess.call("ssh-keyscan  -t ecdsa %s >> ~/.ssh/known_hosts" % worker, shell=True)
